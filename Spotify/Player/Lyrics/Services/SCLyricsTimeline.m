#import "SCLyricsTimeline.h"
@implementation SCLyricsTimeline
#pragma mark - Public Methods

+ (NSInteger)indexInLines:(NSArray<SCLyricLine *> *)lines atTime:(NSTimeInterval)time {
    NSInteger low = 0, high = lines.count;
    while (low < high) {
        NSInteger middle = low + (high - low) / 2;
        if (lines[middle].startTime <= time)
            low = middle + 1;
        else
            high = middle;
    }
    return low ? low - 1 : NSNotFound;
}
@end
