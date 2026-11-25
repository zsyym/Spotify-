#import "SCLyricsModel.h"
@interface SCLRCParser : NSObject
+ (SCLyricsModel *)parse:(NSString *)source translation:(NSString *)translation;
@end
