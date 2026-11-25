#import <UIKit/UIKit.h>
#import "SCHomeSectionModel.h"

@class SCHomeHeaderView;
@interface SCHomeView : UIView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) SCHomeHeaderView *headerView;

- (void)showSections:(NSArray<SCHomeSectionModel *> *)sections;

@end
