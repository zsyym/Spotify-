#import "SCHomeSectionHeaderView.h"
#import "SCMusicStyle.h"

@interface SCHomeSectionHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIStackView *stack;

@end

@implementation SCHomeSectionHeaderView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - Public Methods

- (void)configureTitle:(NSString *)title {
    [self configureTitle:title message:nil allowsRetry:NO];
}

- (void)configureTitle:(NSString *)title message:(NSString *)message allowsRetry:(BOOL)allowsRetry {
    self.messageLabel.text = message;
    self.messageLabel.hidden = message.length == 0;
    self.retryButton.hidden = !allowsRetry;
    self.titleLabel.text = title;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.titleLabel = SCMusicLabel(24, UIFontWeightBold);
    self.titleLabel.accessibilityTraits = UIAccessibilityTraitHeader;
    self.messageLabel = SCMusicLabel(14, UIFontWeightRegular);
    self.messageLabel.textColor = SCMusicColor(SCColorSecondaryText);
    self.messageLabel.numberOfLines = 0;
    self.retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.retryButton setTitle:@"Retry" forState:UIControlStateNormal];
    self.retryButton.tintColor = SCMusicColor(SCColorBrand);
    [self.retryButton addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
    self.stack =
        [[UIStackView alloc] initWithArrangedSubviews:@[ self.titleLabel, self.messageLabel, self.retryButton ]];
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.alignment = UIStackViewAlignmentLeading;
    self.stack.spacing = 4;
    [self addSubview:self.stack];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self).offset(-14);
        make.top.equalTo(self).offset(12);
    }];
}

#pragma mark - Actions

- (void)retry {
    if (self.retryAction)
        self.retryAction();
}

@end
