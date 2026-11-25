#import "SCCategoryCell.h"

#import "SCMusicStyle.h"
@interface SCCategoryCell ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *art;
@end
@implementation SCCategoryCell

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
    self.contentView.alpha = highlighted ? 0.75 : 1;
}

#pragma mark - Public Methods

- (void)showCategory:(NSString *)category atIndex:(NSUInteger)index {
    static const unsigned int palette[] = {0x93415B,
                                           0xA94920,
                                           0x8E343B,
                                           0x474989,
                                           0x875E25,
                                           0x555581,
                                           0x884463,
                                           0x36675C,
                                           0x306B83,
                                           0x42704A,
                                           0x765235,
                                           0x4E6585};
    self.label.text = category;
    self.contentView.backgroundColor = SCMusicColor(palette[index % 12]);
    self.art.image = [UIImage imageNamed:[NSString stringWithFormat:@"SCCover%02lu", (unsigned long)index]];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.contentView.layer.cornerRadius = SCMusicCardRadius;
    self.contentView.clipsToBounds = YES;
    self.label = SCMusicLabel(18, UIFontWeightBold);
    self.art = [UIImageView new];
    self.art.transform = CGAffineTransformMakeRotation(0.23);
    self.art.contentMode = UIViewContentModeScaleAspectFill;
    self.art.layer.cornerRadius = 4;
    self.art.clipsToBounds = YES;
    [self.contentView addSubview:self.art];
    [self.contentView addSubview:self.label];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self.contentView).offset(12);
        make.trailing.equalTo(self.contentView).offset(-8);
    }];
    [self.art mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(66);
        make.height.equalTo(self.art.mas_width);
        make.trailing.equalTo(self.contentView).offset(9);
        make.bottom.equalTo(self.contentView).offset(14);
    }];
}

@end
