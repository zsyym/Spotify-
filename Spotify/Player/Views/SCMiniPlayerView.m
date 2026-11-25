#import "SCMiniPlayerView.h"
#import "SCPlayerStyle.h"

@interface SCMiniPlayerView ()
@property (nonatomic, strong) UIImageView *artwork;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@end

@implementation SCMiniPlayerView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)render:(SCPlaybackSnapshot *)state {
    self.artwork.image = [UIImage imageNamed:state.track.artworkName];
    self.titleLabel.text = state.track.title;
    self.artistLabel.text = state.track.artist.name ?: state.track.subtitle;
    self.openButton.accessibilityLabel =
        [NSString stringWithFormat:@"Open player, %@, %@", self.titleLabel.text, self.artistLabel.text];
    SCSetPlayerSymbol(
        self.playButton, state.playing ? @"pause.fill" : @"play.fill", state.playing ? @"Pause" : @"Play");
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCMusicColor(SCColorCard);
    self.layer.cornerRadius = SCMusicCardRadius;
    self.clipsToBounds = YES;
    self.artwork = [UIImageView new];
    self.artwork.clipsToBounds = YES;
    self.artwork.layer.cornerRadius = SCMusicArtworkRadius;
    self.artwork.contentMode = UIViewContentModeScaleAspectFill;
    self.titleLabel = SCMusicLabel(15, UIFontWeightSemibold);
    self.titleLabel.numberOfLines = 1;
    self.artistLabel = SCMusicLabel(12, UIFontWeightRegular);
    self.artistLabel.numberOfLines = 1;
    self.artistLabel.textColor = SCMusicColor(SCColorSecondaryText);
    _openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton = SCPlayerButton(@"play.fill", @"Play", 20);
    [self addSubview:self.artwork];
    [self addSubview:self.titleLabel];
    [self addSubview:self.artistLabel];
    [self addSubview:self.openButton];
    [self addSubview:self.playButton];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.artwork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.height.lessThanOrEqualTo(self.mas_height).offset(-8);
        make.height.mas_equalTo(40).priorityHigh();
        make.width.equalTo(self.artwork.mas_height);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-4);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(48);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.artwork.mas_trailing).offset(12);
        make.trailing.equalTo(self.playButton.mas_leading);
        make.bottom.equalTo(self.mas_centerY).offset(1);
    }];
    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom);
    }];
    [self.openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self);
        make.trailing.equalTo(self.playButton.mas_leading);
    }];
}

@end
