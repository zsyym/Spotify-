#import "SCMusicStyle.h"
#import "SCTrack.h"
@interface SCNumberedTrackCell : UICollectionViewCell
- (void)showTrack:(SCTrack *)track
           number:(NSUInteger)number
          artwork:(BOOL)artwork
          current:(BOOL)current
          playing:(BOOL)playing;
@property (nonatomic, strong, readonly) UIButton *moreButton;

@end
