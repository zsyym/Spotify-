#import <UIKit/UIKit.h>
@interface SCProfileHeader : UICollectionViewCell
@property (nonatomic, strong, readonly) UIButton *editButton;
@property (nonatomic, strong, readonly) UIButton *shareButton;
@property (nonatomic, strong, readonly) UIButton *moreButton;
- (void)showFollowingCount:(NSUInteger)count;
@end
