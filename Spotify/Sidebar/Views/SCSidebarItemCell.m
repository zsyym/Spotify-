#import "SCProfileAvatar.h"
#import "SCSidebarItemCell.h"
#import "SCMusicStyle.h"

@implementation SCSidebarItemCell

#pragma mark - Public Methods

- (void)showTitle:(NSString *)title symbol:(NSString *)symbol profile:(BOOL)profile {
    self.backgroundColor = UIColor.clearColor;
    UIListContentConfiguration *row = [UIListContentConfiguration subtitleCellConfiguration];
    row.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, 20, 0, 12);
    row.imageToTextPadding = 16;
    row.text = profile ? SCUser.current.nickname : title;
    row.textProperties.font = SCMusicFont(profile ? 21 : 17, UIFontWeightSemibold);
    row.textProperties.color = UIColor.whiteColor;
    row.secondaryText = profile ? @"View profile" : nil;
    row.secondaryTextProperties.color = SCMusicColor(SCColorSecondaryText);
    row.image = profile ? SCProfileAvatar(SCUser.current.nickname, SCUser.current.photo, 44)
                        : [UIImage systemImageNamed:symbol];
    row.imageProperties.preferredSymbolConfiguration =
        [UIImageSymbolConfiguration configurationWithPointSize:profile ? 44 : 22 weight:UIImageSymbolWeightRegular];
    row.imageProperties.tintColor = profile ? SCMusicColor(0xE5A87E) : UIColor.whiteColor;
    self.contentConfiguration = row;
    self.accessoryType = profile ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    self.accessibilityTraits |= UIAccessibilityTraitButton;
}
@end
