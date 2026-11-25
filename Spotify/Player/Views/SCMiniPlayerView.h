#import <UIKit/UIKit.h>
#import "SCPlaybackSnapshot.h"

@interface SCMiniPlayerView : UIView
@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UIButton *openButton;
- (void)render:(SCPlaybackSnapshot *)state;
@end
