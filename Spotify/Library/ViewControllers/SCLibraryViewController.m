#import "SCRootContainerViewController.h"
#import "SCLibraryViewController.h"
#import "SCLibraryView.h"
#import "SCLibraryStore.h"
#import "SCLibraryItemCell.h"
#import "SCLibraryOptionsViewController.h"
#import "SCMusicNavigation.h"

@interface SCLibraryViewController () <UICollectionViewDelegateFlowLayout,
                                       UICollectionViewDataSource,
                                       UITextFieldDelegate>
@property (nonatomic, strong) SCLibraryView *page;
@property (nonatomic, copy) NSArray<SCLibraryItemModel *> *items;
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, assign) BOOL grid;
@end
@implementation SCLibraryViewController

#pragma mark - Lifecycle

- (void)loadView {
    self.page = [SCLibraryView new];
    self.view = self.page;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.page.avatar addTarget:self action:@selector(openSidebar) forControlEvents:UIControlEventTouchUpInside];
    self.sort = @"Recently Added";
    [self.page.collection registerClass:SCLibraryItemCell.class forCellWithReuseIdentifier:@"item"];
    self.page.collection.delegate = self;
    self.page.collection.dataSource = self;
    self.page.field.delegate = self;
    [self.page.field addTarget:self action:@selector(refresh) forControlEvents:UIControlEventEditingChanged];
    [self.page.cancelButton addTarget:self action:@selector(closeSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.page.searchButton addTarget:self action:@selector(toggleSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.page.addButton addTarget:self action:@selector(addItem) forControlEvents:UIControlEventTouchUpInside];
    [self.page.sortButton addTarget:self action:@selector(changeSort) forControlEvents:UIControlEventTouchUpInside];
    [self.page.layoutButton addTarget:self action:@selector(changeLayout) forControlEvents:UIControlEventTouchUpInside];
    __weak typeof(self) weakSelf = self;
    self.page.filterAction = ^(NSString *filter) {
        weakSelf.filter = [weakSelf.filter isEqual:filter] ? nil : filter;
        [weakSelf refresh];
    };
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(libraryChanged:)
                                                 name:SCLibraryDidChange
                                               object:SCLibraryStore.sharedStore];
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Actions

- (void)openSidebar {
    [SCRootContainerViewController openSidebarFrom:self];
}

- (void)libraryChanged:(NSNotification *)notification {
    if (notification.userInfo[@"savedIdentifier"] || [self.sort isEqual:@"Recently Played"])
        [self refresh];
}

- (void)closeSearch {
    self.page.field.text = @"";
    [self.page.field resignFirstResponder];
    self.page.searchRow.hidden = YES;
    [self refresh];
}

- (void)toggleSearch {
    if (self.page.searchRow.hidden) {
        self.page.searchRow.hidden = NO;
        [self.page.field becomeFirstResponder];
    } else
        [self closeSearch];
}

- (void)changeLayout {
    self.grid = !self.grid;
    [self.page.layoutButton setImage:[UIImage systemImageNamed:self.grid ? @"list.bullet" : @"square.grid.2x2"]
                            forState:UIControlStateNormal];
    self.page.layoutButton.accessibilityLabel = self.grid ? @"Show list" : @"Show grid";
    [self.page.collection.collectionViewLayout invalidateLayout];
    [self.page.collection reloadData];
}

- (void)changeSort {
    __weak typeof(self) weakSelf = self;
    [self showOptions:@"Sort by"
              options:@[ @"Recently Played", @"Recently Added", @"Alphabetical" ]
             selected:self.sort
              handler:^(NSString *option) {
                  weakSelf.sort = option;
                  [weakSelf refresh];
              }];
}

- (void)addItem {
    __weak typeof(self) weakSelf = self;
    [self showOptions:@"Add to your library"
              options:@[ @"Create playlist", @"Create folder" ]
             selected:nil
              handler:^(NSString *option) {
                  UIAlertController *alert =
                      [UIAlertController alertControllerWithTitle:option
                                                          message:@"Creation is not available in this local preview."
                                                   preferredStyle:UIAlertControllerStyleAlert];
                  [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
                  [weakSelf presentViewController:alert animated:YES completion:nil];
              }];
}

#pragma mark - Delegate / DataSource

- (BOOL)textFieldShouldReturn:(UITextField *)field {
    [field resignFirstResponder];
    return YES;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGSize)collectionView:(UICollectionView *)view
                    layout:(UICollectionViewLayout *)layout
    sizeForItemAtIndexPath:(NSIndexPath *)path {
    CGFloat width = CGRectGetWidth(view.bounds);
    CGFloat tile = floor((width - 10) / 2);
    return self.grid ? CGSizeMake(tile, tile + 56) : CGSizeMake(width, 66);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)view cellForItemAtIndexPath:(NSIndexPath *)path {
    SCLibraryItemCell *cell = [view dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:path];
    SCLibraryItemModel *row = self.items[path.item];
    NSString *detail = [SCMusicNavigation descriptionForItem:row.item];
    if (row.downloaded)
        detail = [detail stringByAppendingString:@" · Local"];
    [cell showItem:row.item detail:detail grid:self.grid];
    __weak typeof(self) weakSelf = self;
    cell.moreAction = ^(id<SCMusicItem> selected) {
        [SCMusicNavigation showOptionsFor:selected from:weakSelf];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)view didSelectItemAtIndexPath:(NSIndexPath *)path {
    [self.page.field resignFirstResponder];
    [SCMusicNavigation openItem:self.items[path.item].item from:self];
}

#pragma mark - Private Methods

- (void)refresh {
    self.items = [SCLibraryStore.sharedStore itemsForFilter:self.filter query:self.page.field.text sort:self.sort];
    [self.page selectFilter:self.filter];
    [self.page.sortButton setTitle:[@"  " stringByAppendingString:self.sort] forState:UIControlStateNormal];
    self.page.emptyLabel.text = self.items.count ? nil : @"No matching library items";
    [self.page.collection reloadData];
}

- (void)showOptions:(NSString *)title
            options:(NSArray *)options
           selected:(NSString *)selected
            handler:(void (^)(NSString *))handler {
    [self.page.field resignFirstResponder];
    SCLibraryOptionsViewController *sheet = [[SCLibraryOptionsViewController alloc] initWithTitle:title
                                                                                          options:options
                                                                                         selected:selected
                                                                                          handler:handler];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sheet];
    nav.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    nav.sheetPresentationController.detents =
        @[ [UISheetPresentationControllerDetent mediumDetent], [UISheetPresentationControllerDetent largeDetent] ];
    nav.sheetPresentationController.prefersGrabberVisible = YES;
    nav.sheetPresentationController.preferredCornerRadius = 20;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
