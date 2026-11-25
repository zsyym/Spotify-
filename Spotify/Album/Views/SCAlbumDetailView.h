#import "SCCatalogDetailView.h"
#import "SCAlbumDetailModel.h"
@interface SCAlbumDetailView : SCCatalogDetailView
- (void)showModel:(SCAlbumDetailModel *)model;
@property (nonatomic, copy) void (^openArtist)(void);
@end
