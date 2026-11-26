#import "SCHomeDataProvider.h"

@protocol SCRecommendedPlaylistProviding;

NS_ASSUME_NONNULL_BEGIN

/// Call load and cancel on the main thread. Completion is asynchronous on the main queue.
/// Superseded or explicitly cancelled loads do not deliver a completion.
@interface SCRemoteHomeProvider : NSObject <SCHomeDataProviding>

- (instancetype)initWithService:(id<SCRecommendedPlaylistProviding>)service NS_DESIGNATED_INITIALIZER;
- (void)cancelLoading;

@end

NS_ASSUME_NONNULL_END
