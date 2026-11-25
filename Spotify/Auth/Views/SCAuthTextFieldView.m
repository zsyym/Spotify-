#import "SCAuthTextFieldView.h"
#import "SCAuthStyle.h"

@interface SCAuthTextFieldView ()

@property (nonatomic, strong) UIView *surface;
@property (nonatomic, strong) UIButton *visibilityButton;
@property (nonatomic, assign) BOOL invalid;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL passwordEntry;
@property (nonatomic, copy) NSString *fieldTitle;

@end

@implementation SCAuthTextFieldView

#pragma mark - Lifecycle

- (instancetype)initWithTitle:(NSString *)title password:(BOOL)password {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    _passwordEntry = password;
    _fieldTitle = [title copy];
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - Public Methods

- (void)setInvalid:(BOOL)invalid {
    _invalid = invalid;
    [self updateBorder];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.label = SCAuthLabel(self.fieldTitle, 14, UIFontWeightBold);
    _surface = [UIView new];
    _surface.backgroundColor = SCAuthColor(0x242424);
    _surface.layer.cornerRadius = 6;
    _surface.layer.borderWidth = 1;
    _textField = [UITextField new];
    _textField.textColor = UIColor.whiteColor;
    _textField.tintColor = SCAuthColor(0x1ED760);
    _textField.font = SCAuthFont(16, UIFontWeightRegular, UIFontTextStyleBody);
    _textField.adjustsFontForContentSizeCategory = YES;
    _textField.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:self.passwordEntry ? @"Enter your password" : @"Email or username"
                                        attributes:@{NSForegroundColorAttributeName : SCAuthColor(0xB3B3B3)}];
    _textField.accessibilityLabel = self.fieldTitle;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.spellCheckingType = UITextSpellCheckingTypeNo;
    _textField.textContentType = self.passwordEntry ? UITextContentTypePassword : UITextContentTypeUsername;
    _textField.secureTextEntry = self.passwordEntry;
    _textField.returnKeyType = self.passwordEntry ? UIReturnKeyDone : UIReturnKeyNext;
    _textField.enablesReturnKeyAutomatically = YES;
    [self addSubview:self.label];
    [self addSubview:_surface];
    [_surface addSubview:_textField];
    if (self.passwordEntry) {
        _visibilityButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _visibilityButton.tintColor = SCAuthColor(0xB3B3B3);
        [_visibilityButton addTarget:self
                              action:@selector(togglePassword)
                    forControlEvents:UIControlEventTouchUpInside];
        [_surface addSubview:_visibilityButton];
        [self updateVisibilityButton];
    }
    [_textField addTarget:self
                   action:@selector(updateBorder)
         forControlEvents:UIControlEventEditingDidBegin | UIControlEventEditingDidEnd];
    [self updateBorder];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self);
    }];
    [_surface mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.label.mas_bottom).offset(10);
        make.leading.trailing.bottom.equalTo(self);
        make.height.greaterThanOrEqualTo(@56);
    }];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.surface).offset(16);
        make.trailing.equalTo(self.passwordEntry ? self.visibilityButton.mas_leading : self.surface.mas_trailing)
            .offset(self.passwordEntry ? -4 : -16);
        make.top.bottom.equalTo(self.surface).inset(16);
    }];
    if (self.passwordEntry) {
        [_visibilityButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.surface).offset(-4);
            make.centerY.equalTo(self.surface);
            make.width.height.mas_equalTo(44);
        }];
    }
}

#pragma mark - Actions

- (void)togglePassword {
    UITextRange *selection = self.textField.selectedTextRange;
    self.textField.secureTextEntry = !self.textField.secureTextEntry;
    if (selection)
        self.textField.selectedTextRange = selection;
    [self updateVisibilityButton];
}

#pragma mark - Private Methods

- (void)updateBorder {
    self.surface.layer.borderColor = SCAuthColor(self.invalid                      ? 0xF15E6C
                                                 : self.textField.isFirstResponder ? 0xFFFFFF
                                                                                   : 0x535353)
                                         .CGColor;
    self.surface.layer.borderWidth = self.textField.isFirstResponder ? 2 : 1;
}

- (void)updateVisibilityButton {
    [self.visibilityButton setImage:[UIImage systemImageNamed:self.textField.secureTextEntry ? @"eye" : @"eye.slash"]
                           forState:UIControlStateNormal];
    self.visibilityButton.accessibilityLabel = self.textField.secureTextEntry ? @"Show password" : @"Hide password";
}

@end
