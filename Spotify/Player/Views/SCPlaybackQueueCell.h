#import <UIKit/UIKit.h>
#import "SCTrack.h"

@interface SCPlaybackQueueCell : UITableViewCell
@property (nonatomic, copy) void (^moreAction)(SCTrack *track);
- (void)configureWithTrack:(SCTrack *)track current:(BOOL)current;
@end
