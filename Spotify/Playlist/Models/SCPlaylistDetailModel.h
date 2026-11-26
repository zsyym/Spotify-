#import "SCPlaylist.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCPlaylistDetailModel : NSObject

@property (nonatomic, strong, readonly) SCPlaylist *playlist;
@property (nonatomic, copy, readonly) NSString *trackSummary;

@property (nonatomic, copy) NSArray<SCTrack *> *tracks;

- (instancetype)initWithPlaylist:(SCPlaylist *)playlist;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
