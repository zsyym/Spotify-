#import "SCHomeSectionHeaderView.h"
#import "SCMusicStyle.h"

@interface SCHomeSectionHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

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
    self.titleLabel.text = title;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.titleLabel = SCMusicLabel(24, UIFontWeightBold);
    self.titleLabel.accessibilityTraits = UIAccessibilityTraitHeader;
    [self addSubview:self.titleLabel];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self).offset(-14);
        make.top.greaterThanOrEqualTo(self).offset(12);
    }];
}

@end
