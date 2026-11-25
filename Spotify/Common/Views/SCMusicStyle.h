#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

typedef NS_ENUM(unsigned int, SCPaletteColor) {
    SCColorBackground = 0x121212,
    SCColorSurface = 0x181818,
    SCColorCard = 0x242424,
    SCColorText = 0xFFFFFF,
    SCColorSecondaryText = 0xB3B3B3,
    SCColorBrand = 0x1ED760
};
static const CGFloat SCMusicArtworkRadius = 8;
static const CGFloat SCMusicCardRadius = 12;

NS_INLINE UIColor *SCMusicColor(unsigned int hex) {
    return [UIColor colorWithRed:((hex >> 16) & 255) / 255.0
                           green:((hex >> 8) & 255) / 255.0
                            blue:(hex & 255) / 255.0
                           alpha:1];
}
NS_INLINE UIFont *SCMusicFont(CGFloat size, UIFontWeight weight) {
    return [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody] scaledFontForFont:[UIFont systemFontOfSize:size
                                                                                                        weight:weight]];
}
NS_INLINE UILabel *SCMusicLabel(CGFloat size, UIFontWeight weight) {
    UILabel *label = [UILabel new];
    label.font = SCMusicFont(size, weight);
    label.textColor = SCMusicColor(SCColorText);
    label.adjustsFontForContentSizeCategory = YES;
    label.numberOfLines = 2;
    return label;
}
