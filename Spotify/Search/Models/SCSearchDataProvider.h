#import "SCSearchResultModel.h"

@protocol SCSearchDataProviding <NSObject>
// Deliver results on the main thread. The controller discards superseded requests.
- (void)search:(NSString *)query
      category:(NSString *)category
        filter:(NSString *)filter
    completion:(void (^)(SCSearchResultModel *result))completion;
@end
@interface SCSearchDataProvider : NSObject <SCSearchDataProviding>
@property (class, nonatomic, readonly) NSArray<NSString *> *categories;
@end
