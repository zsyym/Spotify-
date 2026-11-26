#import <UIKit/UIKit.h>

@interface SCHomeSectionHeaderView : UICollectionReusableView

@property (nonatomic, copy) void (^retryAction)(void);
- (void)configureTitle:(NSString *)title;
- (void)configureTitle:(NSString *)title message:(NSString *)message allowsRetry:(BOOL)allowsRetry;

@end
