#import "SCHomeSectionModel.h"

@class SCPlaylist;

NS_ASSUME_NONNULL_BEGIN

typedef void (^SCHomeSectionsCompletion)(NSArray<SCHomeSectionModel *> *sections, NSError *_Nullable error);
@protocol SCHomeDataProviding <NSObject>

- (void)loadSectionsWithCompletion:(SCHomeSectionsCompletion)completion;

@optional
- (void)cancelLoading;

@end
@interface SCHomeDataProvider : NSObject <SCHomeDataProviding>

+ (NSArray<SCHomeSectionModel *> *)sectionsWithRecommendedPlaylists:(NSArray<SCPlaylist *> *)playlists;

@end

NS_ASSUME_NONNULL_END
