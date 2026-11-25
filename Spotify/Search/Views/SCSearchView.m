#import "SCSearchView.h"
@implementation SCSearchView

#pragma mark - UI Setup

- (void)setupUI {
    [super setupUI];
    self.heading.text = @"Search";
    self.field.placeholder = @"What do you want to listen to?";
    self.field.accessibilityLabel = @"Search music";
    self.sectionTitle.text = @"Browse All";
    [self installFilters:@[ @"All", @"Songs", @"Artists", @"Albums", @"Playlists" ]];
    self.cancelButton.hidden = YES;
    self.filterStrip.hidden = YES;
}

@end
