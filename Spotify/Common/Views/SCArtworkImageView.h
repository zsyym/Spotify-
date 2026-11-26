#import <UIKit/UIKit.h>
@interface SCArtworkImageView : UIImageView
- (void)showURL:(nullable NSURL *)url placeholderName:(NSString *)name;
- (void)cancelArtworkLoad;
@end
