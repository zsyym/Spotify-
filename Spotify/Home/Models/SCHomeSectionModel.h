#import "SCMusicItem.h"

typedef NS_ENUM(NSInteger, SCHomeSectionKind) {
    SCHomeSectionKindShortcuts,
    SCHomeSectionKindPlaylists,
    SCHomeSectionKindAlbums,
    SCHomeSectionKindTracks
};
NS_ASSUME_NONNULL_BEGIN

@interface SCHomeSectionModel : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, assign, readonly) SCHomeSectionKind kind;
@property (nonatomic, copy, readonly) NSArray<id<SCMusicItem>> *items;

- (instancetype)initWithTitle:(NSString *)title kind:(SCHomeSectionKind)kind items:(NSArray<id<SCMusicItem>> *)items;

@end

NS_ASSUME_NONNULL_END
