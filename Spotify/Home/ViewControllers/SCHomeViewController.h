#import <UIKit/UIKit.h>
#import "SCHomeDataProvider.h"

@interface SCHomeViewController : UIViewController

- (instancetype)initWithDataProvider:(id<SCHomeDataProviding>)dataProvider;

@end
