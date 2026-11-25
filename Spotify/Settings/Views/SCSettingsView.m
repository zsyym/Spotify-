#import "SCSettingsView.h"
#import "SCPlayerStyle.h"
@interface SCSettingsView ()
@property (nonatomic, strong) UILabel *heading;
@property (nonatomic, strong) UILabel *note;
@property (nonatomic, strong) UIStackView *header;
@end
@implementation SCSettingsView
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)showTitle:(NSString *)title note:(NSString *)note {
    self.heading.text = title;
    self.note.text = note;
    self.note.hidden = !note.length;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCMusicColor(SCColorBackground);
    _back = SCPlayerButton(@"chevron.backward", @"Back", 21);
    [self addSubview:_back];
    self.heading = SCMusicLabel(28, UIFontWeightBold);
    self.note = SCMusicLabel(14, UIFontWeightRegular);
    self.note.textColor = SCMusicColor(SCColorSecondaryText);
    self.header = [[UIStackView alloc] initWithArrangedSubviews:@[ self.heading, self.note ]];
    self.header.axis = UILayoutConstraintAxisVertical;
    self.header.spacing = 6;
    [self addSubview:self.header];
    _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    _table.backgroundColor = self.backgroundColor;
    _table.separatorColor = SCMusicColor(SCColorCard);
    _table.rowHeight = UITableViewAutomaticDimension;
    _table.estimatedRowHeight = 70;
    _table.sectionHeaderHeight = 12;
    _table.sectionFooterHeight = 4;
    [self addSubview:_table];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.back mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(4);
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(20);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-20);
        make.top.equalTo(self.back.mas_bottom).offset(4);
    }];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.header.mas_bottom).offset(8);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
    }];
}
@end
