#import "SCPlaylistTrackCell.h"
#import "SCMusicStyle.h"

@interface SCPlaylistTrackCell ()

@property (nonatomic, strong) UIImageView *artwork;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) SCTrack *track;

@end

@implementation SCPlaylistTrackCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.contentView.backgroundColor = highlighted ? SCMusicColor(0x242424) : UIColor.clearColor;
}

#pragma mark - Public Methods

- (void)configureWithTrack:(SCTrack *)track {
    self.track = track;
    self.artwork.image = [UIImage imageNamed:track.artworkName];
    self.titleLabel.text = track.title;
    self.artistLabel.text = track.artist.name ?: track.subtitle;
    self.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", track.title, self.artistLabel.text];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.artwork = [UIImageView new];
    self.artwork.contentMode = UIViewContentModeScaleAspectFill;
    self.artwork.clipsToBounds = YES;
    self.artwork.layer.cornerRadius = 3;
    self.titleLabel = SCMusicLabel(16, UIFontWeightMedium);
    self.titleLabel.numberOfLines = 1;
    self.artistLabel = SCMusicLabel(13, UIFontWeightRegular);
    self.artistLabel.numberOfLines = 1;
    self.artistLabel.textColor = SCMusicColor(0xB3B3B3);
    self.moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.moreButton setImage:[UIImage systemImageNamed:@"ellipsis"] forState:UIControlStateNormal];
    self.moreButton.tintColor = SCMusicColor(0xB3B3B3);
    self.moreButton.accessibilityLabel = @"More track options";
    [self.moreButton addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitButton;
    self.accessibilityCustomActions = @[ [[UIAccessibilityCustomAction alloc] initWithName:@"More track options"
                                                                                    target:self
                                                                                  selector:@selector(showMore)] ];
    for (UIView *view in @[ self.artwork, self.titleLabel, self.artistLabel, self.moreButton ]) {
        [self.contentView addSubview:view];
    }
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.artwork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(20);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(46, 46));
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
        make.top.equalTo(self.titleLabel.mas_bottom).offset(2);
    }];
}

#pragma mark - Actions

- (BOOL)showMore {
    if (self.moreAction && self.track) {
        self.moreAction(self.track);
        return YES;
    }
    return NO;
}

@end
