#import <UIKit/UIKit.h>
@interface SCSettingsView : UIView
@property (nonatomic, strong, readonly) UIButton *back;
@property (nonatomic, strong, readonly) UITableView *table;
- (void)showTitle:(NSString *)title note:(NSString *)note;
@end
