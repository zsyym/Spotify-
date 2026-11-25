#import "SCMusicStyle.h"

NS_INLINE void SCSetPlayerSymbol(UIButton *button, NSString *symbol, NSString *label) {
    UIImage *image = [UIImage systemImageNamed:symbol];
    if (![[button imageForState:UIControlStateNormal] isEqual:image]) {
        if (button.window && !UIAccessibilityIsReduceMotionEnabled()) {
            [UIView transitionWithView:button
                              duration:0.15
                               options:UIViewAnimationOptionTransitionCrossDissolve |
                                       UIViewAnimationOptionAllowUserInteraction |
                                       UIViewAnimationOptionBeginFromCurrentState
                            animations:^{
                                [button setImage:image forState:UIControlStateNormal];
                            }
                            completion:nil];
        } else {
            [button setImage:image forState:UIControlStateNormal];
        }
    }
    button.accessibilityLabel = label;
}

NS_INLINE UIButton *SCPlayerButton(NSString *symbol, NSString *label, CGFloat size) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tintColor = UIColor.whiteColor;
    [button setPreferredSymbolConfiguration:[UIImageSymbolConfiguration
                                                configurationWithPointSize:size
                                                                    weight:UIImageSymbolWeightMedium]
                            forImageInState:UIControlStateNormal];
    SCSetPlayerSymbol(button, symbol, label);
    return button;
}
