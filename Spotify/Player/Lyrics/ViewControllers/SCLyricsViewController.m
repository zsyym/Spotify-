#import "SCLyricsViewController.h"
#import "SCLyricsView.h"
#import "SCLyricsTimeline.h"
#import "SCLyricsProvider.h"
#import "SCPlaybackManager.h"

@interface SCLyricsViewController ()
@property (nonatomic, strong) SCLyricsView *page;
@property (nonatomic, strong) SCLyricsModel *lyrics;
@property (nonatomic, copy) NSString *trackID;
@property (nonatomic, assign) NSUInteger generation;
@end
@implementation SCLyricsViewController
#pragma mark - Lifecycle

- (void)loadView {
    self.page = [SCLyricsView new];
    self.view = self.page;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SCPlaybackManager *manager = SCPlaybackManager.sharedManager;
    [self.page.play addTarget:manager action:@selector(togglePlayback) forControlEvents:UIControlEventTouchUpInside];
    [self.page.progress.slider addTarget:self action:@selector(seek:) forControlEvents:UIControlEventValueChanged];
    [self.page.back addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.page.share addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    self.page.seekLine = ^(NSTimeInterval time) {
        [manager seekTo:time];
    };
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(updated:)
                                               name:SCPlaybackDidChangeNotification
                                             object:manager];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(advanced:)
                                               name:SCPlaybackProgressDidChange
                                             object:manager];
    [self updated:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Actions

- (void)close {
    [self dismissViewControllerAnimated:!UIAccessibilityIsReduceMotionEnabled() completion:nil];
}

- (void)seek:(UISlider *)slider {
    [SCPlaybackManager.sharedManager seekTo:slider.value];
}

- (void)share {
    SCTrack *track = SCPlaybackManager.sharedManager.snapshot.track;
    if (!track || self.presentedViewController)
        return;
    UIActivityViewController *share = [[UIActivityViewController alloc]
        initWithActivityItems:@[ [NSString stringWithFormat:@"%@ — %@", track.title, track.subtitle] ]
        applicationActivities:nil];
    share.popoverPresentationController.sourceView = self.page.share;
    share.popoverPresentationController.sourceRect = self.page.share.bounds;
    [self presentViewController:share animated:YES completion:nil];
}

- (void)updated:(NSNotification *)notification {
    SCPlaybackSnapshot *state = SCPlaybackManager.sharedManager.snapshot;
    [self.page renderPlayback:state];
    if (![self.trackID isEqual:state.track.identifier]) {
        self.trackID = state.track.identifier;
        self.lyrics = nil;
        NSUInteger token = ++self.generation;
        [self.page beginTrack:state.track];
        if (!state.track)
            return;
        __weak typeof(self) weakSelf = self;
        [SCLyricsProvider loadTrack:state.track
                         completion:^(SCLyricsModel *model) {
                             typeof(self) self = weakSelf;
                             if (!self || self.generation != token)
                                 return;
                             self.lyrics = model;
                             [self.page display:model];
                             [self syncIndex];
                         }];
    } else
        [self syncIndex];
}

- (void)advanced:(NSNotification *)notification {
    [self.page.progress render:SCPlaybackManager.sharedManager.snapshot];
    [self syncIndex];
}

#pragma mark - Private Methods

- (void)syncIndex {
    if (self.lyrics.kind == SCLyricsTimed)
        [self.page highlight:[SCLyricsTimeline indexInLines:self.lyrics.lines
                                                     atTime:SCPlaybackManager.sharedManager.snapshot.progress]];
}
@end
