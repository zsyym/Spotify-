#import "SCArtistHeaderView.h"
#import "SCPlayerStyle.h"
@interface SCArtistHeaderView ()
@property (nonatomic, strong) UIImageView *hero;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) CAGradientLayer *shade;
@end
@implementation SCArtistHeaderView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.shade.frame = self.bounds;
    [CATransaction commit];
}

#pragma mark - Public Methods

- (void)showArtist:(SCArtist *)artist {
    self.hero.image = [UIImage imageNamed:artist.artworkName];
    self.name.text = artist.name;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.hero = [UIImageView new];
    self.hero.contentMode = UIViewContentModeScaleAspectFill;
    self.hero.clipsToBounds = YES;
    self.hero.layer.cornerRadius = 0;

    self.shade = [CAGradientLayer layer];
    self.shade.colors = @[
        (id)UIColor.clearColor.CGColor,
        (id)[UIColor colorWithWhite:0 alpha:0.18].CGColor,
        (id)SCMusicColor(SCColorBackground).CGColor
    ];
    self.shade.locations = @[ @0, @0.45, @1 ];
    [self.hero.layer addSublayer:self.shade];
    self.name = SCMusicLabel(44, UIFontWeightHeavy);
    self.name.numberOfLines = 2;
    [self.contentView addSubview:self.hero];
    [self.contentView addSubview:self.name];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.hero mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(20);
        make.trailing.equalTo(self.contentView).offset(-20);
        make.bottom.equalTo(self.contentView).offset(-12);
    }];
}

@end
