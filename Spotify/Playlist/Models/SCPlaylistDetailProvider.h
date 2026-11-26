#import "SCNeteaseMusicService.h"
#import "SCPlaylist.h"

NS_ASSUME_NONNULL_BEGIN

/// Main-thread owner. Updated snapshots are delivered on the main queue.
@interface SCPlaylistDetailProvider : NSObject
@property (nonatomic, strong, readonly) SCPlaylist *playlist;
@property (nonatomic, copy, readonly) NSArray<SCTrack *> *tracks;
@property (nonatomic, readonly) BOOL loadingMetadata;
@property (nonatomic, readonly) BOOL loadingPage;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, strong, readonly, nullable) NSError *metadataError;
@property (nonatomic, strong, readonly, nullable) NSError *pageError;
@property (nonatomic, copy, nullable) void (^didChange)(void);

- (instancetype)initWithPlaylist:(SCPlaylist *)playlist service:(id<SCPlaylistDetailProviding>)service;
- (void)refresh;
- (void)retryMetadata;
- (void)loadNextPage;
- (void)cancel;
@end

NS_ASSUME_NONNULL_END
