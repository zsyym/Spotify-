#import "SCMusicNavigation.h"
typedef NS_ENUM(NSUInteger, SCProfileAction) { SCProfileBack, SCProfileEdit, SCProfileShare, SCProfileMore };
@interface SCProfileView : UIView
@property (nonatomic, copy) void (^action)(SCProfileAction action, UIView *sender);
@property (nonatomic, copy) void (^openItem)(id<SCMusicItem> item);
@property (nonatomic, copy) void (^itemOptions)(id<SCMusicItem> item);
- (void)showPreview:(NSArray<SCArtist *> *)preview following:(NSArray<SCArtist *> *)following;
@end
