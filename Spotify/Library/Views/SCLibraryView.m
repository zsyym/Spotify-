#import "SCProfileAvatar.h"
#import "SCLibraryView.h"
@implementation SCLibraryView

#pragma mark - UI Setup

- (void)setupUI {
    [super setupUI];
    self.heading.text = @"Your Library";
    self.heading.font = SCMusicFont(25, UIFontWeightBold);
    _avatar = [SCProfileAvatarButton new];
    self.avatar.accessibilityLabel = @"Open sidebar";
    [self.headingRow insertArrangedSubview:self.avatar atIndex:0];
    _searchButton = [self iconButton:@"magnifyingglass" label:@"Search your library"];
    _addButton = [self iconButton:@"plus" label:@"Add to your library"];
    [self.headingRow addArrangedSubview:_searchButton];
    [self.headingRow addArrangedSubview:_addButton];
    self.searchRow.hidden = YES;
    self.field.placeholder = @"Search your library";
    self.field.accessibilityLabel = self.field.placeholder;
    [self installFilters:@[ @"Playlists", @"Artists", @"Albums", @"Downloaded" ]];
    self.sectionTitle.hidden = YES;
    _sortButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _sortButton.tintColor = UIColor.whiteColor;
    [_sortButton setImage:[UIImage systemImageNamed:@"arrow.up.arrow.down"] forState:UIControlStateNormal];
    _sortButton.titleLabel.font = SCMusicFont(14, UIFontWeightMedium);
    _layoutButton = [self iconButton:@"square.grid.2x2" label:@"Show grid"];
    [self.toolsRow addArrangedSubview:_sortButton];
    [self.toolsRow addArrangedSubview:[UIView new]];
    [self.toolsRow addArrangedSubview:_layoutButton];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [super setupConstraints];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(32);
    }];
    for (UIButton *button in @[ self.searchButton, self.addButton, self.layoutButton ]) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(44);
        }];
    }
}
@end
