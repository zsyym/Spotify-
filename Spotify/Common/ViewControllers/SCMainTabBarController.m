#import "SCMainTabBarController.h"
#import "SCHomeViewController.h"
#import "SCRemoteHomeProvider.h"
#import "SCSearchViewController.h"
#import "SCLibraryViewController.h"
#import "SCMusicStyle.h"

#import "SCMiniPlayerView.h"
#import "SCPlaybackManager.h"
#import "SCPlayerViewController.h"

@interface SCMainTabBarController ()
@property (nonatomic, strong) SCMiniPlayerView *miniPlayer;
@property (nonatomic, strong) SCPlayerViewController *playerController;
@end

@implementation SCMainTabBarController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    NSArray<UIViewController *> *roots = @[
        [[SCHomeViewController alloc] initWithDataProvider:[SCRemoteHomeProvider new]],
        [SCSearchViewController new],
        [SCLibraryViewController new]
    ];
    NSArray<NSString *> *titles = @[ @"Home", @"Search", @"Your Library" ];
    NSArray<NSString *> *symbols = @[ @"house", @"magnifyingglass", @"square.stack" ];
    NSArray<NSString *> *selectedSymbols = @[ @"house.fill", @"magnifyingglass", @"square.stack.fill" ];
    NSMutableArray *controllers = [NSMutableArray new];
    for (NSUInteger index = 0; index < roots.count; index++) {
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:roots[index]];
        navigation.navigationBarHidden = YES;
        navigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:titles[index]
                                                              image:[UIImage systemImageNamed:symbols[index]]
                                                      selectedImage:[UIImage systemImageNamed:selectedSymbols[index]]];
        [controllers addObject:navigation];
    }
    self.viewControllers = controllers;
    UITabBarAppearance *appearance = [UITabBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = SCMusicColor(SCColorBackground);
    appearance.shadowColor = SCMusicColor(SCColorCard);
    for (UITabBarItemAppearance *item in @[
             appearance.stackedLayoutAppearance,
             appearance.inlineLayoutAppearance,
             appearance.compactInlineLayoutAppearance
         ]) {
        item.normal.iconColor = SCMusicColor(SCColorSecondaryText);
        item.normal.titleTextAttributes = @{NSForegroundColorAttributeName : SCMusicColor(SCColorSecondaryText)};
        item.selected.iconColor = UIColor.whiteColor;
        item.selected.titleTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
    }
    self.tabBar.standardAppearance = appearance;
    self.tabBar.scrollEdgeAppearance = appearance;
    self.tabBar.tintColor = UIColor.whiteColor;
    self.tabBar.unselectedItemTintColor = SCMusicColor(SCColorSecondaryText);
    [self setupMiniPlayer];
}

#pragma mark - UI Setup

- (void)setupMiniPlayer {
    self.miniPlayer = [SCMiniPlayerView new];
    SCPlaybackManager *manager = SCPlaybackManager.sharedManager;
    [self.miniPlayer.openButton addTarget:self
                                   action:@selector(openPlayer)
                         forControlEvents:UIControlEventTouchUpInside];
    [self.miniPlayer.playButton addTarget:manager
                                   action:@selector(togglePlayback)
                         forControlEvents:UIControlEventTouchUpInside];
    if (@available(iOS 26.0, *)) {
        self.tabBarMinimizeBehavior = UITabBarMinimizeBehaviorNever;
    } else {
        [self.view addSubview:self.miniPlayer];
        [self.miniPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.tabBar.mas_top).offset(-4);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(8);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-8);
            make.height.mas_equalTo(56);
        }];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackChanged:)
                                                 name:SCPlaybackDidChangeNotification
                                               object:manager];
    [self updateMiniPlayer];
}

#pragma mark - Actions

- (void)openPlayer {
    if (self.presentedViewController || !SCPlaybackManager.sharedManager.snapshot.track)
        return;
    if (!self.playerController) {
        self.playerController = [SCPlayerViewController new];
        self.playerController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.playerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    [self presentViewController:self.playerController animated:!UIAccessibilityIsReduceMotionEnabled() completion:nil];
}

- (void)playbackChanged:(NSNotification *)notification {
    [self updateMiniPlayer];
}

#pragma mark - Private Methods

- (void)updateMiniPlayer {
    SCPlaybackSnapshot *state = SCPlaybackManager.sharedManager.snapshot;
    BOOL visible = state.track != nil;
    if (visible)
        [self.miniPlayer render:state];
    if (@available(iOS 26.0, *)) {
        if (visible != (self.bottomAccessory != nil)) {
            self.bottomAccessory = visible ? [[UITabAccessory alloc] initWithContentView:self.miniPlayer] : nil;
        }
    } else {
        self.miniPlayer.hidden = !visible;
        for (UIViewController *child in self.viewControllers) {
            UIEdgeInsets insets = child.additionalSafeAreaInsets;
            insets.bottom = visible ? 64 : 0;
            if (!UIEdgeInsetsEqualToEdgeInsets(child.additionalSafeAreaInsets, insets))
                child.additionalSafeAreaInsets = insets;
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
