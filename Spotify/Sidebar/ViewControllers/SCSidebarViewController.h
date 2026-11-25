#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCSidebarDestination) {
    SCSidebarProfile,
    SCSidebarAddAccount,
    SCSidebarHistory,
    SCSidebarNews,
    SCSidebarSettings
};
@interface SCSidebarViewController : UITableViewController
@property (nonatomic, copy) void (^selection)(SCSidebarDestination destination, NSString *title);
@end
