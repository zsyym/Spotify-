#import "SCLyricsModel.h"
@interface SCLyricsTimeline : NSObject
+ (NSInteger)indexInLines:(NSArray<SCLyricLine *> *)lines atTime:(NSTimeInterval)time;
@end
