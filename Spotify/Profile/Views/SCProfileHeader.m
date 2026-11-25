#import "SCProfileHeader.h"
#import "SCProfileAvatar.h"
#import "SCPlayerStyle.h"
@interface SCProfileHeader ()
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *stats;
@property (nonatomic, strong) UIStackView *stack;
@end
@implementation SCProfileHeader
#pragma mark - Lifecycle
+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)showFollowingCount:(NSUInteger)count {
    self.avatar.image = SCProfileAvatar(SCUser.current.nickname, SCUser.current.photo, 108);
    self.name.text = SCUser.current.nickname;
    self.stats.text = [NSString stringWithFormat:@"0 followers   ·   %lu following", (unsigned long)count];
}

#pragma mark - UI Setup
- (void)setupUI {
    ((CAGradientLayer *)self.layer).colors =
        @[ (id)SCMusicColor(0x514235).CGColor, (id)SCMusicColor(SCColorBackground).CGColor ];
    self.avatar = [UIImageView new];
    UILabel *tag = SCMusicLabel(13, UIFontWeightSemibold);
    tag.text = @"Profile";
    self.name = SCMusicLabel(30, UIFontWeightBold);
    self.name.textAlignment = NSTextAlignmentCenter;
    self.stats = SCMusicLabel(14, UIFontWeightMedium);
    self.stats.textColor = SCMusicColor(SCColorSecondaryText);
    _editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_editButton setTitle:@"Edit profile" forState:UIControlStateNormal];
    _editButton.tintColor = UIColor.whiteColor;
    _editButton.layer.cornerRadius = 18;
    _editButton.layer.borderWidth = 1;
    _editButton.layer.borderColor = SCMusicColor(0x777777).CGColor;
    _shareButton = SCPlayerButton(@"square.and.arrow.up", @"Share profile", 19);
    _moreButton = SCPlayerButton(@"ellipsis", @"More profile options", 20);
    UIStackView *actions = [[UIStackView alloc] initWithArrangedSubviews:@[ _editButton, _shareButton, _moreButton ]];
    actions.spacing = 16;
    self.stack = [[UIStackView alloc] initWithArrangedSubviews:@[ self.avatar, tag, self.name, self.stats, actions ]];
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.alignment = UIStackViewAlignmentCenter;
    self.stack.spacing = 8;
    [self.stack setCustomSpacing:16 afterView:self.stats];
    [self.contentView addSubview:self.stack];
}

#pragma mark - Constraints
- (void)setupConstraints {
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(108, 108));
    }];
    [self.stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.width.equalTo(self.contentView).offset(-32);
    }];
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(36);
    }];
}
@end
