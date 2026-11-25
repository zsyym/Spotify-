#import <UIKit/UIKit.h>
#import "SCReleaseControlsCell.h"
#import "SCNumberedTrackCell.h"
#import "SCLocalMusicCatalog.h"
#import "SCPlaybackSnapshot.h"

typedef NS_ENUM(NSInteger, SCDetailSectionKind) {
    SCDetailHero,
    SCDetailControls,
    SCDetailTracks,
    SCDetailReleases,
    SCDetailShelf,
    SCDetailNote
};
@interface SCDetailSection : NSObject
@property (nonatomic, assign, readonly) SCDetailSectionKind kind;
@property (nonatomic, copy, readonly) NSString *heading;
@property (nonatomic, copy, readonly) NSArray<id<SCMusicItem>> *items;
+ (instancetype)section:(SCDetailSectionKind)kind title:(NSString *)heading items:(NSArray<id<SCMusicItem>> *)items;
@end

@interface SCCatalogDetailView : UIView
@property (nonatomic, strong, readonly) UICollectionView *collection;
@property (nonatomic, strong, readonly) UIButton *back;
@property (nonatomic, copy) void (^selectItem)(id<SCMusicItem> item, NSUInteger index);
@property (nonatomic, copy) void (^moreAction)(id<SCMusicItem> item);
@property (nonatomic, copy) void (^controlsReady)(SCReleaseControlsCell *cell);
@property (nonatomic, copy) NSString *note;
- (void)displayItem:(id<SCMusicItem>)item sections:(NSArray<SCDetailSection *> *)sections;
- (void)refreshWithSnapshot:(SCPlaybackSnapshot *)snapshot
                      saved:(BOOL)saved
              playingSource:(BOOL)playingSource
                  hasTracks:(BOOL)hasTracks;
// Subclass hooks for the two distinct hero designs.
- (Class)heroClass;
- (void)configureHero:(UICollectionViewCell *)cell;
@end
