#import <UIKit/UIKit.h>

@interface SCHomeHeaderView : UIView

@property (nonatomic, copy) void (^profileAction)(void);
@property (nonatomic, copy, readonly) NSString *selectedFilter;

@end
