#import <UIKit/UIKit.h>

@interface SCPlaylistDetailView : UIView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) UIButton *backButton;

@property (nonatomic, strong, readonly) UIButton *statusButton;
- (void)showStatus:(nullable NSString *)title actionable:(BOOL)actionable;
- (void)setPlaylistTitle:(NSString *)title;
- (void)updateNavigationAppearance;

@end
