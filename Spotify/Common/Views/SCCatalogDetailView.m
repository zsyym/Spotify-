#import "SCCatalogDetailView.h"

#import "SCMusicItemCell.h"
#import "SCPlayerStyle.h"
#import "SCHomeSectionHeaderView.h"
@implementation SCDetailSection
+ (instancetype)section:(SCDetailSectionKind)kind title:(NSString *)heading items:(NSArray<id<SCMusicItem>> *)items {
    SCDetailSection *section = [self new];
    section->_kind = kind;
    section->_heading = heading.copy;
    section->_items = items.copy;
    return section;
}

@end

@interface SCCatalogDetailView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, copy) NSArray<SCDetailSection *> *sections;
@property (nonatomic, strong) id<SCMusicItem> item;
@property (nonatomic, strong) UILabel *navTitle;
@property (nonatomic, strong) SCPlaybackSnapshot *snapshot;
@property (nonatomic, assign) BOOL saved;
@property (nonatomic, assign) BOOL playingSource;
@property (nonatomic, assign) BOOL hasTracks;
@end
@implementation SCCatalogDetailView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)displayItem:(id<SCMusicItem>)item sections:(NSArray<SCDetailSection *> *)sections {
    self.item = item;
    self.sections = sections;
    self.navTitle.text = item.title;
    [self.collection reloadData];
    [self.collection.collectionViewLayout invalidateLayout];
}

- (Class)heroClass {
    return UICollectionViewCell.class;
}

- (void)configureHero:(UICollectionViewCell *)cell {
}

- (void)refreshWithSnapshot:(SCPlaybackSnapshot *)snapshot
                      saved:(BOOL)saved
              playingSource:(BOOL)playingSource
                  hasTracks:(BOOL)hasTracks {
    self.snapshot = snapshot;
    self.saved = saved;
    self.playingSource = playingSource;
    self.hasTracks = hasTracks;
    for (NSIndexPath *path in self.collection.indexPathsForVisibleItems) {
        UICollectionViewCell *cell = [self.collection cellForItemAtIndexPath:path];
        if ([cell isKindOfClass:SCNumberedTrackCell.class])
            [self renderTrack:(id)cell path:path];
        else if ([cell isKindOfClass:SCReleaseControlsCell.class])
            [self renderControls:(id)cell];
    }
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCMusicColor(SCColorBackground);
    _back = SCPlayerButton(@"chevron.backward", @"Back", 20);
    self.navTitle = SCMusicLabel(17, UIFontWeightBold);
    self.navTitle.textAlignment = NSTextAlignmentCenter;
    self.navTitle.numberOfLines = 1;
    self.navTitle.alpha = 0;
    __weak typeof(self) weakSelf = self;
    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc]
        initWithSectionProvider:^NSCollectionLayoutSection *(NSInteger index, id<NSCollectionLayoutEnvironment> env) {
            return [weakSelf layoutAt:index width:env.container.effectiveContentSize.width];
        }];
    _collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collection.backgroundColor = UIColor.clearColor;
    self.collection.alwaysBounceVertical = YES;
    self.collection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.collection.dataSource = self;
    self.collection.delegate = self;
    for (Class type in @[
             [self heroClass],
             SCReleaseControlsCell.class,
             SCNumberedTrackCell.class,
             SCMusicItemCell.class,
             UICollectionViewCell.class
         ])
        [self.collection registerClass:type forCellWithReuseIdentifier:NSStringFromClass(type)];
    [self.collection registerClass:SCHomeSectionHeaderView.class
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:@"heading"];
    [self addSubview:self.collection];
    [self addSubview:self.back];
    [self addSubview:self.navTitle];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.back mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(4);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [self.navTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.back);
        make.left.equalTo(self.back.mas_right);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-52);
    }];
    [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.top.equalTo(self.back.mas_bottom);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
    }];
}

- (NSCollectionLayoutSection *)layoutAt:(NSInteger)index width:(CGFloat)width {
    if (index >= (NSInteger)self.sections.count)
        return nil;
    SCDetailSection *section = self.sections[index];
    BOOL shelf = section.kind == SCDetailShelf;
    CGFloat height = 64;
    switch (section.kind) {
        case SCDetailHero:
            height = [self isArtist] ? MIN(width * 0.76, 360) : MIN(width * 0.66, 250) + 140;
            break;
        case SCDetailShelf:
            height = 194;
            break;
        case SCDetailNote:
            height = [self isArtist] ? 138 : 82;
            break;
        case SCDetailControls:
            height = 72;
            break;
        default:
            break;
    }
    NSCollectionLayoutDimension *full = [NSCollectionLayoutDimension fractionalWidthDimension:1];
    NSCollectionLayoutSize *size = [NSCollectionLayoutSize
        sizeWithWidthDimension:shelf ? [NSCollectionLayoutDimension absoluteDimension:138] : full
               heightDimension:[NSCollectionLayoutDimension absoluteDimension:height]];
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem
        itemWithLayoutSize:[NSCollectionLayoutSize
                               sizeWithWidthDimension:full
                                      heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];
    NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:size subitems:@[ item ]];
    NSCollectionLayoutSection *layout = [NSCollectionLayoutSection sectionWithGroup:group];
    CGFloat margin = section.kind == SCDetailHero ? 0 : 16;
    layout.contentInsets = NSDirectionalEdgeInsetsMake(0, margin, shelf ? 16 : 0, margin);
    if (shelf) {
        layout.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuous;
        layout.interGroupSpacing = 14;
    }
    if (section.heading.length) {
        NSCollectionLayoutSize *headerSize =
            [NSCollectionLayoutSize sizeWithWidthDimension:full
                                           heightDimension:[NSCollectionLayoutDimension absoluteDimension:56]];
        layout.boundarySupplementaryItems = @[ [NSCollectionLayoutBoundarySupplementaryItem
            boundarySupplementaryItemWithLayoutSize:headerSize
                                        elementKind:UICollectionElementKindSectionHeader
                                          alignment:NSRectAlignmentTop] ];
    }
    return layout;
}

