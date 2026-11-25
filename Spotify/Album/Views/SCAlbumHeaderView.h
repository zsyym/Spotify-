#import "SCMusicStyle.h"
#import "SCAlbumDetailModel.h"
@interface SCAlbumHeaderView : UICollectionViewCell
@property (nonatomic, strong, readonly) UIButton *artistButton;
- (void)showAlbum:(SCAlbumDetailModel *)model;
@end
