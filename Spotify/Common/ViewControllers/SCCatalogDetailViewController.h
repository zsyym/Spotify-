#import "SCCatalogDetailView.h"

@interface SCCatalogDetailViewController : UIViewController
- (instancetype)initWithItem:(id<SCMusicItem>)item tracks:(NSArray<SCTrack *> *)tracks;
@end
