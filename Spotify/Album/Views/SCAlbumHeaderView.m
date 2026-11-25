#import "SCAlbumHeaderView.h"
#import "SCPlayerStyle.h"
@interface SCAlbumHeaderView ()
@property (nonatomic, strong) UIImageView *art;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *meta;
@end
@implementation SCAlbumHeaderView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)showAlbum:(SCAlbumDetailModel *)model {
    self.art.image = [UIImage imageNamed:model.album.artworkName];
    self.avatar.image =
        model.album.artist.artworkName.length ? [UIImage imageNamed:model.album.artist.artworkName] : nil;
    self.name.text = model.album.title;
    self.meta.text = model.releaseInfo;
    [self.artistButton setTitle:model.album.artist.name forState:UIControlStateNormal];
    self.artistButton.enabled = model.album.artist != nil;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.art = [UIImageView new];
    self.art.contentMode = UIViewContentModeScaleAspectFill;
    self.art.clipsToBounds = YES;
    [self.art setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                              forAxis:UILayoutConstraintAxisVertical];
    [self.art setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                              forAxis:UILayoutConstraintAxisHorizontal];
    self.art.layer.cornerRadius = 8;
    self.avatar = [UIImageView new];
    self.avatar.contentMode = UIViewContentModeScaleAspectFill;
    self.avatar.clipsToBounds = YES;
    self.avatar.layer.cornerRadius = 13;

    self.name = SCMusicLabel(30, UIFontWeightHeavy);
    self.name.numberOfLines = 1;
    self.meta = SCMusicLabel(14, UIFontWeightMedium);
    [self.name setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.meta setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    self.meta.numberOfLines = 1;
    self.meta.textColor = SCMusicColor(SCColorSecondaryText);
    _artistButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.artistButton.tintColor = UIColor.whiteColor;
    self.artistButton.titleLabel.font = SCMusicFont(16, UIFontWeightBold);
    self.artistButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    self.artistButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.art];
    [self.contentView addSubview:self.name];
    [self.contentView addSubview:self.avatar];
    [self.contentView addSubview:self.artistButton];
    [self.contentView addSubview:self.meta];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.meta mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(20);
        make.trailing.equalTo(self.contentView).offset(-20);
        make.bottom.equalTo(self.contentView).offset(-4);
    }];
    [self.artistButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.meta.mas_top);
        make.height.mas_equalTo(42);
        make.leading.equalTo(self.avatar.mas_trailing).offset(8);
        make.trailing.equalTo(self.meta);
    }];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.meta);
        make.centerY.equalTo(self.artistButton);
        make.size.mas_equalTo(CGSizeMake(26, 26));
    }];
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.meta);
        make.bottom.equalTo(self.artistButton.mas_top);
    }];
    [self.art mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.name.mas_top).offset(-18);
        make.width.equalTo(self.art.mas_height);
        make.width.lessThanOrEqualTo(self.contentView.mas_width).offset(-32);
    }];
}

@end
