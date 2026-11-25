#import "SCLoginView.h"
#import "SCAuthTextFieldView.h"
#import "SCAuthStyle.h"

@interface SCLoginView ()

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UIView *logoRow;
@property (nonatomic, strong) UIView *divider;
@property (nonatomic, strong) UIStackView *stack;

@end

@implementation SCLoginView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - Public Methods

- (void)setSubmitEnabled:(BOOL)enabled {
    self.loginButton.enabled = enabled;
}

- (void)setLoading:(BOOL)loading {
    UIButtonConfiguration *config = self.loginButton.configuration;
    config.showsActivityIndicator = loading;
    config.title = loading ? @"Checking…" : @"Log in";
    self.loginButton.configuration = config;
    self.loginButton.enabled = !loading;
    self.accountField.textField.enabled = self.passwordField.textField.enabled = !loading;
    self.loginButton.accessibilityLabel = loading ? @"Checking login form" : @"Log in";
}

- (void)showMessage:(NSString *)message error:(BOOL)error {
    self.messageLabel.text = message;
    self.messageLabel.textColor = SCAuthColor(error ? 0xF15E6C : 0xB3B3B3);
    self.messageLabel.hidden = !message.length;
    if (message.length)
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
}

- (void)revealField:(SCAuthTextFieldView *)field {
    [self layoutIfNeeded];
    CGRect rect = [field convertRect:field.bounds toView:self.scrollView];
    [self.scrollView scrollRectToVisible:CGRectInset(rect, 0, -16) animated:!UIAccessibilityIsReduceMotionEnabled()];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCAuthColor(SCColorBackground);
    _scrollView = [UIScrollView new];
    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    _scrollView.alwaysBounceVertical = YES;
    [self addSubview:_scrollView];
    self.content = [UIView new];
    [_scrollView addSubview:self.content];
    self.logo = SCAuthLogo();
    self.logoRow = [UIView new];
    [self.logoRow addSubview:self.logo];
    UILabel *title = SCAuthLabel(@"Log in to Spotify", 28, UIFontWeightBold);
    title.accessibilityTraits = UIAccessibilityTraitHeader;
    _accountField = [[SCAuthTextFieldView alloc] initWithTitle:@"Email or username" password:NO];
    _passwordField = [[SCAuthTextFieldView alloc] initWithTitle:@"Password" password:YES];
    _messageLabel = SCAuthLabel(@"", 14, UIFontWeightRegular);
    _messageLabel.hidden = YES;
    _loginButton = SCAuthButton(@"Log in", YES);
    _forgotButton = [self textButton:@"Forgot your password?"];
    self.divider = [UIView new];
    self.divider.backgroundColor = SCAuthColor(0x353535);
    UILabel *prompt = SCAuthLabel(@"Don’t have an account?", 15, UIFontWeightRegular);
    prompt.textColor = SCAuthColor(0xB3B3B3);
    prompt.textAlignment = NSTextAlignmentCenter;
    _signUpButton = SCAuthButton(@"Sign up", NO);
    self.stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.logoRow,
        title,
        _accountField,
        _passwordField,
        _messageLabel,
        _loginButton,
        _forgotButton,
        self.divider,
        prompt,
        _signUpButton
    ]];
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.spacing = 20;
    [self.stack setCustomSpacing:32 afterView:self.logoRow];
    [self.stack setCustomSpacing:32 afterView:title];
    [self.stack setCustomSpacing:28 afterView:_forgotButton];
    [self.stack setCustomSpacing:28 afterView:self.divider];
    [self.stack setCustomSpacing:12 afterView:prompt];
#if DEBUG
    _developmentEntryButton = [self textButton:@"Enter App (Dev Only)"];
    UIButtonConfiguration *developmentConfig = _developmentEntryButton.configuration;
    developmentConfig.baseForegroundColor = SCAuthColor(0xB3B3B3);
    _developmentEntryButton.configuration = developmentConfig;
    [self.stack addArrangedSubview:_developmentEntryButton];
    [self.stack setCustomSpacing:28 afterView:_signUpButton];
#endif
    [self.content addSubview:self.stack];
}

#pragma mark - Constraints

- (void)setupConstraints {
#if DEBUG
    [self.developmentEntryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@44);
    }];
#endif
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.bottom.equalTo(SCAuthGuideAttribute(self.keyboardLayoutGuide, NSLayoutAttributeTop));
    }];
    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(SCAuthGuideAttribute(self.scrollView.contentLayoutGuide, NSLayoutAttributeLeading));
        make.trailing.equalTo(SCAuthGuideAttribute(self.scrollView.contentLayoutGuide, NSLayoutAttributeTrailing));
        make.top.equalTo(SCAuthGuideAttribute(self.scrollView.contentLayoutGuide, NSLayoutAttributeTop));
        make.bottom.equalTo(SCAuthGuideAttribute(self.scrollView.contentLayoutGuide, NSLayoutAttributeBottom));
        make.width.equalTo(SCAuthGuideAttribute(self.scrollView.frameLayoutGuide, NSLayoutAttributeWidth));
    }];
    [self.logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.logoRow);
        make.width.mas_equalTo(132);
        make.height.mas_equalTo(40);
    }];
    [self.stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.content).offset(20);
        make.bottom.equalTo(self.content).offset(-32);
        make.centerX.equalTo(self.content);
        make.width.equalTo(self.content).offset(-48).priorityHigh();
        make.width.lessThanOrEqualTo(@440);
    }];
    [self.signUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@56);
    }];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@56);
    }];
    [self.forgotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@44);
    }];
    [self.divider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - Private Methods

- (UIButton *)textButton:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
    config.attributedTitle = [[NSAttributedString alloc]
        initWithString:title
            attributes:@{NSFontAttributeName : SCAuthFont(14, UIFontWeightSemibold, UIFontTextStyleBody)}];
    config.baseForegroundColor = UIColor.whiteColor;
    config.contentInsets = NSDirectionalEdgeInsetsMake(12, 0, 12, 0);
    button.configuration = config;
    button.titleLabel.adjustsFontForContentSizeCategory = YES;
    button.titleLabel.numberOfLines = 0;
    return button;
}

@end
