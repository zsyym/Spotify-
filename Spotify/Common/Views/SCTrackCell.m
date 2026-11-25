#import "SCTrackCell.h"
#import "SCMusicStyle.h"

@interface SCTrackCell ()

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UIStackView *textStack;
@property (nonatomic, strong) UIImageView *disclosureView;

@end

@implementation SCTrackCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - Public Methods

- (void)configureWithTrack:(SCTrack *)track {
    self.coverView.image = [UIImage imageNamed:track.artworkName];
    self.titleLabel.text = track.title;
    self.artistLabel.text = track.subtitle;
    self.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", track.title, track.subtitle];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.contentView.backgroundColor = highlighted ? SCMusicColor(0x242424) : UIColor.clearColor;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitButton;
    self.coverView = [UIImageView new];
    self.coverView.layer.cornerRadius = 4;
    self.coverView.clipsToBounds = YES;
    self.titleLabel = SCMusicLabel(15, UIFontWeightSemibold);
    self.artistLabel = SCMusicLabel(13, UIFontWeightRegular);
    self.artistLabel.textColor = SCMusicColor(0xB3B3B3);
    self.textStack = [[UIStackView alloc] initWithArrangedSubviews:@[ self.titleLabel, self.artistLabel ]];
    self.textStack.axis = UILayoutConstraintAxisVertical;
    self.textStack.spacing = 4;
    self.disclosureView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    self.disclosureView.tintColor = SCMusicColor(0xB3B3B3);
    self.disclosureView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.textStack];
    [self.contentView addSubview:self.disclosureView];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(52);
    }];
    [self.textStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.coverView.mas_trailing).offset(12);
        make.trailing.equalTo(self.disclosureView.mas_leading).offset(-12);
        make.centerY.equalTo(self.contentView);
        make.top.greaterThanOrEqualTo(self.contentView).offset(6);
        make.bottom.lessThanOrEqualTo(self.contentView).offset(-6);
    }];
    [self.disclosureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-4);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(18);
    }];
}

@end
