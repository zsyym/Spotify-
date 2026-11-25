#import <UIKit/UIKit.h>
#import "SCPlaylistDetailModel.h"

typedef NS_ENUM(NSInteger, SCPlaylistAction) {
    SCPlaylistActionSave,
    SCPlaylistActionDownload,
    SCPlaylistActionMore,
    SCPlaylistActionShuffle,
    SCPlaylistActionPlay
};

@interface SCPlaylistHeaderView : UICollectionReusableView

@property (nonatomic, copy) void (^actionHandler)(SCPlaylistAction action);

- (void)configureWithModel:(SCPlaylistDetailModel *)model shuffleEnabled:(BOOL)shuffleEnabled;
- (void)showSaved:(BOOL)saved shuffleEnabled:(BOOL)shuffleEnabled;
- (CGFloat)titleBottomInView:(UIView *)view;

@end
