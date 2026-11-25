#import <UIKit/UIKit.h>
#import "SCPlaybackSnapshot.h"
#import "SCPlayerProgressView.h"
#import "SCPlayerControlsView.h"

@interface SCPlayerView : UIView
@property (nonatomic, strong, readonly) UIButton *closeButton;
@property (nonatomic, strong, readonly) UIButton *favoriteButton;
@property (nonatomic, strong, readonly) UIButton *deviceButton;
@property (nonatomic, strong, readonly) UIButton *shareButton;
@property (nonatomic, strong, readonly) UIButton *moreButton;
@property (nonatomic, strong, readonly) UIButton *queueButton;
@property (nonatomic, strong, readonly) SCPlayerProgressView *progressView;
@property (nonatomic, strong, readonly) SCPlayerControlsView *controlsView;
- (void)render:(SCPlaybackSnapshot *)state;
@end
