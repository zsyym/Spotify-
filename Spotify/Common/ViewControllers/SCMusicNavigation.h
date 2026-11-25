#import <UIKit/UIKit.h>
#import "SCLocalMusicCatalog.h"
@interface SCMusicNavigation : NSObject
+ (void)openItem:(id<SCMusicItem>)item from:(UIViewController *)controller;
+ (void)showOptionsFor:(id<SCMusicItem>)item from:(UIViewController *)controller;
+ (NSString *)descriptionForItem:(id<SCMusicItem>)item;
@end
