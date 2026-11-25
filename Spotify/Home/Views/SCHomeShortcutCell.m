#import "SCHomeShortcutCell.h"
#import "SCMusicStyle.h"

@interface SCHomeShortcutCell ()

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SCHomeShortcutCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - Public Methods

- (void)configureWithItem:(id<SCMusicItem>)item {
    self.coverView.image = [UIImage imageNamed:item.artworkName];
    self.titleLabel.text = item.title;
    self.accessibilityLabel = item.title;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.contentView.alpha = highlighted ? 0.6 : 1;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.contentView.backgroundColor = SCMusicColor(SCColorCard);
    self.contentView.layer.cornerRadius = SCMusicArtworkRadius;
    self.contentView.clipsToBounds = YES;
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitButton;
    self.coverView = [UIImageView new];
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverView.clipsToBounds = YES;
    self.titleLabel = SCMusicLabel(12, UIFontWeightBold);
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.titleLabel];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.contentView);
        make.width.equalTo(self.coverView.mas_height);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.coverView.mas_trailing).offset(8);
        make.trailing.equalTo(self.contentView).offset(-8);
        make.centerY.equalTo(self.contentView);
        make.top.greaterThanOrEqualTo(self.contentView).offset(6);
        make.bottom.lessThanOrEqualTo(self.contentView).offset(-6);
    }];
}

@end
