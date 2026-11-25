#import "SCSidebarViewController.h"
#import "SCSidebarItemCell.h"
#import "SCMusicStyle.h"

@interface SCSidebarViewController ()
@property (nonatomic, copy) NSArray<NSString *> *titles;
@property (nonatomic, copy) NSArray<NSString *> *symbols;
@end

@implementation SCSidebarViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[ @"Spotify Preview", @"Add account", @"Listening history", @"What’s new", @"Settings and privacy" ];
    self.symbols = @[ @"person.crop.circle.fill", @"person.badge.plus", @"clock", @"bell", @"gearshape" ];
    self.tableView.backgroundColor = SCMusicColor(SCColorSurface);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.accessibilityViewIsModal = YES;
    [self.tableView registerClass:SCSidebarItemCell.class forCellReuseIdentifier:@"row"];
}

#pragma mark - Delegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)path {
    return path.row == SCSidebarProfile ? 100 : 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)path {
    SCSidebarItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"row" forIndexPath:path];
    [cell showTitle:self.titles[path.row] symbol:self.symbols[path.row] profile:path.row == SCSidebarProfile];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    [tableView deselectRowAtIndexPath:path animated:NO];
    if (self.selection)
        self.selection(path.row, self.titles[path.row]);
}
@end
