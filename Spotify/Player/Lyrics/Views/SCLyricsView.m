#import "SCLyricsView.h"
#import "SCPlayerStyle.h"

@interface SCLyricsView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UILabel *song;
@property (nonatomic, strong) UILabel *artist;
@property (nonatomic, strong) UILabel *nowPlaying;
@property (nonatomic, strong) UILabel *message;
@property (nonatomic, strong) UIButton *translation;
@property (nonatomic, strong) UIButton *resume;
@property (nonatomic, strong) UIStackView *top;
@property (nonatomic, strong) UIStackView *bottom;
@property (nonatomic, strong) SCLyricsModel *model;
@property (nonatomic, assign) NSInteger current;
@property (nonatomic, assign) BOOL follows;
@property (nonatomic, assign) BOOL translated;
@end

@implementation SCLyricsView
#pragma mark - Lifecycle

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Public Methods

- (void)beginTrack:(SCTrack *)track {
    self.song.text = track.title;
    self.artist.text = track.artist.name ?: track.subtitle;
    self.nowPlaying.text = track.title;
    NSDictionary *backgrounds = @{
        @"SCCover06" : @0x234955,
        @"SCCover07" : @0x552B4C,
        @"SCCover08" : @0x55341C,
        @"SCCover09" : @0x394128,
        @"SCCover10" : @0x301F55,
        @"SCCover11" : @0x552F26
    };
    NSNumber *color = backgrounds[track.artworkName ?: @""] ?: @0x30383A;
    ((CAGradientLayer *)self.layer).colors =
        @[ (id)SCMusicColor(color.unsignedIntValue).CGColor, (id)SCMusicColor(0x16191B).CGColor ];
    [self display:nil];
    self.message.text = track ? @"Loading lyrics…" : @"Lyrics aren’t available for this song.";
}

- (void)display:(SCLyricsModel *)model {
    self.model = model;
    self.current = NSNotFound;
    self.follows = YES;
    self.translated = model.hasTranslation;
    self.translation.hidden = !model.hasTranslation;
    self.translation.selected = self.translated;
    self.resume.hidden = YES;
    self.message.hidden = model.lines.count > 0;
    self.message.text =
        model.kind == SCLyricsInvalid ? @"These lyrics couldn’t be read." : @"Lyrics aren’t available for this song.";
    [self.table setContentOffset:CGPointZero animated:NO];
    [self.table reloadData];
}

- (void)highlight:(NSInteger)index {
    if (index == self.current)
        return;
    self.current = index;
    for (NSIndexPath *path in self.table.indexPathsForVisibleRows)
        [self styleCell:[self.table cellForRowAtIndexPath:path] row:path.row];
    if (self.follows)
        [self scrollToCurrent];
}

- (void)renderPlayback:(SCPlaybackSnapshot *)state {
    SCSetPlayerSymbol(self.play, state.playing ? @"pause.fill" : @"play.fill", state.playing ? @"Pause" : @"Play");
    [self.progress render:state];
}

#pragma mark - UI Setup

- (void)setupUI {
    _back = SCPlayerButton(@"chevron.down", @"Close lyrics", 20);
    _share = SCPlayerButton(@"square.and.arrow.up", @"Share track", 18);
    self.song = SCMusicLabel(18, UIFontWeightBold);
    self.artist = SCMusicLabel(13, UIFontWeightMedium);
    self.song.textAlignment = self.artist.textAlignment = NSTextAlignmentCenter;
    self.song.numberOfLines = self.artist.numberOfLines = 1;
    UIStackView *titles = [[UIStackView alloc] initWithArrangedSubviews:@[ self.song, self.artist ]];
    titles.axis = UILayoutConstraintAxisVertical;
    titles.spacing = 2;
    self.top = [[UIStackView alloc] initWithArrangedSubviews:@[ _back, titles, _share ]];
    self.top.alignment = UIStackViewAlignmentCenter;
    [self addSubview:self.top];
    self.table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.table.backgroundColor = UIColor.clearColor;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.rowHeight = UITableViewAutomaticDimension;
    self.table.estimatedRowHeight = 92;
    self.table.showsVerticalScrollIndicator = NO;
    [self.table registerClass:UITableViewCell.class forCellReuseIdentifier:@"line"];
    [self addSubview:self.table];
    self.message = SCMusicLabel(23, UIFontWeightBold);
    self.message.textAlignment = NSTextAlignmentCenter;
    self.message.numberOfLines = 0;
    [self addSubview:self.message];
    self.resume = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.resume setTitle:@"Return to current lyric" forState:UIControlStateNormal];
    self.resume.tintColor = SCMusicColor(SCColorBrand);
    [self.resume addTarget:self action:@selector(resumeFollowing) forControlEvents:UIControlEventTouchUpInside];
    self.translation = SCPlayerButton(@"character.bubble", @"Show or hide translations", 20);
    [self.translation addTarget:self action:@selector(toggleTranslation) forControlEvents:UIControlEventTouchUpInside];
    _play = SCPlayerButton(@"play.fill", @"Play", 24);
    self.nowPlaying = SCMusicLabel(16, UIFontWeightSemibold);
    self.nowPlaying.numberOfLines = 1;
    UIStackView *controls =
        [[UIStackView alloc] initWithArrangedSubviews:@[ self.nowPlaying, self.translation, _play ]];
    controls.spacing = 12;
    _progress = [SCPlayerProgressView new];
    self.bottom = [[UIStackView alloc] initWithArrangedSubviews:@[ self.resume, controls, _progress ]];
    self.bottom.axis = UILayoutConstraintAxisVertical;
    self.bottom.spacing = 4;
    [self addSubview:self.bottom];
}

