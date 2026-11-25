#import "SCPlaybackQueueViewController.h"
#import "SCPlaybackManager.h"
#import "SCPlaybackQueueView.h"
#import "SCPlaybackQueueCell.h"
#import "SCMusicStyle.h"

@interface SCPlaybackQueueViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) SCPlaybackQueueView *queueView;
@property (nonatomic, strong) SCPlaybackSnapshot *state;
@end

@implementation SCPlaybackQueueViewController

#pragma mark - Lifecycle

- (void)loadView {
    self.queueView = [SCPlaybackQueueView new];
    self.view = self.queueView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    self.state = SCPlaybackManager.sharedManager.snapshot;
    [self.queueView.tableView registerClass:SCPlaybackQueueCell.class forCellReuseIdentifier:@"track"];
    self.queueView.tableView.dataSource = self;
    self.queueView.tableView.delegate = self;
    [self.queueView.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackChanged:)
                                                 name:SCPlaybackDidChangeNotification
                                               object:SCPlaybackManager.sharedManager];
}

#pragma mark - Actions

- (void)close {
    [self dismissViewControllerAnimated:!UIAccessibilityIsReduceMotionEnabled() completion:nil];
}

- (void)playbackChanged:(NSNotification *)notification {
    SCPlaybackSnapshot *next = SCPlaybackManager.sharedManager.snapshot;
    BOOL changed = next.queue != self.state.queue || next.index != self.state.index || next.mode != self.state.mode;
    self.state = next;
    if (changed)
        [self.queueView.tableView reloadData];
}

- (void)showTrackInfo:(SCTrack *)track {
    if (self.presentedViewController)
        return;
    UIAlertController *info = [UIAlertController alertControllerWithTitle:track.title
                                                                  message:track.artist.name ?: track.subtitle
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [info addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:info animated:!UIAccessibilityIsReduceMotionEnabled() completion:nil];
}

#pragma mark - Delegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"Now Playing" : @"Next Up";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    UIBackgroundConfiguration *background = [UIBackgroundConfiguration clearConfiguration];
    background.backgroundColor = SCMusicColor(SCColorSurface);
    header.backgroundConfiguration = background;
    header.textLabel.textColor = SCMusicColor(SCColorSecondaryText);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.state.track)
        return 0;
    if (section == 0)
        return 1;
    if (self.state.mode == SCPlaybackModeRepeatAll)
        return self.state.queue.count - 1;
    return self.state.queue.count - self.state.index - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)path {
    SCPlaybackQueueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"track" forIndexPath:path];
    [cell configureWithTrack:self.state.queue[[self queueIndexForPath:path]] current:path.section == 0];
    __weak typeof(self) weakSelf = self;
    cell.moreAction = ^(SCTrack *track) {
        [weakSelf showTrackInfo:track];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    [tableView deselectRowAtIndexPath:path animated:!UIAccessibilityIsReduceMotionEnabled()];
    if (path.section == 1)
        [SCPlaybackManager.sharedManager selectQueueIndex:[self queueIndexForPath:path]];
}

#pragma mark - Private Methods

- (NSUInteger)queueIndexForPath:(NSIndexPath *)path {
    if (path.section == 0)
        return self.state.index;
    return (self.state.index + 1 + path.row) % self.state.queue.count;
}

@end
