#import <UIKit/UIKit.h>

@protocol SCSearchDataProviding;

@interface SCSearchViewController : UIViewController

- (instancetype)initWithDataProvider:(id<SCSearchDataProviding>)provider;

@end
