#import "SCProfileViewController.h"
#import "SCEditProfileViewController.h"
#import "SCProfileView.h"
#import "SCUser.h"
#import "SCLibraryStore.h"
@interface SCProfileViewController ()
@property (nonatomic, strong) SCProfileView *page;
@end
@implementation SCProfileViewController
#pragma mark - Lifecycle

- (void)loadView {
    self.page = [SCProfileView new];
    self.view = self.page;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    self.page.action = ^(SCProfileAction action, UIView *sender) {
        [weakSelf handle:action sender:sender];
    };
    self.page.itemOptions = ^(id<SCMusicItem> item) {
        [SCMusicNavigation showOptionsFor:item from:weakSelf];
    };
    self.page.openItem = ^(id<SCMusicItem> item) {
        [SCMusicNavigation openItem:item from:weakSelf];
    };
    for (NSString *name in @[ SCProfileDidChange, SCLibraryDidChange ])
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(refresh:) name:name object:nil];
    [self refresh:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Actions
- (void)refresh:(NSNotification *)notification {
    NSArray *artists = SCLocalMusicCatalog.sharedCatalog.artists;
    NSMutableArray *following = [NSMutableArray new];
    for (SCArtist *artist in artists)
        if ([SCLibraryStore.sharedStore containsID:artist.identifier])
            [following addObject:artist];
    [self.page showPreview:artists following:following];
}

- (void)handle:(SCProfileAction)action sender:(UIView *)sender {
    if (self.presentedViewController)
        return;
    if (action == SCProfileBack) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (action == SCProfileEdit) {
        SCEditProfileViewController *edit = [SCEditProfileViewController new];
        edit.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:edit animated:YES completion:nil];
        return;
    }
    if (action == SCProfileShare) {
        UIActivityViewController *share =
            [[UIActivityViewController alloc] initWithActivityItems:@[ SCUser.current.nickname ]
                                              applicationActivities:nil];
        share.popoverPresentationController.sourceView = sender;
        share.popoverPresentationController.sourceRect = sender.bounds;
        [self presentViewController:share animated:YES completion:nil];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Profile options"
                                                                   message:@"No additional actions in this preview."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
