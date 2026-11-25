#import <UIKit/UIKit.h>
#import "SCMusicItem.h"

@interface SCHomePlaylistCell : UICollectionViewCell

- (void)configureWithItem:(id<SCMusicItem>)item album:(BOOL)album;

@end
