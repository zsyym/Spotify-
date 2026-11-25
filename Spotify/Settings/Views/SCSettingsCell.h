#import "SCSettingsItem.h"
#import <UIKit/UIKit.h>
@interface SCSettingsCell : UITableViewCell
@property (nonatomic, copy) void (^valueChanged)(NSNumber *value);
- (void)showItem:(SCSettingsItem *)item value:(id)value selected:(BOOL)selected accountLink:(BOOL)accountLink;
@end
