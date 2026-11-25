#import "SCPlaybackQueueView.h"
#import "SCPlayerStyle.h"

@interface SCPlaybackQueueView ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation SCPlaybackQueueView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCMusicColor(SCColorSurface);
    self.titleLabel = SCMusicLabel(23, UIFontWeightBold);
    self.titleLabel.text = @"Playing Queue";
    self.titleLabel.accessibilityTraits |= UIAccessibilityTraitHeader;
    _closeButton = SCPlayerButton(@"xmark", @"Close queue", 17);
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionHeaderTopPadding = 8;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64;
    [self addSubview:self.titleLabel];
    [self addSubview:self.closeButton];
    [self addSubview:self.tableView];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(14);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-8);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(20);
        make.centerY.equalTo(self.closeButton);
        make.trailing.lessThanOrEqualTo(self.closeButton.mas_leading);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.closeButton.mas_bottom).offset(8);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
    }];
}

@end
