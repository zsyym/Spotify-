#import "SCPlaylistHeaderView.h"
#import "SCMusicStyle.h"
#import "SCArtworkImageView.h"
#import "SCAlbum.h"

@interface SCPlaylistHeaderView ()

@property (nonatomic, strong) SCArtworkImageView *artwork;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *creatorLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *shuffleButton;
@property (nonatomic, strong) UIButton *playButton;

@end

@implementation SCPlaylistHeaderView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)prepareForReuse { [super prepareForReuse]; [self.artwork cancelArtworkLoad]; }

#pragma mark - Public Methods

- (void)configureWithModel:(SCPlaylistDetailModel *)model shuffleEnabled:(BOOL)shuffleEnabled {
    SCPlaylist *playlist = model.playlist;
    [self.artwork showURL:playlist.artworkURL placeholderName:playlist.artworkName];
    self.titleLabel.text = playlist.title;
    self.descriptionLabel.text = playlist.subtitle;
    self.creatorLabel.text = playlist.creatorName;
    self.summaryLabel.text = model.trackSummary;
    [self showSaved:playlist.isSaved shuffleEnabled:shuffleEnabled];
}

- (void)showSaved:(BOOL)saved shuffleEnabled:(BOOL)shuffleEnabled {
    self.saveButton.selected = saved;
    self.saveButton.accessibilityLabel = saved ? @"Remove from saved playlists" : @"Save playlist";
    self.saveButton.tintColor = saved ? SCMusicColor(SCColorBrand) : SCMusicColor(SCColorSecondaryText);
    self.shuffleButton.selected = shuffleEnabled;
    self.shuffleButton.tintColor = shuffleEnabled ? SCMusicColor(SCColorBrand) : SCMusicColor(SCColorSecondaryText);
}

- (CGFloat)titleBottomInView:(UIView *)view {
    return CGRectGetMaxY([self.titleLabel convertRect:self.titleLabel.bounds toView:view]);
}

#pragma mark - UI Setup

- (void)setupUI {
    self.artwork = [SCArtworkImageView new];
    self.artwork.contentMode = UIViewContentModeScaleAspectFill;
    self.artwork.clipsToBounds = YES;
    self.artwork.layer.cornerRadius = SCMusicArtworkRadius;
    self.titleLabel = SCMusicLabel(32, UIFontWeightHeavy);
    self.titleLabel.accessibilityTraits |= UIAccessibilityTraitHeader;
    self.descriptionLabel = SCMusicLabel(15, UIFontWeightRegular);
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textColor = SCMusicColor(0xC7C7C7);
    self.creatorLabel = SCMusicLabel(14, UIFontWeightSemibold);
    self.summaryLabel = SCMusicLabel(13, UIFontWeightRegular);
    self.summaryLabel.textColor = SCMusicColor(SCColorSecondaryText);
    for (UIView *view in
         @[ self.artwork, self.titleLabel, self.descriptionLabel, self.creatorLabel, self.summaryLabel ]) {
        [self addSubview:view];
    }
    self.saveButton = [self buttonWithSymbol:@"plus.circle" label:@"Save playlist" action:SCPlaylistActionSave];
    [self.saveButton setImage:[UIImage systemImageNamed:@"checkmark.circle.fill"] forState:UIControlStateSelected];
    self.downloadButton = [self buttonWithSymbol:@"arrow.down.circle"
                                           label:@"Download playlist"
                                          action:SCPlaylistActionDownload];
    self.moreButton = [self buttonWithSymbol:@"ellipsis" label:@"More playlist options" action:SCPlaylistActionMore];
    self.shuffleButton = [self buttonWithSymbol:@"shuffle" label:@"Shuffle" action:SCPlaylistActionShuffle];
    self.playButton = [self buttonWithSymbol:@"play.fill" label:@"Play playlist" action:SCPlaylistActionPlay];
    self.playButton.backgroundColor = SCMusicColor(SCColorBrand);
    self.playButton.tintColor = SCMusicColor(SCColorBackground);
    self.playButton.layer.cornerRadius = 27;
}

- (UIButton *)buttonWithSymbol:(NSString *)symbol label:(NSString *)label action:(SCPlaylistAction)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setPreferredSymbolConfiguration:[UIImageSymbolConfiguration
                                                configurationWithPointSize:23
                                                                    weight:UIImageSymbolWeightMedium]
                            forImageInState:UIControlStateNormal];
    [button setImage:[UIImage systemImageNamed:symbol] forState:UIControlStateNormal];
    button.tintColor = SCMusicColor(SCColorSecondaryText);
    button.accessibilityLabel = label;
    __weak typeof(self) weakSelf = self;
    [button addAction:[UIAction actionWithHandler:^(UIAction *sender) {
                if (weakSelf.actionHandler) {
                    weakSelf.actionHandler(action);
                }
            }]
        forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.artwork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(8);
        make.centerX.equalTo(self);
        make.width.lessThanOrEqualTo(self.mas_width).multipliedBy(0.60);
        make.width.mas_equalTo(224).priorityHigh();
        make.height.equalTo(self.artwork.mas_width);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.artwork.mas_bottom).offset(24);
        make.leading.equalTo(self).offset(20);
        make.trailing.equalTo(self).offset(-20);
    }];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(6);
        make.leading.trailing.equalTo(self.titleLabel);
    }];
    [self.creatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionLabel.mas_bottom).offset(14);
        make.leading.trailing.equalTo(self.titleLabel);
    }];
    [self.summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.creatorLabel.mas_bottom).offset(3);
        make.leading.trailing.equalTo(self.titleLabel);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.summaryLabel.mas_bottom).offset(12);
        make.trailing.equalTo(self.titleLabel);
        make.size.mas_equalTo(CGSizeMake(54, 54));
        make.bottom.equalTo(self).offset(-14);
    }];
    [self.shuffleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.playButton.mas_leading).offset(-8);
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10);
    }];
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.saveButton.mas_trailing);
    }];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.downloadButton.mas_trailing);
    }];
    for (UIButton *button in @[ self.saveButton, self.downloadButton, self.moreButton, self.shuffleButton ]) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.playButton);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
    }
}

@end
