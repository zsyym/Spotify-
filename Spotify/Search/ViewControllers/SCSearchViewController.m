#import "SCSearchViewController.h"
#import "SCSearchView.h"
#import "SCCategoryCell.h"
#import "SCSearchResultCell.h"
#import "SCSearchDataProvider.h"
#import "SCMusicNavigation.h"
#import "SCPlaybackManager.h"

@interface SCSearchViewController () <UICollectionViewDelegateFlowLayout,
                                      UICollectionViewDataSource,
                                      UITextFieldDelegate>
@property (nonatomic, strong) SCSearchView *page;
@property (nonatomic, strong) id<SCSearchDataProviding> provider;
@property (nonatomic, copy) NSArray<id<SCMusicItem>> *items;
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, assign) NSUInteger requestNumber;
@end
@implementation SCSearchViewController

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithDataProvider:[SCSearchDataProvider new]];
}

- (instancetype)initWithDataProvider:(id<SCSearchDataProviding>)provider {
    if ((self = [super initWithNibName:nil bundle:nil]))
        _provider = provider;
    return self;
}

- (void)loadView {
    self.page = [SCSearchView new];
    self.view = self.page;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filter = @"All";
    [self.page.collection registerClass:SCCategoryCell.class forCellWithReuseIdentifier:@"category"];
    [self.page.collection registerClass:SCSearchResultCell.class forCellWithReuseIdentifier:@"result"];
    self.page.collection.delegate = self;
    self.page.collection.dataSource = self;
    self.page.field.delegate = self;
    [self.page.field addTarget:self action:@selector(edited) forControlEvents:UIControlEventEditingChanged];
    [self.page.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    __weak typeof(self) weakSelf = self;
    self.page.filterAction = ^(NSString *filter) {
        weakSelf.filter = filter;
        [weakSelf refresh];
    };
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Actions

- (void)edited {
    self.category = nil;
    [self refresh];
}

- (void)cancel {
    self.category = nil;
    self.filter = @"All";
    self.page.field.text = @"";
    [self.page.field resignFirstResponder];
    [self refresh];
}

#pragma mark - Delegate / DataSource

- (BOOL)textFieldShouldReturn:(UITextField *)field {
    [field resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)field {
    self.page.cancelButton.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)field {
    self.page.cancelButton.hidden = [self browsing];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self browsing] ? SCSearchDataProvider.categories.count : self.items.count;
}

- (CGSize)collectionView:(UICollectionView *)view
                    layout:(UICollectionViewLayout *)layout
    sizeForItemAtIndexPath:(NSIndexPath *)path {
    CGFloat width = CGRectGetWidth(view.bounds);
    return [self browsing] ? CGSizeMake(floor((width - 10) / 2), 100) : CGSizeMake(width, 66);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)view cellForItemAtIndexPath:(NSIndexPath *)path {
    if ([self browsing]) {
        SCCategoryCell *cell = [view dequeueReusableCellWithReuseIdentifier:@"category" forIndexPath:path];
        [cell showCategory:SCSearchDataProvider.categories[path.item] atIndex:path.item];
        return cell;
    }
    SCSearchResultCell *cell = [view dequeueReusableCellWithReuseIdentifier:@"result" forIndexPath:path];
    id<SCMusicItem> item = self.items[path.item];
    [cell showItem:item detail:[SCMusicNavigation descriptionForItem:item] grid:NO];
    __weak typeof(self) weakSelf = self;
    cell.moreAction = ^(id<SCMusicItem> selected) {
        [SCMusicNavigation showOptionsFor:selected from:weakSelf];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)view didSelectItemAtIndexPath:(NSIndexPath *)path {
    [self.page.field resignFirstResponder];
    if ([self browsing]) {
        self.category = SCSearchDataProvider.categories[path.item];
        self.page.field.text = self.category;
        self.filter = @"All";
        [self refresh];
        return;
    }
    id<SCMusicItem> item = self.items[path.item];
    if ([(NSObject *)item isKindOfClass:SCTrack.class]) {
        NSMutableArray *queue = [NSMutableArray new];
        for (id candidate in self.items)
            if ([candidate isKindOfClass:SCTrack.class])
                [queue addObject:candidate];
        [SCPlaybackManager.sharedManager playQueue:queue
                                           atIndex:[queue indexOfObject:item]
                                            source:self.category ?: @"Search"];
    } else
        [SCMusicNavigation openItem:item from:self];
}

#pragma mark - Private Methods

- (BOOL)browsing {
    return self.category == nil &&
           ![self.page.field.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]
                .length;
}

- (void)refresh {
    BOOL browse = [self browsing];
    NSUInteger request = ++self.requestNumber;
    self.page.filterStrip.hidden = browse;
    self.page.cancelButton.hidden = browse && !self.page.field.isFirstResponder;
    self.page.sectionTitle.text = browse ? @"Browse All" : self.category ?: @"Search results";
    [self.page selectFilter:self.filter];
    if (browse) {
        self.items = @[];
        self.filter = @"All";
        self.page.emptyLabel.text = nil;
        [self reload];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.provider search:self.category ? @"" : self.page.field.text
                 category:self.category
                   filter:self.filter
               completion:^(SCSearchResultModel *result) {
                   if (weakSelf.requestNumber != request)
                       return;
                   weakSelf.items = result.items;
                   weakSelf.page.emptyLabel.text = result.items.count ? nil : @"No matching music";
                   [weakSelf reload];
               }];
}

- (void)reload {
    [self.page.collection.collectionViewLayout invalidateLayout];
    [self.page.collection reloadData];
    [self.page.collection setContentOffset:CGPointZero animated:NO];
}

@end
