#import "SCMusicStyle.h"

@interface SCMusicBrowserView : UIView
@property (nonatomic, strong, readonly) UITextField *field;
@property (nonatomic, strong, readonly) UIButton *cancelButton;
@property (nonatomic, strong, readonly) UIView *searchRow;
@property (nonatomic, strong, readonly) UIScrollView *filterStrip;
@property (nonatomic, strong, readonly) UIStackView *headingRow;
@property (nonatomic, strong, readonly) UIStackView *toolsRow;
@property (nonatomic, strong, readonly) UILabel *heading;
@property (nonatomic, strong, readonly) UILabel *sectionTitle;
@property (nonatomic, strong, readonly) UICollectionView *collection;
@property (nonatomic, strong, readonly) UILabel *emptyLabel;
@property (nonatomic, copy) void (^filterAction)(NSString *);
// Subclasses extend these methods after calling super.
- (void)setupUI;
- (void)setupConstraints;
- (void)installFilters:(NSArray<NSString *> *)titles;
- (void)selectFilter:(NSString *)title;
- (UIButton *)iconButton:(NSString *)symbol label:(NSString *)label;
@end
