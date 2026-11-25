#import <UIKit/UIKit.h>
#import "SCTrack.h"

@interface SCPlaylistTrackCell : UICollectionViewCell

@property (nonatomic, copy) void (^moreAction)(SCTrack *track);

- (void)configureWithTrack:(SCTrack *)track;

@end
