#import "SCLibraryItemModel.h"
#import "SCLocalMusicCatalog.h"

FOUNDATION_EXPORT NSNotificationName const SCLibraryDidChange;
@interface SCLibraryStore : NSObject
@property (class, nonatomic, readonly) SCLibraryStore *sharedStore;
- (BOOL)containsID:(NSString *)identifier;
- (void)setSaved:(BOOL)saved identifier:(NSString *)identifier;
- (void)recordPlayedIDs:(NSArray<NSString *> *)identifiers;
- (NSArray<SCLibraryItemModel *> *)itemsForFilter:(NSString *)filter query:(NSString *)query sort:(NSString *)sort;
@end
