#import "SCLyricsModel.h"
#import "SCTrack.h"
@interface SCLyricsProvider : NSObject
+ (void)loadTrack:(SCTrack *)track completion:(void (^)(SCLyricsModel *model))completion;
@end
