#import "SCMusicItem.h"

@interface SCLibraryItemModel : NSObject
@property (nonatomic, strong) id<SCMusicItem> item;
@property (nonatomic, assign) NSTimeInterval added;
@property (nonatomic, assign) NSTimeInterval played;
@property (nonatomic, assign) BOOL downloaded;
@end
