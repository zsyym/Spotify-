#import "SCPlayerControlsView.h"
#import "SCPlayerStyle.h"

@interface SCPlayerControlsView ()

@end

@implementation SCPlayerControlsView

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
    SCSetPlayerSymbol(
        self.playButton, state.playing ? @"pause.fill" : @"play.fill", state.playing ? @"Pause" : @"Play");
    UIColor *active = SCMusicColor(SCColorBrand);
    self.shuffleButton.tintColor = (state.mode == SCPlaybackModeShuffle) ? active : UIColor.whiteColor;
    self.shuffleButton.accessibilityValue = (state.mode == SCPlaybackModeShuffle) ? @"On" : @"Off";
    self.repeatButton.tintColor =
        (state.mode == SCPlaybackModeRepeatOne || state.mode == SCPlaybackModeRepeatAll) ? active : UIColor.whiteColor;
    SCSetPlayerSymbol(self.repeatButton, state.mode == SCPlaybackModeRepeatOne ? @"repeat.1" : @"repeat", @"Repeat");
    self.repeatButton.accessibilityValue = @[ @"Off", @"Off", @"Queue", @"One" ][state.mode];
    self.previousButton.enabled = state.index > 0 || state.mode == SCPlaybackModeRepeatAll;
    self.nextButton.enabled = state.index + 1 < state.queue.count || state.mode == SCPlaybackModeRepeatAll;
}

#pragma mark - UI Setup

- (void)setupUI {
    _shuffleButton = SCPlayerButton(@"shuffle", @"Shuffle", 20);
    _previousButton = SCPlayerButton(@"backward.end.fill", @"Previous track", 26);
    _playButton = SCPlayerButton(@"play.fill", @"Play", 27);
    _nextButton = SCPlayerButton(@"forward.end.fill", @"Next track", 26);
    _repeatButton = SCPlayerButton(@"repeat", @"Repeat", 20);
    self.playButton.backgroundColor = UIColor.whiteColor;
    self.playButton.tintColor = SCMusicColor(0x121212);
    self.playButton.layer.cornerRadius = 34;
    [self addSubview:self.shuffleButton];
    [self addSubview:self.previousButton];
    [self addSubview:self.playButton];
    [self addSubview:self.nextButton];
    [self addSubview:self.repeatButton];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(68, 68));
    }];
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.playButton.mas_leading).offset(-8);
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.playButton.mas_trailing).offset(8);
    }];
    [self.shuffleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
    }];
    [self.repeatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self);
    }];
    for (UIButton *button in @[ self.shuffleButton, self.previousButton, self.nextButton, self.repeatButton ]) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
    }
}

@end
