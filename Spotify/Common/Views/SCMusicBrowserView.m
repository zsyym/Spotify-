#import "SCMusicBrowserView.h"

@interface SCMusicBrowserView ()
@property (nonatomic, strong) UIView *fieldSurface;
@property (nonatomic, strong) UIImageView *searchIcon;
@property (nonatomic, strong) UIStackView *stack;
@property (nonatomic, strong) UIStackView *pills;

@end
@implementation SCMusicBrowserView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (UIButton *)iconButton:(NSString *)symbol label:(NSString *)label {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:[UIImage systemImageNamed:symbol] forState:UIControlStateNormal];
    button.tintColor = UIColor.whiteColor;
    button.accessibilityLabel = label;
    return button;
}

- (void)installFilters:(NSArray<NSString *> *)titles {
    for (NSString *title in titles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
        config.title = title;
        config.cornerStyle = UIButtonConfigurationCornerStyleCapsule;
        config.contentInsets = NSDirectionalEdgeInsetsMake(5, 14, 5, 14);
        button.configuration = config;
        button.configurationUpdateHandler = ^(UIButton *sender) {
            UIButtonConfiguration *style = sender.configuration;
            style.baseForegroundColor = sender.selected ? UIColor.blackColor : UIColor.whiteColor;
            style.background.backgroundColor = SCMusicColor(sender.selected ? SCColorBrand : SCColorCard);
            sender.configuration = style;
        };
        [button addTarget:self action:@selector(tapFilter:) forControlEvents:UIControlEventTouchUpInside];
        [self.pills addArrangedSubview:button];
    }
}

- (void)selectFilter:(NSString *)title {
    for (UIButton *button in self.pills.arrangedSubviews)
        button.selected = [button.configuration.title isEqual:title];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCMusicColor(SCColorBackground);
    self.tintColor = SCMusicColor(SCColorBrand);
    _heading = SCMusicLabel(29, UIFontWeightBold);
    _heading.numberOfLines = 1;
    _heading.adjustsFontSizeToFitWidth = YES;
    _heading.minimumScaleFactor = 0.7;
    _headingRow = [[UIStackView alloc] initWithArrangedSubviews:@[ _heading ]];
    _headingRow.alignment = UIStackViewAlignmentCenter;
    _headingRow.spacing = 6;
    _field = [UITextField new];
    _field.backgroundColor = SCMusicColor(SCColorCard);
    _field.layer.cornerRadius = SCMusicCardRadius;
    _field.textColor = UIColor.whiteColor;
    _field.font = SCMusicFont(15, UIFontWeightMedium);
    _field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _field.autocorrectionType = UITextAutocorrectionTypeNo;
    _field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _field.returnKeyType = UIReturnKeySearch;
    self.searchIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"magnifyingglass"]];
    self.searchIcon.tintColor = SCMusicColor(SCColorSecondaryText);
    self.searchIcon.contentMode = UIViewContentModeCenter;
    self.fieldSurface = [UIView new];
    [self.fieldSurface addSubview:_field];
    [self.fieldSurface addSubview:self.searchIcon];
    self.searchIcon.userInteractionEnabled = NO;
    self.fieldSurface.backgroundColor = SCMusicColor(SCColorCard);
    self.fieldSurface.layer.cornerRadius = SCMusicCardRadius;
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    _cancelButton.tintColor = UIColor.whiteColor;
    [_cancelButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIStackView *search = [[UIStackView alloc] initWithArrangedSubviews:@[ self.fieldSurface, _cancelButton ]];
    search.spacing = 8;
    _searchRow = search;
    _filterStrip = [UIScrollView new];
    _filterStrip.showsHorizontalScrollIndicator = NO;
    self.pills = [UIStackView new];
    self.pills.spacing = 6;
    [_filterStrip addSubview:self.pills];
    _sectionTitle = SCMusicLabel(19, UIFontWeightBold);
    _toolsRow = [[UIStackView alloc] initWithArrangedSubviews:@[ _sectionTitle ]];
    _toolsRow.alignment = UIStackViewAlignmentCenter;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 8;
    _collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collection.backgroundColor = UIColor.clearColor;
    _collection.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _collection.alwaysBounceVertical = YES;
    _emptyLabel = SCMusicLabel(16, UIFontWeightMedium);
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    _emptyLabel.textColor = SCMusicColor(SCColorSecondaryText);
    _collection.backgroundView = _emptyLabel;
    self.stack =
        [[UIStackView alloc] initWithArrangedSubviews:@[ _headingRow, search, _filterStrip, _toolsRow, _collection ]];
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.spacing = 12;
    [self addSubview:self.stack];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.centerY.equalTo(self.fieldSurface);
        make.width.mas_equalTo(40);
    }];
    [_field mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.searchIcon.mas_trailing);
        make.trailing.equalTo(self.fieldSurface).offset(-4);
        make.top.bottom.equalTo(self.fieldSurface);
    }];

    [self.stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(16);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-16);
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(8);
        make.bottom.lessThanOrEqualTo(self.mas_safeAreaLayoutGuideBottom);
        make.bottom.lessThanOrEqualTo([[MASViewAttribute alloc] initWithView:self
                                                                        item:self.keyboardLayoutGuide
                                                             layoutAttribute:NSLayoutAttributeTop]);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).priorityHigh();
    }];
    [self.headingRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
    }];
    [self.searchRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(46).priority(999);
    }];
    [self.filterStrip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(36).priority(999);
    }];
    [self.pills mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo([[MASViewAttribute alloc] initWithView:self.filterStrip
                                                               item:self.filterStrip.contentLayoutGuide
                                                    layoutAttribute:NSLayoutAttributeLeading]);
        make.trailing.equalTo([[MASViewAttribute alloc] initWithView:self.filterStrip
                                                                item:self.filterStrip.contentLayoutGuide
                                                     layoutAttribute:NSLayoutAttributeTrailing]);
        make.top.equalTo([[MASViewAttribute alloc] initWithView:self.filterStrip
                                                           item:self.filterStrip.contentLayoutGuide
                                                layoutAttribute:NSLayoutAttributeTop]);
        make.bottom.equalTo([[MASViewAttribute alloc] initWithView:self.filterStrip
                                                              item:self.filterStrip.contentLayoutGuide
                                                   layoutAttribute:NSLayoutAttributeBottom]);
        make.height.equalTo([[MASViewAttribute alloc] initWithView:self.filterStrip
                                                              item:self.filterStrip.frameLayoutGuide
                                                   layoutAttribute:NSLayoutAttributeHeight]);
    }];
}

#pragma mark - Actions

- (void)tapFilter:(UIButton *)sender {
    if (self.filterAction)
        self.filterAction(sender.configuration.title);
}

@end
