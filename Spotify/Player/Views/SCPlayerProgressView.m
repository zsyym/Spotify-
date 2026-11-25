#import "SCPlayerProgressView.h"
#import "SCPlayerStyle.h"

@interface SCPlayerProgressView ()
@property (nonatomic, strong) UILabel *elapsed;
@property (nonatomic, strong) UILabel *total;
@end

@implementation SCPlayerProgressView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)render:(SCPlaybackSnapshot *)state {
    self.slider.maximumValue = MAX(1, state.duration);
    self.slider.enabled = state.duration > 0;
    if (!self.slider.tracking)
        self.slider.value = state.progress;
    self.elapsed.text = [self timeLabel:state.progress];
    self.total.text = [self timeLabel:state.duration];
    self.slider.accessibilityValue = self.elapsed.text;
}

#pragma mark - UI Setup

- (void)setupUI {
    _slider = [UISlider new];
    self.slider.continuous = YES;
    self.slider.thumbTintColor = UIColor.whiteColor;
    self.slider.minimumTrackTintColor = UIColor.whiteColor;
    self.slider.maximumTrackTintColor = SCMusicColor(0x606665);
    self.slider.accessibilityLabel = @"Playback position";
    self.elapsed = SCMusicLabel(12, UIFontWeightMedium);
    self.elapsed.numberOfLines = 1;
    self.total = SCMusicLabel(12, UIFontWeightMedium);
    self.total.numberOfLines = 1;
    self.elapsed.textColor = self.total.textColor = SCMusicColor(SCColorSecondaryText);
    [self addSubview:self.slider];
    [self addSubview:self.elapsed];
    [self addSubview:self.total];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(36);
    }];
    [self.elapsed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.top.equalTo(self.slider.mas_bottom);
        make.bottom.equalTo(self);
    }];
    [self.total mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self);
        make.centerY.equalTo(self.elapsed);
    }];
}

#pragma mark - Private Methods

- (NSString *)timeLabel:(NSTimeInterval)seconds {
    NSInteger whole = (NSInteger)seconds;
    return [NSString stringWithFormat:@"%ld:%02ld", (long)(whole / 60), (long)(whole % 60)];
}

@end
