#import <UIKit/UIKit.h>
#import "SCMusicStyle.h"

// Adapt layout-guide attributes for Masonry without creating native constraints.
NS_INLINE MASViewAttribute *SCAuthGuideAttribute(UILayoutGuide *guide, NSLayoutAttribute attribute) {
    return [[MASViewAttribute alloc] initWithView:guide.owningView item:guide layoutAttribute:attribute];
}

NS_INLINE UIColor *SCAuthColor(unsigned int hex) {
    return SCMusicColor(hex);
}

NS_INLINE UIFont *SCAuthFont(CGFloat size, UIFontWeight weight, UIFontTextStyle style) {
    return [[UIFontMetrics metricsForTextStyle:style] scaledFontForFont:[UIFont systemFontOfSize:size weight:weight]];
}

NS_INLINE UILabel *SCAuthLabel(NSString *text, CGFloat size, UIFontWeight weight) {
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = SCAuthFont(size, weight, UIFontTextStyleBody);
    label.adjustsFontForContentSizeCategory = YES;
    label.textColor = UIColor.whiteColor;
    label.numberOfLines = 0;
    return label;
}

NS_INLINE UIButton *SCAuthButton(NSString *title, BOOL primary) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    configuration.title = title;
    configuration.contentInsets = NSDirectionalEdgeInsetsMake(16, 20, 16, 20);
    configuration.cornerStyle = UIButtonConfigurationCornerStyleCapsule;
    button.configuration = configuration;
    button.titleLabel.adjustsFontForContentSizeCategory = YES;
    button.configurationUpdateHandler = ^(UIButton *sender) {
        UIButtonConfiguration *config = sender.configuration;
        config.baseForegroundColor = primary ? UIColor.blackColor : UIColor.whiteColor;
        config.background.backgroundColor =
            primary ? SCAuthColor(sender.enabled ? SCColorBrand : 0x28663E) : UIColor.clearColor;
        config.background.strokeColor = SCAuthColor(sender.highlighted ? 0xFFFFFF : 0x535353);
        config.background.strokeWidth = primary ? 0 : 1;
        config.titleTextAttributesTransformer = ^NSDictionary *(NSDictionary *incoming) {
            NSMutableDictionary *attributes = incoming.mutableCopy;
            attributes[NSFontAttributeName] = SCAuthFont(16, UIFontWeightBold, UIFontTextStyleHeadline);
            return attributes;
        };
        sender.configuration = config;
        CGFloat scale = sender.highlighted && !UIAccessibilityIsReduceMotionEnabled() ? 0.98 : 1;
        sender.transform = CGAffineTransformMakeScale(scale, scale);
        sender.alpha = sender.enabled ? (sender.highlighted ? 0.85 : 1) : 0.7;
    };
    return button;
}

NS_INLINE UIImageView *SCAuthLogo(void) {
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SpotifyLogo"]];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.isAccessibilityElement = YES;
    logo.accessibilityLabel = @"Spotify";
    logo.accessibilityTraits = UIAccessibilityTraitImage;
    return logo;
}
