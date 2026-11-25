#import "SCLyricsViewController.h"
#import "SCPlayerViewController.h"
#import "SCPlayerView.h"
#import "SCPlaybackQueueViewController.h"
#import "SCPlaybackManager.h"

@interface SCPlayerViewController ()
@property (nonatomic, strong) SCPlayerView *playerView;
@end
@implementation SCPlayerViewController

#pragma mark - Lifecycle

- (void)loadView {
    self.playerView = [SCPlayerView new];
    self.view = self.playerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SCPlaybackManager *manager = SCPlaybackManager.sharedManager;
    SCPlayerControlsView *controls = self.playerView.controlsView;
    [controls.playButton addTarget:manager
                            action:@selector(togglePlayback)
                  forControlEvents:UIControlEventTouchUpInside];
    [controls.shuffleButton addTarget:manager
                               action:@selector(toggleShuffle)
                     forControlEvents:UIControlEventTouchUpInside];
    [controls.repeatButton addTarget:manager
                              action:@selector(cycleRepeatMode)
                    forControlEvents:UIControlEventTouchUpInside];
    [controls.nextButton addTarget:self action:@selector(nextTrack) forControlEvents:UIControlEventTouchUpInside];
    [controls.previousButton addTarget:self
                                action:@selector(previousTrack)
                      forControlEvents:UIControlEventTouchUpInside];
    [self.playerView.favoriteButton addTarget:manager
                                       action:@selector(toggleFavorite)
                             forControlEvents:UIControlEventTouchUpInside];
    [self.playerView.progressView.slider addTarget:self
                                            action:@selector(seek:)
                                  forControlEvents:UIControlEventValueChanged];
    [self.playerView.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.playerView.moreButton addTarget:self
                                   action:@selector(showOptions)
                         forControlEvents:UIControlEventTouchUpInside];
    [self.playerView.queueButton addTarget:self
                                    action:@selector(openQueue)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.playerView.deviceButton addTarget:self
                                     action:@selector(showDevices)
                           forControlEvents:UIControlEventTouchUpInside];
    [self.playerView.shareButton addTarget:self
                                    action:@selector(shareTrack)
                          forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackChanged:)
                                                 name:SCPlaybackDidChangeNotification
                                               object:manager];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(progressChanged:)
                                               name:SCPlaybackProgressDidChange
                                             object:manager];
    [self.playerView render:manager.snapshot];
}

#pragma mark - Actions

- (void)nextTrack {
    [SCPlaybackManager.sharedManager skipBy:1];
}

- (void)previousTrack {
    [SCPlaybackManager.sharedManager skipBy:-1];
}

- (void)close {
    [self dismissViewControllerAnimated:!UIAccessibilityIsReduceMotionEnabled() completion:nil];
}

- (void)seek:(UISlider *)slider {
    [SCPlaybackManager.sharedManager seekTo:slider.value];
}

- (void)playbackChanged:(NSNotification *)notification {
    [self.playerView render:SCPlaybackManager.sharedManager.snapshot];
}

- (void)progressChanged:(NSNotification *)notification {
    [self.playerView.progressView render:SCPlaybackManager.sharedManager.snapshot];
}

- (void)openLyrics {
    SCLyricsViewController *page = [SCLyricsViewController new];
    page.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:page animated:!UIAccessibilityIsReduceMotionEnabled() completion:nil];
}

- (void)openQueue {
    if (self.presentedViewController)
        return;
    SCPlaybackQueueViewController *queue = [SCPlaybackQueueViewController new];
    queue.modalPresentationStyle = UIModalPresentationPageSheet;
    UISheetPresentationController *sheet = queue.sheetPresentationController;
    sheet.detents =
        @[ [UISheetPresentationControllerDetent mediumDetent], [UISheetPresentationControllerDetent largeDetent] ];
    sheet.prefersGrabberVisible = YES;
    sheet.preferredCornerRadius = 20;
    [self presentViewController:queue animated:!UIAccessibilityIsReduceMotionEnabled() completion:nil];
}

- (void)shareTrack {
    if (self.presentedViewController)
        return;
    SCTrack *track = SCPlaybackManager.sharedManager.snapshot.track;
    NSString *text = [NSString stringWithFormat:@"%@ — %@", track.title, track.artist.name ?: track.subtitle];
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[ text ]
                                                                        applicationActivities:nil];
    share.popoverPresentationController.sourceView = self.playerView.shareButton;
    share.popoverPresentationController.sourceRect = self.playerView.shareButton.bounds;
    [self presentViewController:share animated:!UIAccessibilityIsReduceMotionEnabled() completion:nil];
}

- (void)showDevices {
    [self showNotice:@"Audio output" message:@"Device selection is unavailable for local preview tracks."];
}

- (void)showOptions {
    if (self.presentedViewController)
        return;
    UIAlertController *options =
        [UIAlertController alertControllerWithTitle:SCPlaybackManager.sharedManager.snapshot.track.title
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [options addAction:[UIAlertAction actionWithTitle:@"Lyrics"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action) {
                                                  [weakSelf openLyrics];
                                              }]];
    [options addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    options.popoverPresentationController.sourceView = self.playerView.moreButton;
    options.popoverPresentationController.sourceRect = self.playerView.moreButton.bounds;
    [self presentViewController:options animated:!UIAccessibilityIsReduceMotionEnabled() completion:nil];
}

#pragma mark - Private Methods

- (void)showNotice:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:!UIAccessibilityIsReduceMotionEnabled() completion:nil];
}

@end
