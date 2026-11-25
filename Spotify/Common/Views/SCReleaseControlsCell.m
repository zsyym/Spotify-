#import "SCReleaseControlsCell.h"
#import "SCPlayerStyle.h"
@interface SCReleaseControlsCell ()
@property (nonatomic, strong) UIStackView *row;
@end
@implementation SCReleaseControlsCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)renderArtist:(BOOL)artist saved:(BOOL)saved playing:(BOOL)playing shuffle:(BOOL)shuffle enabled:(BOOL)enabled {
    self.download.hidden = artist;
    if (artist) {
        UIButtonConfiguration *follow = [UIButtonConfiguration plainButtonConfiguration];
        follow.contentInsets = NSDirectionalEdgeInsetsMake(0, 12, 0, 12);
        follow.title = saved ? @"Following" : @"Follow";
        self.save.configuration = follow;
        [self.save setTitle:saved ? @"Following" : @"Follow" forState:UIControlStateNormal];
        self.save.accessibilityLabel = saved ? @"Unfollow artist" : @"Follow artist";
        self.save.layer.borderColor = SCMusicColor(saved ? SCColorBrand : SCColorSecondaryText).CGColor;
        self.save.layer.borderWidth = 1;
        self.save.layer.cornerRadius = 12;
    } else {
        SCSetPlayerSymbol(
            self.save, saved ? @"checkmark.circle.fill" : @"plus.circle", saved ? @"Remove album" : @"Save album");
    }
    self.save.tintColor = saved ? SCMusicColor(SCColorBrand) : UIColor.whiteColor;
    self.shuffle.tintColor = shuffle ? SCMusicColor(SCColorBrand) : UIColor.whiteColor;
    self.shuffle.enabled = self.play.enabled = enabled;
    SCSetPlayerSymbol(self.play, playing ? @"pause.fill" : @"play.fill", playing ? @"Pause" : @"Play");
}

#pragma mark - UI Setup

- (void)setupUI {
    _save = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.save setPreferredSymbolConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:23]
                               forImageInState:UIControlStateNormal];
    _download = SCPlayerButton(@"arrow.down.circle", @"Download", 22);
    _more = SCPlayerButton(@"ellipsis", @"More options", 19);
    _shuffle = SCPlayerButton(@"shuffle", @"Shuffle", 21);
    _play = SCPlayerButton(@"play.fill", @"Play", 23);

    self.play.backgroundColor = SCMusicColor(SCColorBrand);
    self.play.tintColor = UIColor.blackColor;
    self.play.layer.cornerRadius = 26;
    self.save.titleLabel.font = SCMusicFont(14, UIFontWeightSemibold);
    self.row = [[UIStackView alloc]
        initWithArrangedSubviews:@[ self.save, self.download, self.more, [UIView new], self.shuffle, self.play ]];
    self.row.alignment = UIStackViewAlignmentCenter;
    self.row.spacing = 2;
    [self.contentView addSubview:self.row];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.row mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.play mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(52, 52));
    }];

    for (UIButton *button in @[ self.save, self.download, self.shuffle, self.more ]) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
            make.width.greaterThanOrEqualTo(@44).priority(999);
        }];
        [button setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    }
}

@end
