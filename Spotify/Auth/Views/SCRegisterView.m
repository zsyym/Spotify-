#import "SCRegisterView.h"
#import "SCAuthTextFieldView.h"
#import "SCVerificationCodeInputView.h"
#import "SCAuthStyle.h"

@interface SCRegisterView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIStackView *emailStack;
@property (nonatomic, strong) UILabel *emailErrorLabel;
@property (nonatomic, strong) UIView *verificationContainer;
@property (nonatomic, strong) UIStackView *verificationStack;
@property (nonatomic, strong) UILabel *recipientLabel;
@property (nonatomic, assign) BOOL verificationExpanded;

@end

@implementation SCRegisterView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - Public Methods

- (void)setSendCodeEnabled:(BOOL)enabled verifyEnabled:(BOOL)verifyEnabled {
    self.sendCodeButton.enabled = enabled && !self.verificationExpanded;
    self.verifyButton.enabled = verifyEnabled && self.verificationExpanded;
}

- (void)showEmailError:(NSString *)message {
    self.emailErrorLabel.text = message;
    self.emailErrorLabel.hidden = !message.length;
    [self.emailField setInvalid:message.length > 0];
    if (message.length)
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
}

- (void)setVerificationExpanded:(BOOL)expanded email:(NSString *)email animated:(BOOL)animated {
    if (self.verificationExpanded == expanded)
        return;
    [self layoutIfNeeded];
    self.verificationExpanded = expanded;
    self.recipientLabel.text = expanded ? email : @"";
    self.verificationContainer.accessibilityElementsHidden = !expanded;
    UIButtonConfiguration *configuration = self.sendCodeButton.configuration;
    configuration.title = expanded ? @"Code preview opened" : @"Send Code";
    self.sendCodeButton.configuration = configuration;
    self.verificationStack.hidden = NO;
    if (expanded)
        self.verificationStack.alpha = 0;
    [self setupVerificationConstraints];
    void (^updates)(void) = ^{
        self.verificationStack.alpha = expanded ? 1 : 0;
        [self layoutIfNeeded];
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        self.verificationStack.hidden = !self.verificationExpanded;
        if (expanded && self.verificationExpanded) {
            CGRect rect = [self.verificationContainer convertRect:self.verificationContainer.bounds
                                                           toView:self.scrollView];
            [self.scrollView scrollRectToVisible:rect animated:!UIAccessibilityIsReduceMotionEnabled()];
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.recipientLabel);
        }
    };
    if (animated && !UIAccessibilityIsReduceMotionEnabled()) {
        [UIView
            animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:updates
                     completion:completion];
    } else {
        updates();
        completion(YES);
    }
}

