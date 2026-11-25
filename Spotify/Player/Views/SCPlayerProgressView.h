#import <UIKit/UIKit.h>
#import "SCPlaybackSnapshot.h"

@interface SCPlayerProgressView : UIView
@property (nonatomic, strong, readonly) UISlider *slider;
- (void)render:(SCPlaybackSnapshot *)state;
@end
