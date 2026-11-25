#import "SCProfileAvatar.h"
#import "SCMusicStyle.h"

UIImage *SCProfileAvatar(NSString *name, UIImage *photo, CGFloat size) {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(size, size)];
    return [[renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGRect bounds = (CGRect){CGPointZero, CGSizeMake(size, size)};
        [[UIBezierPath bezierPathWithOvalInRect:bounds] addClip];
        [SCMusicColor(0xE5A87E) setFill];
        UIRectFill(bounds);
        if (photo) {
            CGFloat scale = MAX(size / photo.size.width, size / photo.size.height);
            CGSize dimensions = CGSizeMake(photo.size.width * scale, photo.size.height * scale);
            [photo drawInRect:(CGRect){CGPointMake((size - dimensions.width) / 2, (size - dimensions.height) / 2),
                                       dimensions}];
        } else {
            NSString *initial =
                name.length ? [name substringWithRange:[name rangeOfComposedCharacterSequenceAtIndex:0]].uppercaseString
                            : @"S";
            NSDictionary *attributes = @{
                NSFontAttributeName : [UIFont systemFontOfSize:size * 0.45 weight:UIFontWeightBold],
                NSForegroundColorAttributeName : SCMusicColor(0x30251E)
            };
            CGSize text = [initial sizeWithAttributes:attributes];
            [initial drawAtPoint:CGPointMake((size - text.width) / 2, (size - text.height) / 2)
                  withAttributes:attributes];
        }
    }] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
@implementation SCProfileAvatarButton
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(refresh:)
                                                   name:SCProfileDidChange
                                                 object:SCUser.current];
        [self refresh:nil];
    }
    return self;
}

- (void)refresh:(NSNotification *)notification {
    [self setBackgroundImage:SCProfileAvatar(SCUser.current.nickname, SCUser.current.photo, 40)
                    forState:UIControlStateNormal];
    self.accessibilityValue = SCUser.current.nickname;
}
@end
