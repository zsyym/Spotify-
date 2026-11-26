#import "SCPlaylistCardView.h"
#import "SCMusicStyle.h"
#import "SCPlaylist.h"
#import "SCArtworkImageView.h"

@interface SCPlaylistCardView ()

@property (nonatomic, strong) SCArtworkImageView *coverView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation SCPlaylistCardView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - Public Methods

- (void)configureWithItem:(id<SCMusicItem>)item showsSubtitle:(BOOL)showsSubtitle {
    NSURL *url = [(NSObject *)item isKindOfClass:SCPlaylist.class] ? ((SCPlaylist *)item).artworkURL : nil;
    [self.coverView showURL:url placeholderName:item.artworkName];
    self.titleLabel.text = item.title;
    self.subtitleLabel.text = showsSubtitle ? item.subtitle : @"";
    self.subtitleLabel.hidden = !showsSubtitle;
    self.accessibilityLabel =
        showsSubtitle ? [NSString stringWithFormat:@"%@, %@", item.title, item.subtitle] : item.title;
}

- (void)cancelArtworkLoad { [self.coverView cancelArtworkLoad]; }

#pragma mark - UI Setup

- (void)setupUI {
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitButton;
    self.coverView = [SCArtworkImageView new];
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverView.clipsToBounds = YES;
    self.coverView.layer.cornerRadius = 6;
    self.titleLabel = SCMusicLabel(14, UIFontWeightBold);
    self.subtitleLabel = SCMusicLabel(13, UIFontWeightRegular);
    self.subtitleLabel.textColor = SCMusicColor(0xB3B3B3);
    [self addSubview:self.coverView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self);
        make.height.equalTo(self.coverView.mas_width);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverView.mas_bottom).offset(10);
        make.leading.trailing.equalTo(self);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.leading.trailing.equalTo(self);
        make.bottom.lessThanOrEqualTo(self);
    }];
}

@end