#pragma mark - Constraints

- (void)setupConstraints {
    for (UIButton *button in @[ self.back, self.share, self.play, self.translation ])
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(44).priorityHigh();
        }];
    [self.top mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(12);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-12);
    }];
    [self.bottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-8);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(24);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-24);
    }];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top.mas_bottom).offset(12);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.bottom.equalTo(self.bottom.mas_top).offset(-8);
    }];
    [self.message mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.table);
        make.width.equalTo(self.table).offset(-48);
    }];
}

#pragma mark - Actions

- (void)toggleTranslation {
    self.translated = !self.translated;
    self.translation.selected = self.translated;
    [self.table reloadData];
    if (self.follows)
        [self scrollToCurrent];
}

- (void)resumeFollowing {
    self.follows = YES;
    self.resume.hidden = YES;
    [self scrollToCurrent];
}

#pragma mark - Delegate / DataSource

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return self.model.lines.count;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"line" forIndexPath:path];
    [self styleCell:cell row:path.row];
    return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    if (self.model.kind != SCLyricsTimed)
        return;
    NSInteger old = self.current;
    self.follows = YES;
    self.resume.hidden = YES;
    if (self.seekLine)
        self.seekLine(self.model.lines[path.row].startTime);
    if (old == self.current)
        [self scrollToCurrent];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)view {
    if (self.model.kind == SCLyricsTimed) {
        self.follows = NO;
        self.resume.hidden = NO;
    }
}

#pragma mark - Private Methods

- (void)scrollToCurrent {
    if (self.current == NSNotFound) {
        [self.table setContentOffset:CGPointZero animated:NO];
        return;
    }
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.current inSection:0]
                      atScrollPosition:UITableViewScrollPositionMiddle
                              animated:!UIAccessibilityIsReduceMotionEnabled() && !self.progress.slider.tracking &&
                                       self.window != nil];
}

- (void)styleCell:(UITableViewCell *)cell row:(NSInteger)row {
    SCLyricLine *line = self.model.lines[row];
    BOOL timed = self.model.kind == SCLyricsTimed;
    UIColor *color = UIColor.whiteColor;
    if (timed && row != self.current)
        color = [UIColor colorWithWhite:1 alpha:self.current != NSNotFound && row < self.current ? 0.58 : 0.78];
    UIListContentConfiguration *content = [UIListContentConfiguration subtitleCellConfiguration];
    content.text = line.text;
    content.textProperties.font = SCMusicFont(29, UIFontWeightBold);
    content.textProperties.color = color;
    content.textProperties.numberOfLines = 0;
    content.secondaryText = self.translated ? line.translatedText : nil;
    content.secondaryTextProperties.font = SCMusicFont(17, UIFontWeightMedium);
    content.secondaryTextProperties.color = color;
    content.secondaryTextProperties.numberOfLines = 0;
    content.textToSecondaryTextVerticalPadding = 6;
    content.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(13, 24, 13, 24);
    cell.contentConfiguration = content;
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessibilityTraits = timed ? UIAccessibilityTraitButton : UIAccessibilityTraitStaticText;
    if (timed && row == self.current)
        cell.accessibilityTraits |= UIAccessibilityTraitSelected;
}
@end
