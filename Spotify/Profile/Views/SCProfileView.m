#import "SCProfileView.h"
#import "SCProfileHeader.h"
#import "SCProfileAvatar.h"
#import "SCMusicItemCell.h"
#import "SCHomeSectionHeaderView.h"
#import "SCPlayerStyle.h"
@interface SCProfileView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic, strong) UILabel *navName;
@property (nonatomic, strong) UIButton *back;
@property (nonatomic, strong) UIView *bar;
@property (nonatomic, copy) NSArray<NSArray *> *groups;
@end
@implementation SCProfileView
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)showPreview:(NSArray *)preview following:(NSArray *)following {
    self.groups = @[ @[], preview, @[], following ];
    self.navName.text = SCUser.current.nickname;
    [self.collection reloadData];
    [self.collection.collectionViewLayout invalidateLayout];
}

#pragma mark - UI Setup
- (void)setupUI {
    self.backgroundColor = SCMusicColor(SCColorBackground);
    __weak typeof(self) weakSelf = self;
    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc]
        initWithSectionProvider:^NSCollectionLayoutSection *(NSInteger index, id<NSCollectionLayoutEnvironment> env) {
            BOOL shelf = index == 1 && weakSelf.groups[index].count;
            CGFloat height = index == 0 ? 330 : (shelf ? 194 : 70);
            NSCollectionLayoutDimension *full = [NSCollectionLayoutDimension fractionalWidthDimension:1];
            NSCollectionLayoutSize *size = [NSCollectionLayoutSize
                sizeWithWidthDimension:shelf ? [NSCollectionLayoutDimension absoluteDimension:138] : full
                       heightDimension:[NSCollectionLayoutDimension absoluteDimension:height]];
            NSCollectionLayoutItem *item = [NSCollectionLayoutItem
                itemWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:full
                                                                  heightDimension:[NSCollectionLayoutDimension
                                                                                      fractionalHeightDimension:1]]];
            NSCollectionLayoutSection *section = [NSCollectionLayoutSection
                sectionWithGroup:[NSCollectionLayoutGroup horizontalGroupWithLayoutSize:size subitems:@[ item ]]];
            if (index) {
                section.contentInsets = NSDirectionalEdgeInsetsMake(0, 16, 12, 16);
                section.boundarySupplementaryItems = @[ [NSCollectionLayoutBoundarySupplementaryItem
                    boundarySupplementaryItemWithLayoutSize:[NSCollectionLayoutSize
                                                                sizeWithWidthDimension:full
                                                                       heightDimension:[NSCollectionLayoutDimension
                                                                                           absoluteDimension:50]]
                                                elementKind:UICollectionElementKindSectionHeader
                                                  alignment:NSRectAlignmentTop] ];
            }
            if (shelf) {
                section.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuous;
                section.interGroupSpacing = 12;
            }
            return section;
        }];
    self.collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collection.backgroundColor = UIColor.clearColor;
    self.collection.delegate = self;
    self.collection.dataSource = self;
    for (Class c in @[ SCProfileHeader.class, SCMusicItemCell.class, UICollectionViewCell.class ])
        [self.collection registerClass:c forCellWithReuseIdentifier:NSStringFromClass(c)];
    [self.collection registerClass:SCHomeSectionHeaderView.class
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:@"heading"];
    [self addSubview:self.collection];
    self.bar = [UIView new];
    self.bar.backgroundColor = SCMusicColor(0x514235);
    [self addSubview:self.bar];
    self.back = SCPlayerButton(@"chevron.backward", @"Back", 20);
    [self.bar addSubview:self.back];
    [self.back addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navName = SCMusicLabel(17, UIFontWeightSemibold);
    self.navName.numberOfLines = 1;
    self.navName.textAlignment = NSTextAlignmentCenter;
    self.navName.alpha = 0;
    [self.bar addSubview:self.navName];
}

#pragma mark - Constraints
- (void)setupConstraints {
    [self.bar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideTop).offset(48);
    }];
    [self.back mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bar.mas_safeAreaLayoutGuideLeft);
        make.bottom.equalTo(self.bar);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [self.navName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.back);
        make.left.equalTo(self.back.mas_right);
        make.right.equalTo(self.bar.mas_safeAreaLayoutGuideRight).offset(-48);
    }];
    [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bar.mas_bottom);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
    }];
}

#pragma mark - Actions
- (void)tapped:(UIButton *)button {
    if (self.action)
        self.action(button.tag, button);
}

#pragma mark - Delegate / DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)view {
    return self.groups.count;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return MAX(1, self.groups[section].count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)view cellForItemAtIndexPath:(NSIndexPath *)path {
    if (!path.section) {
        SCProfileHeader *header = [view dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SCProfileHeader.class)
                                                                  forIndexPath:path];
        [header showFollowingCount:self.groups[3].count];
        NSArray *buttons = @[ header.editButton, header.shareButton, header.moreButton ];
        for (NSUInteger i = 0; i < buttons.count; i++) {
            UIButton *button = buttons[i];
            button.tag = i + 1;
            [button addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        return header;
    }
    NSArray *items = self.groups[path.section];
    if (items.count) {
        SCMusicItemCell *cell = [view dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SCMusicItemCell.class)
                                                                forIndexPath:path];
        cell.moreAction = self.itemOptions;
        [cell showItem:items[path.item]
                detail:path.section == 1 ? @"Preview artist" : @"Following"
                  grid:path.section == 1];
        return cell;
    }
    UICollectionViewCell *cell =
        [view dequeueReusableCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class) forIndexPath:path];
    UIListContentConfiguration *content = [UIListContentConfiguration cellConfiguration];
    content.text = (@[
        @"",
        @"No preview artists available.",
        @"No public playlists yet.",
        @"Artists you follow will appear here."
    ])[path.section];
    content.textProperties.color = SCMusicColor(SCColorSecondaryText);
    content.textProperties.font = SCMusicFont(15, UIFontWeightRegular);
    cell.contentConfiguration = content;
    cell.backgroundColor = SCMusicColor(SCColorSurface);
    cell.layer.cornerRadius = 12;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)view
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)path {
    SCHomeSectionHeaderView *header = [view dequeueReusableSupplementaryViewOfKind:kind
                                                               withReuseIdentifier:@"heading"
                                                                      forIndexPath:path];
    [header configureTitle:(@[ @"", @"Recently played artists", @"Public playlists", @"Following" ])[path.section]];
    return header;
}

- (void)collectionView:(UICollectionView *)view didSelectItemAtIndexPath:(NSIndexPath *)path {
    NSArray *items = self.groups[path.section];
    if (items.count && self.openItem)
        self.openItem(items[path.item]);
}

- (void)scrollViewDidScroll:(UIScrollView *)view {
    CGFloat t = MIN(1, MAX(0, (view.contentOffset.y - 100) / 150));
    self.navName.alpha = t;
    self.bar.backgroundColor = [UIColor colorWithRed:(81 - 63 * t) / 255
                                               green:(66 - 48 * t) / 255
                                                blue:(53 - 35 * t) / 255
                                               alpha:1];
}
@end
