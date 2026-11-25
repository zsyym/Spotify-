#import "SCProfileAvatar.h"
#import "SCHomeHeaderView.h"
#import "SCMusicStyle.h"

@interface SCHomeHeaderView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *filterStack;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) NSArray<UIButton *> *filterButtons;
@property (nonatomic, copy, readwrite) NSString *selectedFilter;

@end

@implementation SCHomeHeaderView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCMusicColor(SCColorBackground);
    self.selectedFilter = @"All";
    self.scrollView = [UIScrollView new];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    self.avatarButton = [SCProfileAvatarButton new];
    self.avatarButton.accessibilityLabel = @"Open sidebar";
    [self.avatarButton addTarget:self action:@selector(showProfile) forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray *buttons = [NSMutableArray new];
    for (NSString *title in @[ @"All", @"Music", @"Podcasts" ]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
        configuration.title = title;
        configuration.contentInsets = NSDirectionalEdgeInsetsMake(10, 16, 10, 16);
        configuration.cornerStyle = UIButtonConfigurationCornerStyleCapsule;
        button.configuration = configuration;
        button.titleLabel.adjustsFontForContentSizeCategory = YES;
        button.configurationUpdateHandler = ^(UIButton *sender) {
            UIButtonConfiguration *config = sender.configuration;
            config.background.backgroundColor = SCMusicColor(sender.selected ? SCColorBrand : SCColorCard);
            config.baseForegroundColor = sender.selected ? UIColor.blackColor : UIColor.whiteColor;
            config.titleTextAttributesTransformer = ^NSDictionary *(NSDictionary *incoming) {
                NSMutableDictionary *attributes = incoming.mutableCopy;
                attributes[NSFontAttributeName] = SCMusicFont(14, UIFontWeightMedium);
                return attributes;
            };
            sender.configuration = config;
            sender.accessibilityTraits =
                UIAccessibilityTraitButton | (sender.selected ? UIAccessibilityTraitSelected : 0);
        };
        button.selected = [title isEqualToString:@"All"];
        [button addTarget:self action:@selector(selectFilter:) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:button];
    }
    self.filterButtons = buttons;
    NSMutableArray *arranged = [NSMutableArray arrayWithObject:self.avatarButton];
    [arranged addObjectsFromArray:buttons];
    self.filterStack = [[UIStackView alloc] initWithArrangedSubviews:arranged];
    self.filterStack.alignment = UIStackViewAlignmentCenter;
    self.filterStack.spacing = 8;
    [self.filterStack setCustomSpacing:12 afterView:self.avatarButton];
    [self.scrollView addSubview:self.filterStack];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(6, 16, 6, 16));
    }];
    [self.filterStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
    }];
    [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
    }];
    for (UIButton *button in self.filterButtons)
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.greaterThanOrEqualTo(@44);
        }];
}

#pragma mark - Actions

- (void)selectFilter:(UIButton *)sender {
    for (UIButton *button in self.filterButtons)
        button.selected = button == sender;
    self.selectedFilter = sender.configuration.title;
}

- (void)showProfile {
    if (self.profileAction)
        self.profileAction();
}

@end
