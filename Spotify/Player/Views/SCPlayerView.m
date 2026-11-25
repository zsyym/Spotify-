#import "SCPlayerView.h"
#import "SCPlayerStyle.h"

@interface SCPlayerView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *body;
@property (nonatomic, strong) UILabel *sourceCaption;
@property (nonatomic, strong) UILabel *sourceLabel;
@property (nonatomic, strong) UIImageView *artwork;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@end

@implementation SCPlayerView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

+ (Class)layerClass {
    return CAGradientLayer.class;
}

#pragma mark - Public Methods

- (void)render:(SCPlaybackSnapshot *)state {
    self.artwork.image = [UIImage imageNamed:state.track.artworkName];
    self.titleLabel.text = state.track.title;
    self.artistLabel.text = state.track.artist.name ?: state.track.subtitle;
    self.sourceLabel.text = state.source;
    SCSetPlayerSymbol(self.favoriteButton,
                      state.favorite ? @"checkmark.circle.fill" : @"plus.circle",
                      state.favorite ? @"Remove favorite" : @"Save track");
    self.favoriteButton.tintColor = state.favorite ? SCMusicColor(0x1ED760) : UIColor.whiteColor;
    [self.progressView render:state];
    [self.controlsView render:state];
}

#pragma mark - UI Setup

- (void)setupUI {
    CAGradientLayer *gradient = (CAGradientLayer *)self.layer;
    gradient.colors = @[
        (id)SCMusicColor(0x363634).CGColor,
        (id)SCMusicColor(SCColorSurface).CGColor,
        (id)SCMusicColor(SCColorBackground).CGColor
    ];
    _closeButton = SCPlayerButton(@"chevron.down", @"Close player", 20);
    _moreButton = SCPlayerButton(@"ellipsis", @"More options", 20);
    self.sourceCaption = SCMusicLabel(10, UIFontWeightSemibold);
    self.sourceCaption.text = @"PLAYING FROM";
    self.sourceCaption.textColor = SCMusicColor(SCColorSecondaryText);
    self.sourceCaption.textAlignment = NSTextAlignmentCenter;
    self.sourceLabel = SCMusicLabel(15, UIFontWeightSemibold);
    self.sourceLabel.numberOfLines = 1;
    self.sourceLabel.textAlignment = NSTextAlignmentCenter;
    self.scrollView = [UIScrollView new];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.body = [UIView new];
    self.artwork = [UIImageView new];
    self.artwork.clipsToBounds = YES;
    self.artwork.layer.cornerRadius = SCMusicArtworkRadius;
    self.artwork.contentMode = UIViewContentModeScaleAspectFill;
    self.titleLabel = SCMusicLabel(28, UIFontWeightBold);
    self.titleLabel.numberOfLines = 2;
    self.artistLabel = SCMusicLabel(17, UIFontWeightRegular);
    self.artistLabel.numberOfLines = 1;
    self.artistLabel.textColor = SCMusicColor(SCColorSecondaryText);
    _progressView = [SCPlayerProgressView new];
    _controlsView = [SCPlayerControlsView new];
    _favoriteButton = SCPlayerButton(@"plus.circle", @"Save track", 25);
    _deviceButton = SCPlayerButton(@"hifispeaker.2", @"Audio output", 20);
    _shareButton = SCPlayerButton(@"square.and.arrow.up", @"Share track", 20);
    _queueButton = SCPlayerButton(@"list.bullet", @"Playback queue", 22);
    [self addSubview:self.moreButton];
    [self addSubview:self.sourceCaption];
    [self.body addSubview:self.shareButton];
    [self addSubview:self.scrollView];
    [self addSubview:self.closeButton];
    [self addSubview:self.sourceLabel];
    [self.scrollView addSubview:self.body];
    [self.body addSubview:self.artwork];
    [self.body addSubview:self.titleLabel];
    [self.body addSubview:self.artistLabel];
    [self.body addSubview:self.favoriteButton];
    [self.body addSubview:self.progressView];
    [self.body addSubview:self.controlsView];
    [self.body addSubview:self.deviceButton];
    [self.body addSubview:self.queueButton];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(8);
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-8);
        make.centerY.equalTo(self.closeButton);
        make.size.equalTo(self.closeButton);
    }];
    [self.sourceCaption mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.closeButton.mas_centerY).offset(-1);
        make.leading.trailing.equalTo(self.sourceLabel);
    }];
    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sourceCaption.mas_bottom);
        make.left.equalTo(self.closeButton.mas_right);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-56);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.closeButton.mas_bottom);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
    }];

    UILayoutGuide *content = self.scrollView.contentLayoutGuide;
    [self.body mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([[MASViewAttribute alloc] initWithView:self.scrollView
                                                           item:content
                                                layoutAttribute:NSLayoutAttributeTop]);
        make.leading.equalTo([[MASViewAttribute alloc] initWithView:self.scrollView
                                                               item:content
                                                    layoutAttribute:NSLayoutAttributeLeading]);
        make.trailing.equalTo([[MASViewAttribute alloc] initWithView:self.scrollView
                                                                item:content
                                                     layoutAttribute:NSLayoutAttributeTrailing]);
        make.bottom.equalTo([[MASViewAttribute alloc] initWithView:self.scrollView
                                                              item:content
                                                   layoutAttribute:NSLayoutAttributeBottom]);
        make.height.greaterThanOrEqualTo(self.scrollView.mas_height);
        make.width.equalTo([[MASViewAttribute alloc] initWithView:self.scrollView
                                                             item:self.scrollView.frameLayoutGuide
                                                  layoutAttribute:NSLayoutAttributeWidth]);
    }];
    [self.artwork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.body).offset(20);
        make.centerX.equalTo(self.body);
        make.width.lessThanOrEqualTo(self.body.mas_width).offset(-48);
        make.width.lessThanOrEqualTo(self.scrollView.mas_height).multipliedBy(0.50);
        make.width.mas_equalTo(440).priorityHigh();
        make.height.equalTo(self.artwork.mas_width);
    }];
    [self.favoriteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.body).offset(-18);
        make.centerY.equalTo(self.titleLabel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.body).offset(24);
        make.trailing.equalTo(self.favoriteButton.mas_leading).offset(-6);
        make.top.equalTo(self.artwork.mas_bottom).offset(28);
    }];
    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLabel);
        make.trailing.equalTo(self.body).offset(-24);
        make.top.equalTo(self.artistLabel.mas_bottom).offset(14);
    }];
    [self.controlsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.progressView);
        make.top.equalTo(self.progressView.mas_bottom).offset(12);
        make.height.mas_equalTo(72);
    }];
    [self.deviceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.controlsView);
        make.top.greaterThanOrEqualTo(self.controlsView.mas_bottom).offset(18);
        make.top.equalTo(self.controlsView.mas_bottom).offset(24).priority(100);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.bottom.equalTo(self.body).offset(-12);
    }];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.queueButton.mas_leading).offset(-8);
        make.centerY.equalTo(self.queueButton);
        make.size.equalTo(self.queueButton);
    }];
    [self.queueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.controlsView);
        make.centerY.equalTo(self.deviceButton);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
}

@end
