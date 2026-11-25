#import <UIKit/UIKit.h>
#import "SCPlaybackSnapshot.h"

@interface SCPlayerControlsView : UIView
@property (nonatomic, strong, readonly) UIButton *shuffleButton;
@property (nonatomic, strong, readonly) UIButton *previousButton;
@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UIButton *nextButton;
@property (nonatomic, strong, readonly) UIButton *repeatButton;
- (void)render:(SCPlaybackSnapshot *)state;
@end
