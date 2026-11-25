#import "SCLibraryOptionsViewController.h"

#import "SCMusicStyle.h"
@interface SCLibraryOptionsViewController ()
@property (nonatomic, copy) NSArray<NSString *> *options;
@property (nonatomic, copy) NSString *selectedOption;
@property (nonatomic, copy) void (^handler)(NSString *);
@end
@implementation SCLibraryOptionsViewController

#pragma mark - Lifecycle

- (instancetype)initWithTitle:(NSString *)title
                      options:(NSArray<NSString *> *)options
                     selected:(NSString *)selected
                      handler:(void (^)(NSString *))handler {
    if ((self = [super initWithStyle:UITableViewStyleInsetGrouped])) {
        self.title = title;
        _options = options.copy;
        _selectedOption = selected.copy;
        _handler = [handler copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = SCMusicColor(SCColorSurface);
    self.tableView.rowHeight = 54;
    self.tableView.tintColor = SCMusicColor(SCColorBrand);
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"option"];
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                                      target:self
                                                      action:@selector(close)];
    if (@available(iOS 26.0, *))
        self.navigationItem.rightBarButtonItem.hidesSharedBackground = YES;
}

#pragma mark - Actions

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Delegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"option" forIndexPath:path];
    NSString *option = self.options[path.row];
    BOOL selected = [self.selectedOption isEqual:option];
    UIListContentConfiguration *content = cell.defaultContentConfiguration;
    content.text = option;
    content.textProperties.color = selected ? SCMusicColor(SCColorBrand) : UIColor.whiteColor;
    cell.contentConfiguration = content;
    cell.backgroundColor = SCMusicColor(SCColorCard);
    cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    NSString *option = self.options[path.row];
    void (^handler)(NSString *) = self.handler;
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 handler(option);
                             }];
}

@end
