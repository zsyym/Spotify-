#import "SCNumberedTrackCell.h"
#import "SCPlayerStyle.h"
@interface SCNumberedTrackCell ()
@property (nonatomic, strong) UILabel *rank;
@property (nonatomic, strong) UIImageView *art;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *artist;
@property (nonatomic, strong) UIStackView *row;
@end
@implementation SCNumberedTrackCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)showTrack:(SCTrack *)track
           number:(NSUInteger)number
          artwork:(BOOL)artwork
          current:(BOOL)current
          playing:(BOOL)playing {
    self.rank.text = current ? (playing ? @"♫" : @"Ⅱ") : @(number).stringValue;
    self.art.hidden = !artwork;
    self.art.image = artwork ? [UIImage imageNamed:track.artworkName] : nil;
    self.name.text = track.title;
    self.artist.text = track.artist.name ?: track.subtitle;
    self.rank.textColor = current ? SCMusicColor(SCColorBrand) : SCMusicColor(SCColorSecondaryText);
    self.name.textColor = current ? SCMusicColor(SCColorBrand) : UIColor.whiteColor;
    self.moreButton.accessibilityLabel = [@"More options for " stringByAppendingString:track.title];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.rank = SCMusicLabel(15, UIFontWeightMedium);
    self.rank.textAlignment = NSTextAlignmentCenter;
    self.art = [UIImageView new];
    self.art.contentMode = UIViewContentModeScaleAspectFill;
    self.art.clipsToBounds = YES;
    self.art.layer.cornerRadius = 4;
    self.name = SCMusicLabel(16, UIFontWeightMedium);
    self.artist = SCMusicLabel(13, UIFontWeightRegular);
    self.name.numberOfLines = self.artist.numberOfLines = 1;
    self.artist.textColor = SCMusicColor(SCColorSecondaryText);
    UIStackView *text = [[UIStackView alloc] initWithArrangedSubviews:@[ self.name, self.artist ]];
    text.axis = UILayoutConstraintAxisVertical;
    text.spacing = 3;
    _moreButton = SCPlayerButton(@"ellipsis", @"More track options", 18);
    self.row = [[UIStackView alloc] initWithArrangedSubviews:@[ self.rank, self.art, text, self.moreButton ]];
    self.row.spacing = 10;
    self.row.alignment = UIStackViewAlignmentCenter;
    [self.contentView addSubview:self.row];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.row mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.trailing.top.bottom.equalTo(self.contentView);
    }];
    [self.rank mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(25);
    }];
    [self.art mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(44).priority(999);
    }];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
}

@end
