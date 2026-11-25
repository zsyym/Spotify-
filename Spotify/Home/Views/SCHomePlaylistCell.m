#import "SCHomePlaylistCell.h"
#import "SCPlaylistCardView.h"
#import "SCMusicStyle.h"

@interface SCHomePlaylistCell ()

@property (nonatomic, strong) SCPlaylistCardView *cardView;

@end

@implementation SCHomePlaylistCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - Public Methods

- (void)configureWithItem:(id<SCMusicItem>)item album:(BOOL)album {
    [self.cardView configureWithItem:item showsSubtitle:!album];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.contentView.alpha = highlighted ? 0.65 : 1;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.cardView = [SCPlaylistCardView new];
    self.cardView.userInteractionEnabled = NO;
    [self.contentView addSubview:self.cardView];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

@end
