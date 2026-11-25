#import "SCAlbum.h"
@interface SCAlbumDetailModel : NSObject
@property (nonatomic, strong, readonly) SCAlbum *album;
@property (nonatomic, copy, readonly) NSString *releaseInfo;
@property (nonatomic, copy, readonly) NSString *summary;
- (instancetype)initWithAlbum:(SCAlbum *)album;
@end
