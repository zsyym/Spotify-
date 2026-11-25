#import <UIKit/UIKit.h>

@interface SCPlaylistDetailView : UIView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) UIButton *backButton;

- (void)setPlaylistTitle:(NSString *)title;
- (void)updateNavigationAppearance;

@end
