#import "SCWelcomeView.h"
#import "SCAuthStyle.h"

@interface SCWelcomeView ()

@property (nonatomic, strong) UIStackView *brandStack;

@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subtitle;
@property (nonatomic, strong) UIStackView *actions;

@end

@implementation SCWelcomeView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - Public Methods

- (void)animateEntrance {
    if (UIAccessibilityIsReduceMotionEnabled())
        return;
    self.brandStack.alpha = 0;
    [UIView animateWithDuration:0.45
                     animations:^{
                         self.brandStack.alpha = 1;
                     }];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCAuthColor(SCColorBackground);
    self.scroll = [UIScrollView new];
    self.scroll.alwaysBounceVertical = NO;
    self.scroll.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scroll];
    self.content = [UIView new];
    [self.scroll addSubview:self.content];
    self.logo = SCAuthLogo();
    self.title = SCAuthLabel(@"Millions of songs.", 36, UIFontWeightBold);
    self.subtitle = SCAuthLabel(@"Free on Spotify.", 32, UIFontWeightBold);
    self.title.textAlignment = self.subtitle.textAlignment = NSTextAlignmentCenter;
    self.title.accessibilityTraits = self.subtitle.accessibilityTraits = UIAccessibilityTraitHeader;
    _brandStack = [[UIStackView alloc] initWithArrangedSubviews:@[ self.logo, self.title, self.subtitle ]];
    _brandStack.axis = UILayoutConstraintAxisVertical;
    _brandStack.alignment = UIStackViewAlignmentCenter;
    _brandStack.spacing = 4;
    [_brandStack setCustomSpacing:40 afterView:self.logo];
    [self.content addSubview:_brandStack];
    _signUpButton = SCAuthButton(@"Sign up free", YES);
    _loginButton = SCAuthButton(@"Log in", NO);
    UILabel *disclaimer = SCAuthLabel(@"Personal UI study · Not affiliated with Spotify", 12, UIFontWeightRegular);
    disclaimer.textColor = SCAuthColor(0xB3B3B3);
    disclaimer.textAlignment = NSTextAlignmentCenter;
    self.actions = [[UIStackView alloc] initWithArrangedSubviews:@[ _signUpButton, _loginButton, disclaimer ]];
    self.actions.axis = UILayoutConstraintAxisVertical;
    self.actions.spacing = 12;
    [self.actions setCustomSpacing:24 afterView:_loginButton];
    [self.content addSubview:self.actions];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
    }];
    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(SCAuthGuideAttribute(self.scroll.contentLayoutGuide, NSLayoutAttributeLeading));
        make.trailing.equalTo(SCAuthGuideAttribute(self.scroll.contentLayoutGuide, NSLayoutAttributeTrailing));
        make.top.equalTo(SCAuthGuideAttribute(self.scroll.contentLayoutGuide, NSLayoutAttributeTop));
        make.bottom.equalTo(SCAuthGuideAttribute(self.scroll.contentLayoutGuide, NSLayoutAttributeBottom));
        make.width.equalTo(SCAuthGuideAttribute(self.scroll.frameLayoutGuide, NSLayoutAttributeWidth));
        make.height.greaterThanOrEqualTo(SCAuthGuideAttribute(self.scroll.frameLayoutGuide, NSLayoutAttributeHeight));
        make.height.equalTo(SCAuthGuideAttribute(self.scroll.frameLayoutGuide, NSLayoutAttributeHeight)).priority(249);
    }];
    [self.logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(184);
        make.height.mas_equalTo(56);
    }];
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.brandStack);
    }];
    [self.subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.brandStack);
    }];
    [self.actions mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.content);
        make.width.equalTo(self.content).offset(-48).priorityHigh();
        make.width.lessThanOrEqualTo(@440);
        make.bottom.equalTo(self.content).offset(-20);
    }];
    [_brandStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.content);
        make.width.equalTo(self.actions);
        make.top.greaterThanOrEqualTo(self.content).offset(60);
        make.centerY.equalTo(self.content).multipliedBy(0.75).priorityLow();
        make.bottom.lessThanOrEqualTo(self.actions.mas_top).offset(-64);
    }];
    [self.signUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@56);
    }];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@56);
    }];
}

@end
