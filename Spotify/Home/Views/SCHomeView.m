#import "SCHomeView.h"
#import "SCHomeHeaderView.h"
#import "SCHomePlaylistCell.h"
#import "SCHomeShortcutCell.h"
#import "SCHomeSectionHeaderView.h"
#import "SCTrackCell.h"
#import "SCMusicStyle.h"

@interface SCHomeView ()

@property (nonatomic, copy) NSArray<SCHomeSectionModel *> *sections;

@end

@implementation SCHomeView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    _sections = @[];
    [self setupUI];
    [self setupConstraints];
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (![previousTraitCollection.preferredContentSizeCategory
            isEqualToString:self.traitCollection.preferredContentSizeCategory]) {
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self setupConstraintsForHeader];
    }
}

#pragma mark - Public Methods

- (void)showSections:(NSArray<SCHomeSectionModel *> *)sections {
    self.sections = [sections copy];
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCMusicColor(SCColorBackground);
    _headerView = [SCHomeHeaderView new];
    [self addSubview:_headerView];
    __weak typeof(self) weakSelf = self;
    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc]
        initWithSectionProvider:^NSCollectionLayoutSection *(NSInteger index,
                                                             id<NSCollectionLayoutEnvironment> environment) {
            return [weakSelf sectionLayoutAtIndex:index environment:environment];
        }];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView registerClass:SCHomeShortcutCell.class forCellWithReuseIdentifier:@"shortcut"];
    [_collectionView registerClass:SCHomePlaylistCell.class forCellWithReuseIdentifier:@"card"];
    [_collectionView registerClass:SCTrackCell.class forCellWithReuseIdentifier:@"track"];
    [_collectionView registerClass:SCHomeSectionHeaderView.class
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:@"title"];
    [self addSubview:_collectionView];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self setupConstraintsForHeader];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(8);
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
    }];
}

- (void)setupConstraintsForHeader {
    CGFloat height = MAX(60, ceil(SCMusicFont(14, UIFontWeightMedium).lineHeight) + 32);
    [self.headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(height);
    }];
}

- (NSCollectionLayoutSection *)sectionLayoutAtIndex:(NSInteger)index
                                        environment:(id<NSCollectionLayoutEnvironment>)environment {
    if (index >= (NSInteger)self.sections.count)
        return nil;
    SCHomeSectionKind kind = self.sections[index].kind;
    CGFloat availableWidth = environment.container.effectiveContentSize.width - 32;
    NSCollectionLayoutGroup *group;
    if (kind == SCHomeSectionKindShortcuts) {
        BOOL largeText =
            UIContentSizeCategoryIsAccessibilityCategory(self.traitCollection.preferredContentSizeCategory);
        NSInteger columns = availableWidth < 340 && largeText ? 1 : 2;
        CGFloat height = MAX(58, SCMusicFont(12, UIFontWeightBold).lineHeight * 2 + 16);
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem
            itemWithLayoutSize:[NSCollectionLayoutSize
                                   sizeWithWidthDimension:[NSCollectionLayoutDimension
                                                              fractionalWidthDimension:1.0 / columns]
                                          heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];
        group = [NSCollectionLayoutGroup
            horizontalGroupWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension
                                                                                             fractionalWidthDimension:1]
                                                                         heightDimension:[NSCollectionLayoutDimension
                                                                                             absoluteDimension:height]]
                                  subitem:item
                                    count:columns];
        group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:8];
    } else if (kind == SCHomeSectionKindTracks) {
        CGFloat height = MAX(72,
                             SCMusicFont(15, UIFontWeightSemibold).lineHeight * 2 +
                                 SCMusicFont(13, UIFontWeightRegular).lineHeight * 2 + 16);
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem
            itemWithLayoutSize:[NSCollectionLayoutSize
                                   sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                                          heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];
        group = [NSCollectionLayoutGroup
            verticalGroupWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension
                                                                                           fractionalWidthDimension:1]
                                                                       heightDimension:[NSCollectionLayoutDimension
                                                                                           absoluteDimension:height]]
                               subitems:@[ item ]];
    } else {
        CGFloat width = MIN(kind == SCHomeSectionKindAlbums ? 136 : 164, availableWidth * 0.62);
        CGFloat height =
            width + 14 + SCMusicFont(14, UIFontWeightBold).lineHeight * 2 +
            (kind == SCHomeSectionKindAlbums ? 0 : SCMusicFont(13, UIFontWeightRegular).lineHeight * 2 + 4);
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem
            itemWithLayoutSize:[NSCollectionLayoutSize
                                   sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                                          heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];
        group = [NSCollectionLayoutGroup
            horizontalGroupWithLayoutSize:[NSCollectionLayoutSize
                                              sizeWithWidthDimension:[NSCollectionLayoutDimension
                                                                         absoluteDimension:width]
                                                     heightDimension:[NSCollectionLayoutDimension
                                                                         absoluteDimension:ceil(height)]]
                                 subitems:@[ item ]];
    }
    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
    section.contentInsets = NSDirectionalEdgeInsetsMake(0, 16, 24, 16);
    section.interGroupSpacing = kind == SCHomeSectionKindTracks ? 0 : 12;
    if (kind == SCHomeSectionKindPlaylists || kind == SCHomeSectionKindAlbums)
        section.orthogonalScrollingBehavior =
            UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuousGroupLeadingBoundary;
    if (kind != SCHomeSectionKindShortcuts) {
        UIFont *headerFont = SCMusicFont(24, UIFontWeightBold);
        CGRect titleBounds = [self.sections[index].title boundingRectWithSize:CGSizeMake(availableWidth, CGFLOAT_MAX)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName : headerFont}
                                                                      context:nil];
        CGFloat headerHeight = ceil(MIN(titleBounds.size.height, headerFont.lineHeight * 2)) + 26;
        NSCollectionLayoutBoundarySupplementaryItem *header = [NSCollectionLayoutBoundarySupplementaryItem
            boundarySupplementaryItemWithLayoutSize:[NSCollectionLayoutSize
                                                        sizeWithWidthDimension:[NSCollectionLayoutDimension
                                                                                   fractionalWidthDimension:1]
                                                               heightDimension:[NSCollectionLayoutDimension
                                                                                   estimatedDimension:headerHeight]]
                                        elementKind:UICollectionElementKindSectionHeader
                                          alignment:NSRectAlignmentTop];
        section.boundarySupplementaryItems = @[ header ];
    }
    return section;
}

@end