#pragma mark - Delegate / DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collection {
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collection numberOfItemsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collection cellForItemAtIndexPath:(NSIndexPath *)path {
    SCDetailSection *section = self.sections[path.section];
    id<SCMusicItem> item = section.items[path.item];
    switch (section.kind) {
        case SCDetailHero: {
            UICollectionViewCell *hero =
                [collection dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self heroClass])
                                                      forIndexPath:path];
            [self configureHero:hero];
            return hero;
        }
        case SCDetailControls: {
            SCReleaseControlsCell *cell =
                [collection dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SCReleaseControlsCell.class)
                                                      forIndexPath:path];
            [self renderControls:cell];
            if (self.controlsReady)
                self.controlsReady(cell);
            return cell;
        }
        case SCDetailTracks: {
            SCNumberedTrackCell *cell =
                [collection dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SCNumberedTrackCell.class)
                                                      forIndexPath:path];
            [self renderTrack:cell path:path];
            [cell.moreButton addTarget:self
                                action:@selector(trackOptions:)
                      forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        case SCDetailNote: {
            UICollectionViewCell *cell =
                [collection dequeueReusableCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class)
                                                      forIndexPath:path];
            UIListContentConfiguration *content = [UIListContentConfiguration subtitleCellConfiguration];
            content.text = self.note;
            content.textProperties.color = SCMusicColor(SCColorSecondaryText);
            content.textProperties.font = SCMusicFont(14, UIFontWeightRegular);
            content.textProperties.numberOfLines = 0;
            content.directionalLayoutMargins = NSDirectionalEdgeInsetsZero;
            if ([self isArtist]) {
                content.image = [UIImage imageNamed:item.artworkName];
                content.imageProperties.maximumSize = CGSizeMake(70, 70);
                content.imageProperties.cornerRadius = SCMusicArtworkRadius;
            }
            cell.contentConfiguration = content;
            return cell;
        }
        default: {
            SCMusicItemCell *cell =
                [collection dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SCMusicItemCell.class)
                                                      forIndexPath:path];
            NSString *detail = @"Artist";
            if ([(NSObject *)item isKindOfClass:SCAlbum.class]) {
                SCAlbum *album = (id)item;
                detail = album.releaseYear
                             ? [NSString stringWithFormat:@"%@ · %ld", album.releaseType, (long)album.releaseYear]
                             : album.releaseType;
            }
            [cell showItem:item detail:detail grid:section.kind == SCDetailShelf];
            cell.moreAction = self.moreAction;
            return cell;
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collection
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)path {
    SCHomeSectionHeaderView *header = [collection dequeueReusableSupplementaryViewOfKind:kind
                                                                     withReuseIdentifier:@"heading"
                                                                            forIndexPath:path];
    [header configureTitle:self.sections[path.section].heading];
    return header;
}

- (void)collectionView:(UICollectionView *)collection didSelectItemAtIndexPath:(NSIndexPath *)path {
    SCDetailSection *section = self.sections[path.section];
    [collection deselectItemAtIndexPath:path animated:NO];
    if ((section.kind == SCDetailShelf || section.kind == SCDetailReleases || section.kind == SCDetailTracks) &&
        self.selectItem)
        self.selectItem(section.items[path.item], path.item);
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    if (scroll != self.collection)
        return;
    CGFloat heroHeight = [self.collection.collectionViewLayout
                             layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]
                             .size.height;
    CGFloat travel = MIN(heroHeight - 40, scroll.contentSize.height - scroll.bounds.size.height);
    self.navTitle.alpha =
        travel > 0 ? MAX(0, MIN(1, (scroll.contentOffset.y - travel * 0.45) / MAX(1, travel * 0.55))) : 0;
}

#pragma mark - Private Methods

- (BOOL)isArtist {
    return [(NSObject *)self.item isKindOfClass:SCArtist.class];
}

- (void)renderTrack:(SCNumberedTrackCell *)cell path:(NSIndexPath *)path {
    SCTrack *track = (id)self.sections[path.section].items[path.item];
    [cell showTrack:track
             number:path.item + 1
            artwork:[self isArtist]
            current:[track.identifier isEqual:self.snapshot.track.identifier]
            playing:self.snapshot.playing];
}

- (void)renderControls:(SCReleaseControlsCell *)cell {
    [cell renderArtist:[self isArtist]
                 saved:self.saved
               playing:self.playingSource
               shuffle:self.snapshot.mode == SCPlaybackModeShuffle
               enabled:self.hasTracks];
}

- (void)trackOptions:(UIButton *)button {
    CGPoint center = [button convertPoint:CGPointMake(CGRectGetMidX(button.bounds), CGRectGetMidY(button.bounds))
                                   toView:self.collection];
    NSIndexPath *path = [self.collection indexPathForItemAtPoint:center];
    if (path && self.moreAction)
        self.moreAction(self.sections[path.section].items[path.item]);
}

@end
