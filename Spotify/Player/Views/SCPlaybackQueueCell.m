#import "SCPlaybackQueueCell.h"
#import "SCPlayerStyle.h"

@interface SCPlaybackQueueCell ()
@property (nonatomic, strong) SCTrack *track;
@property (nonatomic, strong) UIImageView *artwork;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIImageView *currentIcon;
@end

@implementation SCPlaybackQueueCell

#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    if ((self = [super initWithStyle:style reuseIdentifier:identifier])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)configureWithTrack:(SCTrack *)track current:(BOOL)current {
    self.track = track;
    self.artwork.image = [UIImage imageNamed:track.artworkName];
    self.titleLabel.text = track.title;
    self.artistLabel.text = track.artist.name ?: track.subtitle;
    self.titleLabel.textColor = current ? SCMusicColor(SCColorBrand) : UIColor.whiteColor;
    self.currentIcon.hidden = !current;
    self.moreButton.accessibilityLabel = [NSString stringWithFormat:@"More options for %@", track.title];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = UIColor.clearColor;
    self.artwork = [UIImageView new];
    self.artwork.layer.cornerRadius = SCMusicArtworkRadius;
    self.artwork.clipsToBounds = YES;
    self.artwork.contentMode = UIViewContentModeScaleAspectFill;
    self.currentIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"waveform"]];
    self.currentIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.currentIcon.tintColor = SCMusicColor(SCColorBrand);
    self.currentIcon.backgroundColor = SCMusicColor(SCColorSurface);
    self.currentIcon.layer.cornerRadius = 3;
    self.currentIcon.clipsToBounds = YES;
    self.titleLabel = SCMusicLabel(16, UIFontWeightSemibold);
    self.artistLabel = SCMusicLabel(14, UIFontWeightRegular);
    self.titleLabel.numberOfLines = self.artistLabel.numberOfLines = 1;
    self.artistLabel.textColor = SCMusicColor(SCColorSecondaryText);
    self.moreButton = SCPlayerButton(@"ellipsis", @"More options", 18);
    [self.moreButton addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
    for (UIView *view in @[ self.artwork, self.currentIcon, self.titleLabel, self.artistLabel, self.moreButton ]) {
        [self.contentView addSubview:view];
    }
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = SCMusicColor(SCColorCard);
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.artwork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(20);
        make.centerY.equalTo(self.contentView);
        make.top.greaterThanOrEqualTo(self.contentView).offset(8);
        make.size.mas_equalTo(CGSizeMake(46, 46));
    }];
    [self.currentIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.equalTo(self.artwork);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-8);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.artwork.mas_trailing).offset(12);
        make.trailing.equalTo(self.moreButton.mas_leading).offset(-4);
        make.top.equalTo(self.contentView).offset(10);
    }];
    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
        make.bottom.lessThanOrEqualTo(self.contentView).offset(-10);
    }];
}

#pragma mark - Actions

- (void)showMore {
    if (self.moreAction)
        self.moreAction(self.track);
}
@end
