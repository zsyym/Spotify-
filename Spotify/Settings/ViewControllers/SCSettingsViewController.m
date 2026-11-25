#import "SCSettingsViewController.h"
#import "SCSettingsView.h"
#import "SCSettingsCell.h"
#import "SCSettingsPreviewState.h"
#import "SCStorageUsageView.h"
#import "SCEditProfileViewController.h"
#import "SCMusicStyle.h"

@interface SCSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) SCSettingsView *page;
@property (nonatomic, copy) NSArray<NSArray<SCSettingsItem *> *> *sections;
@end
@implementation SCSettingsViewController
#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithPage:@"Settings and privacy"];
}

- (instancetype)initWithPage:(NSString *)name {
    if ((self = [super initWithNibName:nil bundle:nil]))
        self.title = name;
    return self;
}

- (void)loadView {
    self.page = [SCSettingsView new];
    self.view = self.page;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.page showTitle:self.title note:[SCSettingsItem noteForPage:self.title]];
    [self.page.back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.page.table.delegate = self;
    self.page.table.dataSource = self;
    [self.page.table registerClass:SCSettingsCell.class forCellReuseIdentifier:@"setting"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    NSArray *items = [SCSettingsItem itemsForPage:self.title];
    if ([self.title isEqual:@"Settings and privacy"]) {
        self.sections = @[
            @[ items.firstObject ],
            [items subarrayWithRange:NSMakeRange(1, items.count - 2)],
            @[ items.lastObject ]
        ];
    } else
        self.sections = @[ items ];
    [self.page.table reloadData];
}

#pragma mark - Actions

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Delegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    SCSettingsItem *item = self.sections[path.section][path.row];
    if (item.kind == SCSettingUsage) {
        UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"storage"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"storage"];
            cell.backgroundColor = SCMusicColor(SCColorSurface);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            SCStorageUsageView *usage = [SCStorageUsageView new];
            [cell.contentView addSubview:usage];
            [usage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(cell.contentView);
            }];
        }
        return cell;
    }
    SCSettingsCell *cell = [table dequeueReusableCellWithIdentifier:@"setting" forIndexPath:path];
    SCSettingsPreviewState *state = SCSettingsPreviewState.shared;
    id value = [state valueForSetting:item.name];
    BOOL selected = item.kind == SCSettingChoice && [[state valueForSetting:self.title] isEqual:item.name];
    [cell showItem:item
              value:value
           selected:selected
        accountLink:item.kind == SCSettingProfile && ![self.title isEqual:@"Account"]];
    cell.valueChanged = ^(NSNumber *newValue) {
        [state setValue:newValue forSetting:item.name];
    };
    return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    [table deselectRowAtIndexPath:path animated:YES];
    if (self.presentedViewController || self.navigationController.topViewController != self ||
        self.navigationController.transitionCoordinator)
        return;
    SCSettingsItem *item = self.sections[path.section][path.row];
    if (item.kind == SCSettingChoice) {
        [SCSettingsPreviewState.shared setValue:item.name forSetting:self.title];
        [table reloadData];
        return;
    }
    NSString *destination = item.name;
    if (item.kind == SCSettingProfile && ![self.title isEqual:@"Account"])
        destination = @"Account";
    else if (item.kind != SCSettingLink)
        return;
    if ([destination isEqual:@"Edit profile"]) {
        SCEditProfileViewController *edit = [SCEditProfileViewController new];
        edit.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:edit animated:YES completion:nil];
        return;
    }
    [self.navigationController pushViewController:[[SCSettingsViewController alloc] initWithPage:destination]
                                         animated:YES];
}
@end
