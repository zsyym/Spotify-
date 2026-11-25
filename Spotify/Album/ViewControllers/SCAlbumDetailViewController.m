#import "SCAlbumDetailViewController.h"
#import "SCAlbumDetailView.h"
#import "SCMusicNavigation.h"
@interface SCAlbumDetailViewController ()
@property (nonatomic, strong) SCAlbumDetailModel *model;
@end
@implementation SCAlbumDetailViewController

#pragma mark - Lifecycle

- (instancetype)initWithAlbum:(SCAlbum *)item {
    SCAlbumDetailModel *model = [[SCAlbumDetailModel alloc] initWithAlbum:item];
    if ((self = [super initWithItem:item tracks:item.tracks]))
        _model = model;
    return self;
}

- (void)loadView {
    SCAlbumDetailView *page = [SCAlbumDetailView new];
    [page showModel:self.model];
    __weak typeof(self) weakSelf = self;
    page.openArtist = ^{
        [SCMusicNavigation openItem:weakSelf.model.album.artist from:weakSelf];
    };
    self.view = page;
}

@end
