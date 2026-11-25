#import <UIKit/UIKit.h>
#import "SCMusicItem.h"

@interface SCPlaylistCardView : UIView

- (void)configureWithItem:(id<SCMusicItem>)item showsSubtitle:(BOOL)showsSubtitle;

@end
