#import "SCPlaybackManager.h"
#import "SCLibraryStore.h"
#import "SCPlaylistDetailViewController.h"
#import "SCPlaylistDetailModel.h"
#import "SCPlaylistDetailView.h"
#import "SCPlaylistHeaderView.h"
#import "SCPlaylistTrackCell.h"

@interface SCPlaylistDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) SCPlaylistDetailModel *model;
@property (nonatomic, strong) SCPlaylistDetailView *detailView;

@end

@implementation SCPlaylistDetailViewController

#pragma mark - Lifecycle

- (instancetype)initWithPlaylist:(SCPlaylist *)playlist {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _model = [[SCPlaylistDetailModel alloc] initWithPlaylist:playlist];
        self.title = playlist.title;
    }
    return self;
}

- (void)loadView {
    self.detailView = [SCPlaylistDetailView new];
    self.view = self.detailView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(savedItemsChanged:)
                                                 name:SCLibraryDidChange
                                               object:SCLibraryStore.sharedStore];
    [self.detailView setPlaylistTitle:self.model.playlist.title];
    self.detailView.collectionView.dataSource = self;
    self.detailView.collectionView.delegate = self;
    [self.detailView.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.detailView.collectionView reloadData];
    for (SCPlaylistHeaderView *header in
         [self.detailView.collectionView visibleSupplementaryViewsOfKind:UICollectionElementKindSectionHeader]) {
        [header showSaved:self.model.playlist.isSaved
            shuffleEnabled:(SCPlaybackManager.sharedManager.snapshot.mode == SCPlaybackModeShuffle)];
    }
}

#pragma mark - Actions

- (void)savedItemsChanged:(NSNotification *)note {
    NSString *changedID = note.userInfo[@"savedIdentifier"];
    if (changedID && ([changedID isEqual:self.model.playlist.identifier] ||
                      self.model.playlist == SCLocalMusicCatalog.sharedCatalog.playlists.firstObject))
        [self.detailView.collectionView reloadData];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleAction:(SCPlaylistAction)action fromHeader:(SCPlaylistHeaderView *)header {
    SCPlaylist *playlist = self.model.playlist;
    switch (action) {
        case SCPlaylistActionSave:
            playlist.saved = !playlist.isSaved;
            [header showSaved:playlist.isSaved
                shuffleEnabled:(SCPlaybackManager.sharedManager.snapshot.mode == SCPlaybackModeShuffle)];
            break;
        case SCPlaylistActionShuffle:
            [SCPlaybackManager.sharedManager toggleShuffle];
            [header showSaved:playlist.isSaved
                shuffleEnabled:(SCPlaybackManager.sharedManager.snapshot.mode == SCPlaybackModeShuffle)];
            break;
        case SCPlaylistActionDownload:
            [self showNotice:@"Download" message:@"Offline downloads are not available yet."];
            break;
        case SCPlaylistActionMore:
            [self showNotice:playlist.title message:@"More playlist options are coming later."];
            break;
        case SCPlaylistActionPlay:
            if (playlist.tracks.count)
                [SCLibraryStore.sharedStore recordPlayedIDs:@[ playlist.identifier ]];
            [SCPlaybackManager.sharedManager playQueue:playlist.tracks atIndex:0 source:playlist.title];
            break;
    }
}

#pragma mark - Delegate / DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.playlist.tracks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SCPlaylistTrackCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SCPlaylistTrackCell.class)
                                                  forIndexPath:indexPath];
    [cell configureWithTrack:self.model.playlist.tracks[indexPath.item]];
    __weak typeof(self) weakSelf = self;
    cell.moreAction = ^(SCTrack *track) {
        [weakSelf showNotice:track.title message:@"More track options are coming later."];
    };
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    SCPlaylistHeaderView *header =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                           withReuseIdentifier:NSStringFromClass(SCPlaylistHeaderView.class)
                                                  forIndexPath:indexPath];
    [header configureWithModel:self.model
                shuffleEnabled:(SCPlaybackManager.sharedManager.snapshot.mode == SCPlaybackModeShuffle)];
    __weak typeof(self) weakSelf = self;
    __weak SCPlaylistHeaderView *weakHeader = header;
    header.actionHandler = ^(SCPlaylistAction action) {
        [weakSelf handleAction:action fromHeader:weakHeader];
    };
    return header;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [SCLibraryStore.sharedStore recordPlayedIDs:@[ self.model.playlist.identifier ]];
    SCTrack *track = self.model.playlist.tracks[indexPath.item];
    [SCPlaybackManager.sharedManager playQueue:self.model.playlist.tracks
                                       atIndex:indexPath.item
                                        source:self.model.playlist.title];
    if (self.trackSelectionHandler) {
        self.trackSelectionHandler(track);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.detailView updateNavigationAppearance];
}

#pragma mark - Private Methods

- (void)showNotice:(NSString *)title message:(NSString *)message {
    if (self.presentedViewController) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
