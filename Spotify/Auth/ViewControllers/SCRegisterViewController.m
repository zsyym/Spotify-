#import "SCRegisterViewController.h"
#import "SCRegistrationFormModel.h"
#import "SCRegisterView.h"
#import "SCAuthTextFieldView.h"
#import "SCVerificationCodeInputView.h"

@interface SCRegisterViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) SCRegisterView *registerView;
@property (nonatomic, strong) SCRegistrationFormModel *form;

@end

@implementation SCRegisterViewController

#pragma mark - Lifecycle

- (void)loadView {
    self.registerView = [SCRegisterView new];
    self.view = self.registerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.form = [SCRegistrationFormModel new];
    self.navigationItem.title = @"Create account";
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.left"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(goBack)];
    if (@available(iOS 26.0, *)) {
        self.navigationItem.leftBarButtonItem.hidesSharedBackground = YES;
    }
    self.navigationItem.leftBarButtonItem.accessibilityLabel = @"Back";
    [self setupActions];
    [self updateButtonStates];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Actions

- (void)setupActions {
    self.registerView.emailField.textField.delegate = self;
    [self.registerView.emailField.textField addTarget:self
                                               action:@selector(emailChanged)
                                     forControlEvents:UIControlEventEditingChanged];
    [self.registerView.sendCodeButton addTarget:self
                                         action:@selector(openVerificationPreview)
                               forControlEvents:UIControlEventTouchUpInside];
    [self.registerView.codeInputView addTarget:self
                                        action:@selector(codeChanged)
                              forControlEvents:UIControlEventEditingChanged];
    [self.registerView.codeInputView addTarget:self
                                        action:@selector(revealInput)
                              forControlEvents:UIControlEventEditingDidBegin];
    [self.registerView.verifyButton addTarget:self
                                       action:@selector(verifyPreview)
                             forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChange:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:!UIAccessibilityIsReduceMotionEnabled()];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)emailChanged {
    BOOL changed = ![self.form.email isEqualToString:self.registerView.emailField.textField.text ?: @""];
    self.form.email = self.registerView.emailField.textField.text ?: @"";
    if (changed) {
        [self.registerView.codeInputView clearCode];
        [self.registerView setVerificationExpanded:NO email:@"" animated:YES];
    }
    [self.registerView showEmailError:nil];
    [self updateButtonStates];
}

- (void)openVerificationPreview {
    [self emailChanged];
    if (![self.form beginVerificationPreview]) {
        [self.registerView showEmailError:self.form.emailValidationMessage];
        return;
    }
    [self.view endEditing:YES];
    [self.registerView.codeInputView clearCode];
    [self.registerView setVerificationExpanded:YES email:self.form.email animated:YES];
    [self updateButtonStates];
}

- (void)codeChanged {
    self.form.verificationCode = self.registerView.codeInputView.code;
    [self updateButtonStates];
}

- (void)verifyPreview {
    [self emailChanged];
    [self codeChanged];
    if (!self.form.validCode)
        return;
    [self.view endEditing:YES];
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Verification is not available yet."
                                            message:@"This is a UI preview. No code has been sent or verified."
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)revealInput {
    [self.registerView revealFocusedInput];
}

#pragma mark - Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self openVerificationPreview];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self revealInput];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self emailChanged];
    [self.registerView showEmailError:self.form.email.length ? self.form.emailValidationMessage : nil];
    [self updateButtonStates];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    for (UIView *view = touch.view; view; view = view.superview) {
        if ([view isKindOfClass:UIControl.class])
            return NO;
    }
    return YES;
}

#pragma mark - Private Methods

- (void)updateButtonStates {
    [self.registerView setSendCodeEnabled:self.form.validEmail verifyEnabled:self.form.validCode];
}

- (void)keyboardDidChange:(NSNotification *)notification {
    [self revealInput];
}

@end
