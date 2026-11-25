#import <UIKit/UIKit.h>
@interface SCLibraryOptionsViewController : UITableViewController
- (instancetype)initWithTitle:(NSString *)title
                      options:(NSArray<NSString *> *)options
                     selected:(NSString *)selected
                      handler:(void (^)(NSString *))handler;
@end
