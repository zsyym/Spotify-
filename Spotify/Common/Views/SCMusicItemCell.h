#import "SCLocalMusicCatalog.h"
#import <UIKit/UIKit.h>

@interface SCMusicItemCell : UICollectionViewCell
@property (nonatomic, copy) void (^moreAction)(id<SCMusicItem> item);
- (void)showItem:(id<SCMusicItem>)item detail:(NSString *)detail grid:(BOOL)grid;
@end
