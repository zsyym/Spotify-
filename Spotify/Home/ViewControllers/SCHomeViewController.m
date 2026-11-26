#import "SCRootContainerViewController.h"
#import "SCPlaybackManager.h"
#import "SCHomeViewController.h"
#import "SCMusicNavigation.h"
#import "SCHomeView.h"
#import "SCHomeHeaderView.h"
#import "SCHomePlaylistCell.h"
#import "SCHomeShortcutCell.h"
#import "SCHomeSectionHeaderView.h"
#import "SCTrackCell.h"
#import "SCPlaylist.h"
#import "SCPlaylistDetailViewController.h"

typedef NS_ENUM(NSInteger, SCHomeRecommendationState) {
    SCHomeRecommendationIdle,
    SCHomeRecommendationLoading,
    SCHomeRecommendationSuccess,
    SCHomeRecommendationEmpty,
    SCHomeRecommendationError,
    SCHomeRecommendationRefreshing,
};

@interface SCHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) SCHomeRecommendationState recommendationState;
@property (nonatomic, strong) SCHomeView *homeView;
@property (nonatomic, strong) id<SCHomeDataProviding> dataProvider;
@property (nonatomic, copy) NSArray<SCHomeSectionModel *> *sections;
@end

@implementation SCHomeViewController

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithDataProvider:[SCHomeDataProvider new]];
}

- (instancetype)initWithDataProvider:(id<SCHomeDataProviding>)dataProvider {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _dataProvider = dataProvider;
        _sections = @[];
        self.title = @"Home";
    }
    return self;
}

- (void)loadView {
    self.homeView = [SCHomeView new];
    self.view = self.homeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.homeView.collectionView.dataSource = self;
    self.homeView.collectionView.delegate = self;
    __weak typeof(self) weakSelf = self;
    self.homeView.headerView.profileAction = ^{
        [SCRootContainerViewController openSidebarFrom:weakSelf];
    };
    self.sections = [SCHomeDataProvider sectionsWithRecommendedPlaylists:@[]];
    [self.homeView showSections:self.sections];
    [self.homeView.collectionView.refreshControl addTarget:self
                                                    action:@selector(loadRecommendations)
                                          forControlEvents:UIControlEventValueChanged];
    [self loadRecommendations];
}

- (void)dealloc {
    if ([_dataProvider respondsToSelector:@selector(cancelLoading)])
        [_dataProvider cancelLoading];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SCHomeSectionModel *section = self.sections[indexPath.section];
    id<SCMusicItem> item = section.items[indexPath.item];
    if (section.kind == SCHomeSectionKindShortcuts) {
        SCHomeShortcutCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shortcut"
                                                                             forIndexPath:indexPath];
        [cell configureWithItem:item];
        return cell;
    }
    if (section.kind == SCHomeSectionKindTracks) {
        SCTrackCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"track" forIndexPath:indexPath];
        [cell configureWithTrack:(SCTrack *)item];
        return cell;
    }
    SCHomePlaylistCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"card" forIndexPath:indexPath];
    [cell configureWithItem:item album:section.kind == SCHomeSectionKindAlbums];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    SCHomeSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                         withReuseIdentifier:@"title"
                                                                                forIndexPath:indexPath];
    [self configureHeader:header atIndex:indexPath.section];
    return header;
}

#pragma mark - Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    id<SCMusicItem> item = self.sections[indexPath.section].items[indexPath.item];
    if ([(NSObject *)item isKindOfClass:SCPlaylist.class]) {
        SCPlaylistDetailViewController *detail =
            [[SCPlaylistDetailViewController alloc] initWithPlaylist:(SCPlaylist *)item];
        [self.navigationController pushViewController:detail animated:YES];
        return;
    }
    SCHomeSectionModel *section = self.sections[indexPath.section];
    if (section.kind == SCHomeSectionKindTracks) {
        [SCPlaybackManager.sharedManager playQueue:(NSArray<SCTrack *> *)section.items
                                           atIndex:indexPath.item
                                            source:section.title];
        return;
    }
    [SCMusicNavigation openItem:item from:self];
}

#pragma mark - Private Methods

- (void)loadRecommendations {
    if (self.recommendationState == SCHomeRecommendationLoading ||
        self.recommendationState == SCHomeRecommendationRefreshing)
        return;
    SCHomeRecommendationState previous = self.recommendationState;
    self.recommendationState =
        previous == SCHomeRecommendationIdle ? SCHomeRecommendationLoading : SCHomeRecommendationRefreshing;
    [self updateRecommendationHeader];
    __weak typeof(self) weakSelf = self;
    [self.dataProvider loadSectionsWithCompletion:^(NSArray<SCHomeSectionModel *> *sections, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self)
                return;
            [self.homeView.collectionView.refreshControl endRefreshing];
            if (error) {
                self.recommendationState =
                    ([error.domain isEqual:NSURLErrorDomain] && error.code == NSURLErrorCancelled)
                        ? previous
                        : SCHomeRecommendationError;
                [self updateRecommendationHeader];
                return;
            }
            self.sections = [sections copy];
            self.recommendationState =
                sections.lastObject.items.count ? SCHomeRecommendationSuccess : SCHomeRecommendationEmpty;
            [self.homeView showSections:self.sections];
        });
    }];
}

- (void)updateRecommendationHeader {
    if (!self.sections.count)
        return;
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:self.sections.count - 1];
    SCHomeSectionHeaderView *header =
        (id)[self.homeView.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader
                                                              atIndexPath:path];
    [self configureHeader:header atIndex:path.section];
    [self.homeView.collectionView.collectionViewLayout invalidateLayout];
}

- (void)configureHeader:(SCHomeSectionHeaderView *)header atIndex:(NSInteger)index {
    BOOL recommendation = index == (NSInteger)self.sections.count - 1;
    NSString *message = nil;
    BOOL retry = NO;
    if (recommendation) {
        switch (self.recommendationState) {
            case SCHomeRecommendationLoading:
                message = @"Loading recommendations…";
                break;
            case SCHomeRecommendationRefreshing:
                message = @"Refreshing recommendations…";
                break;
            case SCHomeRecommendationEmpty:
                message = @"No recommendations available today.";
                break;
            case SCHomeRecommendationError:
                message = self.sections.lastObject.items.count ? @"Couldn’t refresh. Showing previous recommendations."
                                                               : @"Couldn’t load recommendations.";
                retry = YES;
                break;
            default:
                break;
        }
    }
    __weak typeof(self) weakSelf = self;
    header.retryAction = ^{
        [weakSelf loadRecommendations];
    };
    [header configureTitle:self.sections[index].title message:message allowsRetry:retry];
}

@end
