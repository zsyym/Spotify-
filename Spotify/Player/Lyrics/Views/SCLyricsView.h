#import "SCLyricsModel.h"
#import "SCPlayerProgressView.h"
@interface SCLyricsView : UIView
@property (nonatomic, strong, readonly) UIButton *back;
@property (nonatomic, strong, readonly) UIButton *play;
@property (nonatomic, strong, readonly) UIButton *share;
@property (nonatomic, strong, readonly) SCPlayerProgressView *progress;
@property (nonatomic, copy) void (^seekLine)(NSTimeInterval time);
- (void)beginTrack:(SCTrack *)track;
- (void)display:(SCLyricsModel *)model;
- (void)highlight:(NSInteger)index;
- (void)renderPlayback:(SCPlaybackSnapshot *)state;
@end