- (void)revealFocusedInput {
    UIView *input = self.emailField.textField.isFirstResponder      ? self.emailField
                    : self.codeInputView.textField.isFirstResponder ? self.codeInputView
                                                                    : nil;
    if (!input)
        return;
    [self layoutIfNeeded];
    CGRect rect = [input convertRect:input.bounds toView:self.scrollView];
    [self.scrollView scrollRectToVisible:CGRectInset(rect, 0, -16) animated:!UIAccessibilityIsReduceMotionEnabled()];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCAuthColor(SCColorBackground);
    self.scrollView = [UIScrollView new];
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.scrollView.alwaysBounceVertical = YES;
    [self addSubview:self.scrollView];
    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];
    UILabel *title = SCAuthLabel(@"What’s your email?", 28, UIFontWeightBold);
    title.accessibilityTraits = UIAccessibilityTraitHeader;
    _emailField = [[SCAuthTextFieldView alloc] initWithTitle:@"Email" password:NO];
    UITextField *email = self.emailField.textField;
    email.keyboardType = UIKeyboardTypeEmailAddress;
    email.textContentType = UITextContentTypeEmailAddress;
    email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    email.autocorrectionType = UITextAutocorrectionTypeNo;
    email.returnKeyType = UIReturnKeyGo;
    email.clearButtonMode = UITextFieldViewModeWhileEditing;
    email.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:@"name@example.com"
                                        attributes:@{NSForegroundColorAttributeName : SCAuthColor(0xB3B3B3)}];
    UILabel *description = SCAuthLabel(@"We’ll use your email to create your account.", 15, UIFontWeightRegular);
    description.textColor = SCAuthColor(0xB3B3B3);
    self.emailErrorLabel = SCAuthLabel(@"", 14, UIFontWeightRegular);
    self.emailErrorLabel.textColor = SCAuthColor(0xF15E6C);
    self.emailErrorLabel.hidden = YES;
    _sendCodeButton = SCAuthButton(@"Send Code", YES);
    self.sendCodeButton.enabled = NO;
    self.emailStack = [[UIStackView alloc]
        initWithArrangedSubviews:@[ title, _emailField, description, self.emailErrorLabel, _sendCodeButton ]];
    self.emailStack.axis = UILayoutConstraintAxisVertical;
    self.emailStack.spacing = 20;
    [self.emailStack setCustomSpacing:32 afterView:title];
    [self.emailStack setCustomSpacing:12 afterView:_emailField];
    [self.contentView addSubview:self.emailStack];
    self.verificationContainer = [UIView new];
    self.verificationContainer.clipsToBounds = YES;
    self.verificationContainer.accessibilityElementsHidden = YES;
    [self.contentView addSubview:self.verificationContainer];
    UILabel *codeTitle = SCAuthLabel(@"Enter verification code", 22, UIFontWeightBold);
    codeTitle.accessibilityTraits = UIAccessibilityTraitHeader;
    UILabel *codeDescription = SCAuthLabel(@"Enter the 6-digit code for:", 15, UIFontWeightRegular);
    codeDescription.textColor = SCAuthColor(0xB3B3B3);
    self.recipientLabel = SCAuthLabel(@"", 16, UIFontWeightSemibold);
    self.recipientLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _codeInputView = [SCVerificationCodeInputView new];
    UILabel *previewNote = SCAuthLabel(@"Verification UI preview — no code has been sent.", 14, UIFontWeightRegular);
    previewNote.textColor = SCAuthColor(0xB3B3B3);
    _verifyButton = SCAuthButton(@"Verify", YES);
    self.verifyButton.enabled = NO;
    self.verificationStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        codeTitle,
        codeDescription,
        self.recipientLabel,
        _codeInputView,
        previewNote,
        _verifyButton
    ]];
    self.verificationStack.axis = UILayoutConstraintAxisVertical;
    self.verificationStack.spacing = 20;
    [self.verificationStack setCustomSpacing:8 afterView:codeDescription];
    self.verificationStack.hidden = YES;
    [self.verificationContainer addSubview:self.verificationStack];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.bottom.equalTo(SCAuthGuideAttribute(self.keyboardLayoutGuide, NSLayoutAttributeTop));
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(SCAuthGuideAttribute(self.scrollView.contentLayoutGuide, NSLayoutAttributeLeading));
        make.trailing.equalTo(SCAuthGuideAttribute(self.scrollView.contentLayoutGuide, NSLayoutAttributeTrailing));
        make.top.equalTo(SCAuthGuideAttribute(self.scrollView.contentLayoutGuide, NSLayoutAttributeTop));
        make.bottom.equalTo(SCAuthGuideAttribute(self.scrollView.contentLayoutGuide, NSLayoutAttributeBottom));
        make.width.equalTo(SCAuthGuideAttribute(self.scrollView.frameLayoutGuide, NSLayoutAttributeWidth));
    }];
    [self.emailStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(self.contentView).offset(-48).priorityHigh();
        make.width.lessThanOrEqualTo(@440);
    }];
    for (UIButton *button in @[ self.sendCodeButton, self.verifyButton ]) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.greaterThanOrEqualTo(@56);
        }];
    }
    [self setupVerificationConstraints];
}

- (void)setupVerificationConstraints {
    // Collapse to zero height; the inner stack has no bottom attachment while collapsed.
    [self.verificationContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.emailStack);
        make.top.equalTo(self.emailStack.mas_bottom).offset(self.verificationExpanded ? 32 : 0);
        make.bottom.equalTo(self.contentView).offset(-32);
        if (!self.verificationExpanded)
            make.height.mas_equalTo(0);
    }];
    [self.verificationStack mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.verificationContainer);
        if (self.verificationExpanded)
            make.bottom.equalTo(self.verificationContainer);
    }];
}

@end
