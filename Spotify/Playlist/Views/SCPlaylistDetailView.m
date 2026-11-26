#import "SCPlaylistDetailView.h"
#import "SCPlaylistHeaderView.h"
#import "SCPlaylistTrackCell.h"
#import "SCMusicStyle.h"

@interface SCPlaylistDetailView ()

@property (nonatomic, strong) UIView *barBackground;
@property (nonatomic, strong) UILabel *navigationTitle;

@end

@implementation SCPlaylistDetailView

#pragma mark - Lifecycle

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateNavigationAppearance];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (![previousTraitCollection.preferredContentSizeCategory
            isEqualToString:self.traitCollection.preferredContentSizeCategory]) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

#pragma mark - Public Methods

- (void)showStatus:(NSString *)title actionable:(BOOL)actionable {
    [self.statusButton setTitle:title forState:UIControlStateNormal];
    self.statusButton.hidden = !title;
    self.statusButton.enabled = actionable;
    [self.statusButton mas_updateConstraints:^(MASConstraintMaker *make) { make.height.mas_equalTo(title ? 44 : 0); }];
}

- (void)setPlaylistTitle:(NSString *)title {
    self.navigationTitle.text = title;
}

- (void)updateNavigationAppearance {
    UICollectionView *collection = self.collectionView;
    SCPlaylistHeaderView *header = (SCPlaylistHeaderView *)[collection
        supplementaryViewForElementKind:UICollectionElementKindSectionHeader
                            atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    CGFloat progress = 0;
    if (collection.contentOffset.y > 0) {
        // Fade in as the scrolling title passes the bottom edge of the fixed bar.
        CGFloat remaining = header ? [header titleBottomInView:collection] - collection.contentOffset.y : 0;
        progress = MAX(0, MIN(1, 1 - remaining / 32.0));
    }
    self.barBackground.alpha = progress;
    self.navigationTitle.alpha = progress;
    self.navigationTitle.accessibilityElementsHidden = progress < 1;
}

#pragma mark - UI Setup

- (void)setupUI {
    CAGradientLayer *gradient = (CAGradientLayer *)self.layer;
    gradient.colors = @[ (id)SCMusicColor(0x30363B).CGColor, (id)SCMusicColor(SCColorBackground).CGColor ];
    gradient.locations = @[ @0, @0.58 ];
    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc]
        initWithSectionProvider:^NSCollectionLayoutSection *(NSInteger section,
                                                             id<NSCollectionLayoutEnvironment> environment) {
            CGFloat lines =
                SCMusicFont(16, UIFontWeightMedium).lineHeight + SCMusicFont(13, UIFontWeightRegular).lineHeight;
            NSCollectionLayoutDimension *width = [NSCollectionLayoutDimension fractionalWidthDimension:1];
            NSCollectionLayoutSize *size = [NSCollectionLayoutSize
                sizeWithWidthDimension:width
                       heightDimension:[NSCollectionLayoutDimension absoluteDimension:MAX(62, ceil(lines) + 22)]];
            NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:size];
            NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup verticalGroupWithLayoutSize:size
                                                                                         subitems:@[ item ]];
            NSCollectionLayoutSection *list = [NSCollectionLayoutSection sectionWithGroup:group];
            NSCollectionLayoutSize *headerSize =
                [NSCollectionLayoutSize sizeWithWidthDimension:width
                                               heightDimension:[NSCollectionLayoutDimension estimatedDimension:440]];
            list.boundarySupplementaryItems = @[ [NSCollectionLayoutBoundarySupplementaryItem
                boundarySupplementaryItemWithLayoutSize:headerSize
                                            elementKind:UICollectionElementKindSectionHeader
                                              alignment:NSRectAlignmentTop] ];
            return list;
        }];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    _collectionView.alwaysBounceVertical = YES;
    [_collectionView registerClass:SCPlaylistTrackCell.class
        forCellWithReuseIdentifier:NSStringFromClass(SCPlaylistTrackCell.class)];
    [_collectionView registerClass:SCPlaylistHeaderView.class
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:NSStringFromClass(SCPlaylistHeaderView.class)];
    [self addSubview:_collectionView];
    _statusButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _statusButton.tintColor = SCMusicColor(SCColorBrand);
    [_statusButton setTitleColor:SCMusicColor(SCColorSecondaryText) forState:UIControlStateDisabled];
    _statusButton.hidden = YES;
    [self addSubview:_statusButton];
    self.barBackground = [UIView new];
    self.barBackground.backgroundColor = SCMusicColor(SCColorSurface);
    self.barBackground.userInteractionEnabled = NO;
    self.barBackground.alpha = 0;
    [self addSubview:self.barBackground];
    self.navigationTitle = SCMusicLabel(17, UIFontWeightBold);
    self.navigationTitle.numberOfLines = 1;
    self.navigationTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationTitle.alpha = 0;
    self.navigationTitle.accessibilityTraits |= UIAccessibilityTraitHeader;
    [self addSubview:self.navigationTitle];
    _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backButton setImage:[UIImage systemImageNamed:@"chevron.backward"] forState:UIControlStateNormal];
    _backButton.tintColor = UIColor.whiteColor;
    _backButton.accessibilityLabel = @"Back";
    [self addSubview:_backButton];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(4);
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [self.navigationTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(56);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-56);
    }];
    [self.barBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self);
        make.bottom.equalTo(self.backButton);
    }];
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        make.height.mas_equalTo(0);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.bottom.equalTo(self.statusButton.mas_top);
    }];
}

@end
