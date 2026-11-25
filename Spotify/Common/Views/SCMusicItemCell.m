#import "SCMusicItemCell.h"

#import "SCMusicStyle.h"
@interface SCMusicItemCell ()
@property (nonatomic, strong) UIImageView *art;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *more;
@property (nonatomic, strong) id<SCMusicItem> item;
@property (nonatomic, assign) BOOL grid;
@end
@implementation SCMusicItemCell

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
    self.contentView.alpha = highlighted ? 0.65 : 1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.art.layer.cornerRadius = [(NSObject *)self.item isKindOfClass:SCArtist.class]
                                      ? (self.grid ? CGRectGetWidth(self.bounds) : 52) / 2
                                      : SCMusicArtworkRadius;
}

#pragma mark - Public Methods

- (void)showItem:(id<SCMusicItem>)item detail:(NSString *)detail grid:(BOOL)grid {
    self.item = item;
    self.art.image = [UIImage imageNamed:item.artworkName];
    self.name.text = item.title;
    self.detailLabel.text = detail;
    self.more.accessibilityLabel = [@"Options for " stringByAppendingString:item.title];
    if (self.grid != grid) {
        self.grid = grid;
        [self setupConstraints];
    }
    self.more.hidden = grid;
    [self setNeedsLayout];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.art = [UIImageView new];
    self.art.contentMode = UIViewContentModeScaleAspectFill;
    self.art.clipsToBounds = YES;
    self.name = SCMusicLabel(16, UIFontWeightSemibold);
    self.detailLabel = SCMusicLabel(13, UIFontWeightRegular);
    self.name.numberOfLines = self.detailLabel.numberOfLines = 1;
    self.detailLabel.textColor = SCMusicColor(SCColorSecondaryText);
    self.more = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.more setImage:[UIImage systemImageNamed:@"ellipsis"] forState:UIControlStateNormal];
    self.more.tintColor = SCMusicColor(SCColorSecondaryText);
    [self.more addTarget:self action:@selector(options) forControlEvents:UIControlEventTouchUpInside];
    for (UIView *v in @[ self.art, self.name, self.detailLabel, self.more ])
        [self.contentView addSubview:v];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.more mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.art mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.height.equalTo(self.art.mas_width);
        if (self.grid) {
            make.top.trailing.equalTo(self.contentView);
        } else {
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(52);
        }
    }];
    [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.grid) {
            make.top.equalTo(self.art.mas_bottom).offset(6);
            make.leading.trailing.equalTo(self.contentView);
        } else {
            make.leading.equalTo(self.art.mas_trailing).offset(12);
            make.trailing.equalTo(self.more.mas_leading);
            make.bottom.equalTo(self.contentView.mas_centerY);
        }
    }];
    [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.name);
        make.top.equalTo(self.name.mas_bottom).offset(3);
    }];
}

#pragma mark - Actions

- (void)options {
    if (self.moreAction)
        self.moreAction(self.item);
}

@end
