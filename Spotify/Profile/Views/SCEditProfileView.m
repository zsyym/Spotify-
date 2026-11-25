#import "SCEditProfileView.h"
#import "SCProfileAvatar.h"
#import "SCAuthStyle.h"
@interface SCEditProfileView ()
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UIStackView *form;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UILabel *title;
@end
@implementation SCEditProfileView
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)previewName:(NSString *)name photo:(UIImage *)photo {
    self.avatar.image = SCProfileAvatar(name, photo, 108);
}

#pragma mark - UI Setup
- (void)setupUI {
    self.backgroundColor = SCMusicColor(SCColorBackground);
    self.title = SCMusicLabel(18, UIFontWeightBold);
    self.title.text = @"Edit profile";
    [self addSubview:self.title];
    _cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    _cancel.tintColor = UIColor.whiteColor;
    [self addSubview:_cancel];
    _save = [UIButton buttonWithType:UIButtonTypeSystem];
    [_save setTitle:@"Save" forState:UIControlStateNormal];
    _save.tintColor = SCMusicColor(SCColorBrand);
    [self addSubview:_save];
    self.scroll = [UIScrollView new];
    self.scroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self addSubview:self.scroll];
    self.avatar = [UIImageView new];
    _change = [UIButton buttonWithType:UIButtonTypeSystem];
    [_change setTitle:@"Change photo" forState:UIControlStateNormal];
    _change.tintColor = UIColor.whiteColor;
    UILabel *label = SCMusicLabel(16, UIFontWeightSemibold);
    label.text = @"Display name";
    _field = [UITextField new];
    _field.accessibilityLabel = label.text;
    _field.backgroundColor = SCMusicColor(SCColorCard);
    _field.textColor = UIColor.whiteColor;
    _field.tintColor = SCMusicColor(SCColorBrand);
    _field.layer.cornerRadius = 8;
    _field.borderStyle = UITextBorderStyleRoundedRect;
    _field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _field.returnKeyType = UIReturnKeyDone;
    _field.textContentType = UITextContentTypeNickname;
    _hint = SCMusicLabel(14, UIFontWeightRegular);
    _hint.textColor = SCMusicColor(SCColorSecondaryText);
    self.form = [[UIStackView alloc] initWithArrangedSubviews:@[ self.avatar, _change, label, _field, _hint ]];
    self.form.axis = UILayoutConstraintAxisVertical;
    self.form.alignment = UIStackViewAlignmentCenter;
    self.form.spacing = 10;
    [self.form setCustomSpacing:30 afterView:_change];
    [self.scroll addSubview:self.form];
}

#pragma mark - Constraints
- (void)setupConstraints {
    [self.cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(16);
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(48);
    }];
    [self.save mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-16);
        make.centerY.equalTo(self.cancel);
        make.height.mas_equalTo(48);
    }];
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.cancel);
    }];
    [self.scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cancel.mas_bottom);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.bottom.equalTo(SCAuthGuideAttribute(self.keyboardLayoutGuide, NSLayoutAttributeTop));
    }];
    [self.form mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scroll).insets(UIEdgeInsetsMake(22, 24, 24, 24));
        make.width.equalTo(self.scroll).offset(-48);
    }];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(108, 108));
    }];
    [self.field mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.form);
        make.height.mas_equalTo(50);
    }];
    [self.hint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.form);
    }];
}
@end
