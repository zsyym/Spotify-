#import "SCLoginViewController.h"
#import "SCLoginView.h"
#import "SCAuthTextFieldView.h"
#import "SCAuthFormModel.h"
#import "SCRegisterViewController.h"
#if DEBUG
#import "SCRootContainerViewController.h"
#endif

@interface SCLoginViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) SCLoginView *loginView;
@property (nonatomic, strong) SCAuthFormModel *form;

@end

@implementation SCLoginViewController

#pragma mark - Lifecycle

- (void)loadView {
    self.loginView = [SCLoginView new];
    self.view = self.loginView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.form = [SCAuthFormModel new];
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.left"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(goBack)];
    if (@available(iOS 26.0, *)) {
        self.navigationItem.leftBarButtonItem.hidesSharedBackground = YES;
    }
    self.navigationItem.leftBarButtonItem.accessibilityLabel = @"Back to welcome";
    for (UITextField *field in @[ self.loginView.accountField.textField, self.loginView.passwordField.textField ]) {
        field.delegate = self;
        [field addTarget:self action:@selector(formChanged) forControlEvents:UIControlEventEditingChanged];
    }
    [self.loginView.loginButton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.forgotButton addTarget:self
                                    action:@selector(showUnavailable:)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.signUpButton addTarget:self
                                    action:@selector(openRegistration)
                          forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.loginView addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChange:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
#if DEBUG
    [self.loginView.developmentEntryButton addTarget:self
                                              action:@selector(openDevelopmentPreview)
                                    forControlEvents:UIControlEventTouchUpInside];
#endif
    [self formChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    // Do not retain credentials after leaving this UI-only form.
    self.form.password = @"";
    self.loginView.passwordField.textField.text = @"";
    [self formChanged];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Actions

#if DEBUG

- (void)openDevelopmentPreview {
    if (self.presentedViewController)
        return;
    SCRootContainerViewController *main = [SCRootContainerViewController new];
    main.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:main animated:YES completion:nil];
}
#endif

- (void)goBack {
    [self.navigationController popViewControllerAnimated:!UIAccessibilityIsReduceMotionEnabled()];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)formChanged {
    self.form.account = self.loginView.accountField.textField.text ?: @"";
    self.form.password = self.loginView.passwordField.textField.text ?: @"";
    [self.loginView setSubmitEnabled:self.form.canSubmit];
    [self.loginView.accountField setInvalid:NO];
    [self.loginView.passwordField setInvalid:NO];
    [self.loginView showMessage:nil error:NO];
}

- (void)submit {
    [self formChanged];
    if (!self.form.canSubmit) {
        BOOL accountMissing =
            ![self.form.account stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length;
        [self.loginView.accountField setInvalid:accountMissing];
        [self.loginView.passwordField setInvalid:!self.form.password.length];
        [self.loginView showMessage:self.form.validationMessage error:YES];
        return;
    }
    [self.view endEditing:YES];
    // No request is made, so do not simulate a loading delay or successful authentication.
    [self.loginView showMessage:@"You’re viewing a UI preview. Login is not connected; no credentials have been sent."
                          error:NO];
}

- (void)openRegistration {
    [self.navigationController pushViewController:[SCRegisterViewController new]
                                         animated:!UIAccessibilityIsReduceMotionEnabled()];
}

- (void)showUnavailable:(UIButton *)sender {
    NSString *title =
        sender == self.loginView.forgotButton ? @"Password reset is coming later" : @"Sign up is coming later";
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:title
                         message:@"功能开发中。This screen is a personal UI study, not an official Spotify service."
                  preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Delegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    for (UIView *view = touch.view; view; view = view.superview) {
        if ([view isKindOfClass:UIControl.class])
            return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.loginView.accountField.textField) {
        [self.loginView.passwordField.textField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self submit];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.loginView revealField:textField == self.loginView.accountField.textField ? self.loginView.accountField
                                                                                   : self.loginView.passwordField];
}

#pragma mark - Private Methods

- (void)keyboardDidChange:(NSNotification *)notification {
    if (self.loginView.accountField.textField.isFirstResponder)
        [self.loginView revealField:self.loginView.accountField];
    if (self.loginView.passwordField.textField.isFirstResponder)
        [self.loginView revealField:self.loginView.passwordField];
}

@end
