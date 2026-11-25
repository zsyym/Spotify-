#import "SCMusicStyle.h"

@interface SCReleaseControlsCell : UICollectionViewCell
@property (nonatomic, strong, readonly) UIButton *save;
@property (nonatomic, strong, readonly) UIButton *download;
@property (nonatomic, strong, readonly) UIButton *more;
@property (nonatomic, strong, readonly) UIButton *shuffle;
@property (nonatomic, strong, readonly) UIButton *play;
- (void)renderArtist:(BOOL)artist saved:(BOOL)saved playing:(BOOL)playing shuffle:(BOOL)shuffle enabled:(BOOL)enabled;
@end
