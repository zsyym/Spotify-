#import "SCLocalMusicCatalog.h"

@interface SCSearchResultModel : NSObject
@property (nonatomic, copy, readonly) NSArray<id<SCMusicItem>> *items;
- (instancetype)initWithItems:(NSArray<id<SCMusicItem>> *)items;
@end
