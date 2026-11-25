#import "SCSettingsCell.h"
#import "SCProfileAvatar.h"
#import "SCMusicStyle.h"

@interface SCSettingsCell ()
@property (nonatomic, strong) UIStackView *stack;
@property (nonatomic, strong) UIStackView *row;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UISwitch *toggle;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIStackView *limits;
@end
@implementation SCSettingsCell
#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    if ((self = [super initWithStyle:style reuseIdentifier:identifier])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.valueChanged = nil;
}

#pragma mark - Public Methods

- (void)showItem:(SCSettingsItem *)item value:(id)value selected:(BOOL)selected accountLink:(BOOL)accountLink {
    self.name.text = item.name;
    self.detail.text = item.detail;
    self.detail.hidden = !item.detail.length;
    self.name.textColor = SCMusicColor(item.kind == SCSettingUnavailable ? SCColorSecondaryText : SCColorText);
    self.icon.image =
        item.kind == SCSettingProfile
            ? SCProfileAvatar(SCUser.current.nickname, SCUser.current.photo, 40)
            : ([item.symbol isEqual:@"logo"] ? [UIImage imageNamed:@"SpotifyLogo"]
                                             : (item.symbol ? [UIImage systemImageNamed:item.symbol] : nil));
    self.icon.hidden = self.icon.image == nil;
    self.toggle.hidden = item.kind != SCSettingSwitch;
    self.slider.hidden = item.kind != SCSettingSlider;
    self.limits.hidden = self.slider.hidden;
    if (!self.toggle.hidden) {
        self.toggle.on = [value boolValue];
        self.toggle.accessibilityLabel = item.name;
    }
    self.valueLabel.text = [value isKindOfClass:NSString.class] ? value : nil;
    if (!self.slider.hidden) {
        self.slider.value = [value floatValue];
        self.valueLabel.text = [self seconds];
        self.slider.accessibilityLabel = item.name;
        self.slider.accessibilityValue = self.valueLabel.text;
    }
    self.valueLabel.hidden = !self.valueLabel.text.length;
    self.accessoryType = selected
                             ? UITableViewCellAccessoryCheckmark
                             : (item.kind == SCSettingLink || accountLink ? UITableViewCellAccessoryDisclosureIndicator
                                                                          : UITableViewCellAccessoryNone);
    self.selectionStyle = (item.kind == SCSettingLink || item.kind == SCSettingChoice || accountLink)
                              ? UITableViewCellSelectionStyleDefault
                              : UITableViewCellSelectionStyleNone;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCMusicColor(SCColorSurface);
    self.tintColor = SCMusicColor(SCColorBrand);
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = SCMusicColor(SCColorCard);
    self.icon = [UIImageView new];
    self.icon.tintColor = SCMusicColor(SCColorSecondaryText);
    self.icon.contentMode = UIViewContentModeScaleAspectFit;
    self.icon.preferredSymbolConfiguration = [UIImageSymbolConfiguration configurationWithPointSize:21];
    self.name = SCMusicLabel(16, UIFontWeightSemibold);
    self.detail = SCMusicLabel(13, UIFontWeightRegular);
    self.detail.numberOfLines = 0;
    self.detail.textColor = SCMusicColor(SCColorSecondaryText);
    UIStackView *labels = [[UIStackView alloc] initWithArrangedSubviews:@[ self.name, self.detail ]];
    labels.axis = UILayoutConstraintAxisVertical;
    labels.spacing = 4;
    self.valueLabel = SCMusicLabel(14, UIFontWeightMedium);
    self.valueLabel.textColor = SCMusicColor(SCColorBrand);
    [self.valueLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    self.toggle = [UISwitch new];
    self.toggle.onTintColor = SCMusicColor(SCColorBrand);
    [self.toggle addTarget:self action:@selector(valueChangedBy:) forControlEvents:UIControlEventValueChanged];
    self.row = [[UIStackView alloc] initWithArrangedSubviews:@[ self.icon, labels, self.valueLabel, self.toggle ]];
    self.row.alignment = UIStackViewAlignmentCenter;
    self.row.spacing = 12;
    self.slider = [UISlider new];
    self.slider.maximumValue = 12;
    self.slider.minimumTrackTintColor = self.tintColor;
    [self.slider addTarget:self action:@selector(valueChangedBy:) forControlEvents:UIControlEventValueChanged];
    UILabel *min = SCMusicLabel(12, UIFontWeightMedium), *max = SCMusicLabel(12, UIFontWeightMedium);
    min.text = @"Off";
    max.text = @"12s";
    self.limits = [[UIStackView alloc] initWithArrangedSubviews:@[ min, [UIView new], max ]];
    self.stack = [[UIStackView alloc] initWithArrangedSubviews:@[ self.row, self.slider, self.limits ]];
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.spacing = 8;
    [self.contentView addSubview:self.stack];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(14, 16, 14, 12));
    }];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36).priorityHigh();
    }];
}

#pragma mark - Actions

- (void)valueChangedBy:(UIControl *)control {
    NSNumber *value;
    if (control == self.slider) {
        self.slider.value = roundf(self.slider.value);
        self.valueLabel.text = [self seconds];
        self.slider.accessibilityValue = self.valueLabel.text;
        value = @((NSInteger)self.slider.value);
    } else
        value = @(self.toggle.on);
    if (self.valueChanged)
        self.valueChanged(value);
}

#pragma mark - Private Methods

- (NSString *)seconds {
    return self.slider.value < 0.5 ? @"Off" : [NSString stringWithFormat:@"%.0fs", self.slider.value];
}
@end
