#import "SCPlaybackSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const SCPlaybackDidChangeNotification;

FOUNDATION_EXPORT NSNotificationName const SCPlaybackProgressDidChange;

// Access on the main thread. Each change publishes one coherent snapshot.
@interface SCPlaybackManager : NSObject
@property (class, nonatomic, readonly) SCPlaybackManager *sharedManager;
@property (nonatomic, strong, readonly) SCPlaybackSnapshot *snapshot;
- (void)playQueue:(NSArray<SCTrack *> *)queue atIndex:(NSUInteger)index source:(NSString *)source;
@property (nonatomic, copy, readonly, nullable) NSString *sourceIdentifier;
- (void)playQueue:(NSArray<SCTrack *> *)queue
          atIndex:(NSUInteger)index
           source:(NSString *)source
       identifier:(nullable NSString *)identifier;
- (void)selectQueueIndex:(NSUInteger)index;
- (void)togglePlayback;
- (void)skipBy:(NSInteger)direction;
- (void)seekTo:(NSTimeInterval)seconds;
- (void)toggleShuffle;
- (void)cycleRepeatMode;
- (void)toggleFavorite;
@end

NS_ASSUME_NONNULL_END
