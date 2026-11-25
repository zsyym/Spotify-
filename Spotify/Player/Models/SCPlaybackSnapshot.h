#import "SCTrack.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SCPlaybackMode) {
    SCPlaybackModeSequential,
    SCPlaybackModeShuffle,
    SCPlaybackModeRepeatAll,
    SCPlaybackModeRepeatOne
};

@interface SCPlaybackSnapshot : NSObject
@property (nonatomic, copy, readonly) NSArray<SCTrack *> *queue;
@property (nonatomic, assign, readonly) NSUInteger index;
@property (nonatomic, strong, readonly, nullable) SCTrack *track;
@property (nonatomic, copy, readonly) NSString *source;
@property (nonatomic, assign, readonly) BOOL playing;
@property (nonatomic, assign, readonly) NSTimeInterval progress;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) SCPlaybackMode mode;
@property (nonatomic, assign, readonly) BOOL favorite;
- (instancetype)initWithQueue:(NSArray<SCTrack *> *)queue
                        index:(NSUInteger)index
                       source:(NSString *)source
                      playing:(BOOL)playing
                     progress:(NSTimeInterval)progress
                         mode:(SCPlaybackMode)mode
                     favorite:(BOOL)favorite;
@end

NS_ASSUME_NONNULL_END
