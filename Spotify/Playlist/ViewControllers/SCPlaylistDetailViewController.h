#import <UIKit/UIKit.h>
#import "SCPlaylist.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCPlaylistDetailViewController : UIViewController

- (instancetype)initWithPlaylist:(SCPlaylist *)playlist;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, copy, nullable) void (^trackSelectionHandler)(SCTrack *track);

@end

NS_ASSUME_NONNULL_END
