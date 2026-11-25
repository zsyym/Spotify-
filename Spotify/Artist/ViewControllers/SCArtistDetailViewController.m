#import "SCArtistDetailViewController.h"
#import "SCArtistDetailView.h"
#import "SCMusicNavigation.h"
@interface SCArtistDetailViewController ()
@property (nonatomic, strong) SCArtistDetailModel *model;
@end
@implementation SCArtistDetailViewController

#pragma mark - Lifecycle

- (instancetype)initWithArtist:(SCArtist *)item {
    SCArtistDetailModel *model = [[SCArtistDetailModel alloc] initWithArtist:item
                                                                     catalog:SCLocalMusicCatalog.sharedCatalog];
    if ((self = [super initWithItem:item tracks:model.popular]))
        _model = model;
    return self;
}

- (void)loadView {
    SCArtistDetailView *page = [SCArtistDetailView new];
    [page showModel:self.model];

    self.view = page;
}

@end
