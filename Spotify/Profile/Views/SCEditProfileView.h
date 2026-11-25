#import <UIKit/UIKit.h>
@interface SCEditProfileView : UIView
@property (nonatomic, strong, readonly) UIButton *cancel;
@property (nonatomic, strong, readonly) UIButton *save;
@property (nonatomic, strong, readonly) UIButton *change;
@property (nonatomic, strong, readonly) UITextField *field;
@property (nonatomic, strong, readonly) UILabel *hint;
- (void)previewName:(NSString *)name photo:(UIImage *)photo;
@end
