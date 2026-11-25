#import "SCCatalogDetailViewController.h"

#import "SCMusicNavigation.h"
#import "SCPlaybackManager.h"
#import "SCLibraryStore.h"

@interface SCCatalogDetailViewController ()
@property (nonatomic, strong) id<SCMusicItem> item;
@property (nonatomic, copy) NSArray<SCTrack *> *tracks;
@end
@implementation SCCatalogDetailViewController

#pragma mark - Lifecycle

- (instancetype)initWithItem:(id<SCMusicItem>)item tracks:(NSArray<SCTrack *> *)tracks {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _item = item;
        _tracks = tracks.copy;
        self.title = item.title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SCCatalogDetailView *page = (id)self.view;
    [page.back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    __weak typeof(self) weakSelf = self;
    page.selectItem = ^(id<SCMusicItem> item, NSUInteger index) {
        if ([(NSObject *)item isKindOfClass:SCTrack.class])
            [weakSelf playAt:index];
        else
            [SCMusicNavigation openItem:item from:weakSelf];
    };
    page.moreAction = ^(id<SCMusicItem> item) {
        [SCMusicNavigation showOptionsFor:item from:weakSelf];
    };
    page.controlsReady = ^(SCReleaseControlsCell *cell) {
        [cell.save addTarget:weakSelf action:@selector(toggleSaved) forControlEvents:UIControlEventTouchUpInside];
        [cell.download addTarget:weakSelf action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
        [cell.more addTarget:weakSelf action:@selector(more) forControlEvents:UIControlEventTouchUpInside];
        [cell.shuffle addTarget:weakSelf action:@selector(shuffle) forControlEvents:UIControlEventTouchUpInside];
        [cell.play addTarget:weakSelf action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    };
    NSNotificationCenter *notifications = NSNotificationCenter.defaultCenter;
    [notifications addObserver:self
                      selector:@selector(changed:)
                          name:SCPlaybackDidChangeNotification
                        object:SCPlaybackManager.sharedManager];
    [notifications addObserver:self
                      selector:@selector(changed:)
                          name:SCLibraryDidChange
                        object:SCLibraryStore.sharedStore];
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self refresh];
}

#pragma mark - Actions

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toggleSaved {
    SCLibraryStore *store = SCLibraryStore.sharedStore;
    [store setSaved:![store containsID:self.item.identifier] identifier:self.item.identifier];
}

- (void)more {
    [SCMusicNavigation showOptionsFor:self.item from:self];
}

- (void)download {
    if (self.presentedViewController)
        return;
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Download"
                                            message:@"Downloads are unavailable in this local preview."
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)play {
    if ([SCPlaybackManager.sharedManager.sourceIdentifier isEqual:self.item.identifier])
        [SCPlaybackManager.sharedManager togglePlayback];
    else
        [self playAt:0];
}

- (void)shuffle {
    if (!self.tracks.count)
        return;
    SCPlaybackManager *manager = SCPlaybackManager.sharedManager;
    if ([manager.sourceIdentifier isEqual:self.item.identifier]) {
        [manager toggleShuffle];
        return;
    }
    if (manager.snapshot.mode != SCPlaybackModeShuffle)
        [manager toggleShuffle];
    [self playAt:arc4random_uniform((uint32_t)self.tracks.count)];
}

- (void)changed:(NSNotification *)notification {
    [self refresh];
}

#pragma mark - Private Methods

- (void)playAt:(NSUInteger)index {
    [SCPlaybackManager.sharedManager playQueue:self.tracks
                                       atIndex:index
                                        source:self.item.title
                                    identifier:self.item.identifier];
}

- (void)refresh {
    SCPlaybackManager *manager = SCPlaybackManager.sharedManager;
    SCCatalogDetailView *page = (id)self.view;
    [page refreshWithSnapshot:manager.snapshot
                        saved:[SCLibraryStore.sharedStore containsID:self.item.identifier]
                playingSource:manager.snapshot.playing && [manager.sourceIdentifier isEqual:self.item.identifier]
                    hasTracks:self.tracks.count > 0];
}

@end
