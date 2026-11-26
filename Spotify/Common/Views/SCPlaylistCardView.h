#import <UIKit/UIKit.h>
#import "SCMusicItem.h"

@interface SCPlaylistCardView : UIView

- (void)cancelArtworkLoad;
- (void)configureWithItem:(id<SCMusicItem>)item showsSubtitle:(BOOL)showsSubtitle;

@end
