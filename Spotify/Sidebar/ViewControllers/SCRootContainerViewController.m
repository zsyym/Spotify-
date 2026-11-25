#import "SCSettingsViewController.h"
#import "SCProfileViewController.h"
#import "SCRootContainerViewController.h"
#import "SCMainTabBarController.h"
#import "SCSidebarViewController.h"
#import "SCMusicStyle.h"

typedef NS_ENUM(NSInteger, SCDrawerState) { SCDrawerClosed, SCDrawerAnimating, SCDrawerOpen, SCDrawerDragging };

@interface SCRootContainerViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) SCMainTabBarController *tabs;
@property (nonatomic, strong) SCSidebarViewController *sidebar;
@property (nonatomic, strong) UIButton *scrim;
@property (nonatomic, assign) SCDrawerState state;
@end

@implementation SCRootContainerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabs = [SCMainTabBarController new];
    [self addChildViewController:self.tabs];
    [self.view addSubview:self.tabs.view];
    [self.tabs.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.tabs didMoveToParentViewController:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Public Methods

+ (void)openSidebarFrom:(UIViewController *)controller {
    for (UIViewController *parent = controller; parent; parent = parent.parentViewController) {
        if ([parent isKindOfClass:self]) {
            [(SCRootContainerViewController *)parent openSidebar];
            return;
        }
    }
}

- (void)openSidebar {
    if (self.state != SCDrawerClosed || self.presentedViewController)
        return;
    [self.view endEditing:YES];
    self.sidebar = [SCSidebarViewController new];
    [self addChildViewController:self.sidebar];
    self.scrim = [UIButton buttonWithType:UIButtonTypeCustom];
    self.scrim.accessibilityLabel = @"Close sidebar";
    self.scrim.backgroundColor = UIColor.blackColor;
    [self.scrim addTarget:self action:@selector(closeSidebar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scrim];
    [self.view addSubview:self.sidebar.view];
    [self.scrim mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.sidebar.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.84).priorityHigh();
        make.width.lessThanOrEqualTo(@380);
    }];
    [self.sidebar didMoveToParentViewController:self];
    __weak typeof(self) weakSelf = self;
    self.sidebar.selection = ^(SCSidebarDestination destination, NSString *title) {
        [weakSelf selectDestination:destination title:title];
    };
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.sidebar.view addGestureRecognizer:pan];
    self.tabs.view.accessibilityElementsHidden = YES;
    [self.view layoutIfNeeded];
    [self renderProgress:0];
    [self settleOpen:YES completion:nil];
}

#pragma mark - Actions

- (void)closeSidebar {
    if (self.state == SCDrawerOpen)
        [self settleOpen:NO completion:nil];
}

- (void)selectDestination:(SCSidebarDestination)destination title:(NSString *)title {
    if (self.state != SCDrawerOpen)
        return;
    [self settleOpen:NO
          completion:^{
              if (destination == SCSidebarProfile || destination == SCSidebarSettings) {
                  Class page =
                      destination == SCSidebarProfile ? SCProfileViewController.class : SCSettingsViewController.class;
                  UINavigationController *nav = (id)self.tabs.selectedViewController;
                  if (![nav.topViewController isKindOfClass:page])
                      [nav pushViewController:[page new] animated:YES];
                  return;
              }
              if (destination == SCSidebarAddAccount) {
                  [self dismissViewControllerAnimated:YES completion:nil];
                  return;
              }
              NSArray *messages = @[ @"", @"", @"No listening history yet.", @"No updates yet." ];
              UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                             message:messages[destination]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
              [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
              [self presentViewController:alert animated:YES completion:nil];
          }];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGFloat width = MAX(CGRectGetWidth(self.sidebar.view.bounds), 1);
    CGFloat translation = [pan translationInView:self.view].x;
    CGFloat progress = MIN(1, MAX(0, 1 + translation / width));
    if (pan.state == UIGestureRecognizerStateBegan)
        self.state = SCDrawerDragging;
    if (self.state != SCDrawerDragging)
        return;
    if (pan.state == UIGestureRecognizerStateChanged)
        [self renderProgress:progress];
    else if (pan.state == UIGestureRecognizerStateEnded) {
        CGFloat velocity = [pan velocityInView:self.view].x;
        [self settleOpen:velocity > 500 || (progress > 0.55 && velocity > -500) completion:nil];
    } else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed)
        [self settleOpen:YES completion:nil];
}

#pragma mark - Delegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gesture {
    CGPoint velocity = [gesture velocityInView:self.view];
    return self.state == SCDrawerOpen && velocity.x < -fabs(velocity.y);
}

#pragma mark - Private Methods

- (void)renderProgress:(CGFloat)progress {
    self.sidebar.view.transform =
        CGAffineTransformMakeTranslation((progress - 1) * CGRectGetWidth(self.sidebar.view.bounds), 0);
    self.scrim.alpha = 0.60 * progress;
}

- (void)settleOpen:(BOOL)open completion:(void (^)(void))completion {
    self.state = SCDrawerAnimating;
    self.tabs.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:UIAccessibilityIsReduceMotionEnabled() ? 0 : 0.25
        animations:^{
            [self renderProgress:open ? 1 : 0];
        }
        completion:^(BOOL finished) {
            self.state = open ? SCDrawerOpen : SCDrawerClosed;
            if (!open) {
                [self.sidebar willMoveToParentViewController:nil];
                [self.sidebar.view removeFromSuperview];
                [self.sidebar removeFromParentViewController];
                self.sidebar = nil;
                [self.scrim removeFromSuperview];
                self.scrim = nil;
                self.tabs.view.accessibilityElementsHidden = NO;
                self.tabs.view.userInteractionEnabled = YES;
            }
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
            if (completion)
                completion();
        }];
}
@end
