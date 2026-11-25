#import "SCWelcomeViewController.h"
#import "SCLoginViewController.h"
#import "SCWelcomeView.h"
#import "SCRegisterViewController.h"

@interface SCWelcomeViewController ()

@property (nonatomic, strong) SCWelcomeView *welcomeView;
@property (nonatomic, assign) BOOL hasAnimated;

@end

@implementation SCWelcomeViewController

#pragma mark - Lifecycle

- (void)loadView {
    self.welcomeView = [SCWelcomeView new];
    self.view = self.welcomeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.welcomeView.loginButton addTarget:self
                                     action:@selector(openLogin)
                           forControlEvents:UIControlEventTouchUpInside];
    [self.welcomeView.signUpButton addTarget:self
                                      action:@selector(openRegistration)
                            forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.hasAnimated) {
        [self.welcomeView animateEntrance];
        self.hasAnimated = YES;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Actions

- (void)openLogin {
    [self.navigationController pushViewController:[SCLoginViewController new]
                                         animated:!UIAccessibilityIsReduceMotionEnabled()];
}

- (void)openRegistration {
    [self.navigationController pushViewController:[SCRegisterViewController new]
                                         animated:!UIAccessibilityIsReduceMotionEnabled()];
}

@end
