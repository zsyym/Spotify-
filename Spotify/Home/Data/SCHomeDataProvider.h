#import "SCHomeSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SCHomeSectionsCompletion)(NSArray<SCHomeSectionModel *> *sections, NSError *_Nullable error);
@protocol SCHomeDataProviding <NSObject>

- (void)loadSectionsWithCompletion:(SCHomeSectionsCompletion)completion;

@end
@interface SCHomeDataProvider : NSObject <SCHomeDataProviding>

@end

NS_ASSUME_NONNULL_END
