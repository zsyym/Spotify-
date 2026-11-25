#import "SCPlaybackManager.h"
#import "SCLibraryStore.h"

NSNotificationName const SCPlaybackDidChangeNotification = @"SCPlaybackDidChangeNotification";

NSNotificationName const SCPlaybackProgressDidChange = @"SCPlaybackProgressDidChange";

@interface SCPlaybackManager ()
@property (nonatomic, copy) NSArray<SCTrack *> *queue;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) SCPlaybackMode mode;
@property (nonatomic, copy) NSArray<SCTrack *> *originalQueue;
@property (nonatomic, copy) NSArray<NSNumber *> *shuffleOrder;
@property (nonatomic, assign) NSTimeInterval progress;
@property (nonatomic, strong) NSTimer *clock;
@property (nonatomic, assign) NSTimeInterval lastTick;
@end

@implementation SCPlaybackManager

#pragma mark - Lifecycle

+ (instancetype)sharedManager {
    static SCPlaybackManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [self new];
    });
    return manager;
}

- (instancetype)init {
    if ((self = [super init])) {
        _queue = @[];
        _source = @"";
        _index = NSNotFound;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(libraryChanged:)
                                                     name:SCLibraryDidChange
                                                   object:SCLibraryStore.sharedStore];
        [self refreshSnapshot];
    }
    return self;
}

#pragma mark - Public Methods

- (void)playQueue:(NSArray<SCTrack *> *)queue atIndex:(NSUInteger)index source:(NSString *)source {
    [self playQueue:queue atIndex:index source:source identifier:nil];
}

- (void)playQueue:(NSArray<SCTrack *> *)queue
          atIndex:(NSUInteger)index
           source:(NSString *)source
       identifier:(NSString *)identifier {
    if (index >= queue.count)
        return;
    _sourceIdentifier = identifier.copy;
    self.originalQueue = queue;
    self.queue = self.originalQueue;
    self.source = source;
    self.index = index;
    if (self.mode == SCPlaybackModeShuffle)
        [self shuffleKeepingCurrentTrack];
    [self selectQueueIndex:self.index];
}

- (void)selectQueueIndex:(NSUInteger)index {
    if (index >= self.queue.count)
        return;
    self.index = index;
    self.lastTick = NSProcessInfo.processInfo.systemUptime;
    self.progress = 0;
    self.playing = YES;
    [self publish];
    [self recordCurrentTrack];
}

- (void)togglePlayback {
    if (!self.snapshot.track)
        return;
    if (!self.playing && self.progress >= self.snapshot.duration)
        self.progress = 0;
    self.playing = !self.playing;
    [self publish];
}

- (void)skipBy:(NSInteger)direction {
    if (!self.queue.count || (direction != 1 && direction != -1))
        return;
    NSInteger next = (NSInteger)self.index + direction;
    NSInteger count = self.queue.count;
    if (self.mode == SCPlaybackModeRepeatAll)
        next = (next + count) % count;
    if (next < 0 || next >= count)
        return;
    self.index = next;
    self.lastTick = NSProcessInfo.processInfo.systemUptime;
    self.progress = 0;
    [self publish];
    [self recordCurrentTrack];
}

- (void)seekTo:(NSTimeInterval)seconds {
    if (!self.snapshot.track || !isfinite(seconds))
        return;
    self.lastTick = NSProcessInfo.processInfo.systemUptime;
    self.progress = MAX(0, MIN(seconds, self.snapshot.duration));
    [self publish];
}

- (void)toggleShuffle {
    [self changeMode:self.mode == SCPlaybackModeShuffle ? SCPlaybackModeSequential : SCPlaybackModeShuffle];
}

- (void)cycleRepeatMode {
    switch (self.mode) {
        case SCPlaybackModeSequential:
        case SCPlaybackModeShuffle:
            [self changeMode:SCPlaybackModeRepeatAll];
            break;
        case SCPlaybackModeRepeatAll:
            [self changeMode:SCPlaybackModeRepeatOne];
            break;
        case SCPlaybackModeRepeatOne:
            [self changeMode:SCPlaybackModeSequential];
            break;
    }
}

- (void)toggleFavorite {
    NSString *identifier = self.snapshot.track.identifier;
    if (!identifier.length)
        return;
    SCLibraryStore *store = SCLibraryStore.sharedStore;
    [store setSaved:![store containsID:identifier] identifier:identifier];
}

#pragma mark - Private Methods

- (void)changeMode:(SCPlaybackMode)mode {
    if (self.queue.count && self.mode == SCPlaybackModeShuffle) {
        self.index = self.shuffleOrder[self.index].unsignedIntegerValue;
        self.queue = self.originalQueue;
        self.shuffleOrder = nil;
    }
    self.mode = mode;
    if (self.queue.count && mode == SCPlaybackModeShuffle)
        [self shuffleKeepingCurrentTrack];
    [self publish];
}

- (void)shuffleKeepingCurrentTrack {
    // Keep source indexes so duplicate tracks return to the correct position.
    NSMutableArray<NSNumber *> *order = [NSMutableArray arrayWithObject:@(self.index)];
    for (NSUInteger i = 0; i < self.originalQueue.count; i++) {
        if (i != self.index)
            [order addObject:@(i)];
    }
    for (NSUInteger end = order.count - 1; end > 1; end--) {
        NSUInteger other = 1 + arc4random_uniform((uint32_t)end);
        [order exchangeObjectAtIndex:end withObjectAtIndex:other];
    }
    NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:order.count];
    for (NSNumber *position in order)
        [tracks addObject:self.originalQueue[position.unsignedIntegerValue]];
    self.queue = tracks;
    self.shuffleOrder = order;
    self.index = 0;
}

- (void)libraryChanged:(NSNotification *)notification {
    if (self.snapshot.track &&
        self.snapshot.favorite != [SCLibraryStore.sharedStore containsID:self.snapshot.track.identifier])
        [self publish];
}

- (void)recordCurrentTrack {
    SCTrack *track = self.queue[self.index];
    NSMutableArray *ids = [NSMutableArray new];
    if (track.artist.identifier)
        [ids addObject:track.artist.identifier];
    for (SCAlbum *album in SCLocalMusicCatalog.sharedCatalog.albums)
        if ([album.tracks containsObject:track]) {
            [ids addObject:album.identifier];
            break;
        }
    [SCLibraryStore.sharedStore recordPlayedIDs:ids];
}

- (void)refreshSnapshot {
    BOOL favorite = self.index < self.queue.count && [SCLibraryStore.sharedStore
                                                         containsID:self.queue[self.index].identifier];
    _snapshot = [[SCPlaybackSnapshot alloc] initWithQueue:self.queue
                                                    index:self.index
                                                   source:self.source
                                                  playing:self.playing
                                                 progress:self.progress
                                                     mode:self.mode
                                                 favorite:favorite];
}

- (void)advanceClock:(NSTimer *)timer {
    NSTimeInterval now = NSProcessInfo.processInfo.systemUptime;
    self.progress += MAX(0, now - self.lastTick);
    self.lastTick = now;
    if (self.progress >= self.snapshot.duration) {
        if (self.mode == SCPlaybackModeRepeatOne && self.snapshot.duration > 0) {
            self.progress = fmod(self.progress, self.snapshot.duration);
        } else if (self.index + 1 < self.queue.count || self.mode == SCPlaybackModeRepeatAll) {
            [self skipBy:1];
            return;
        } else {
            self.progress = self.snapshot.duration;
            self.playing = NO;
            [self publish];
            return;
        }
    }
    [self refreshSnapshot];
    [NSNotificationCenter.defaultCenter postNotificationName:SCPlaybackProgressDidChange object:self];
}

- (void)publish {
    if (self.playing && !self.clock) {
        self.lastTick = NSProcessInfo.processInfo.systemUptime;
        __weak typeof(self) weakSelf = self;
        self.clock = [NSTimer timerWithTimeInterval:0.25
                                            repeats:YES
                                              block:^(NSTimer *timer) {
                                                  [weakSelf advanceClock:timer];
                                              }];
        [NSRunLoop.mainRunLoop addTimer:self.clock forMode:NSRunLoopCommonModes];
    } else if (!self.playing && self.clock) {
        [self.clock invalidate];
        self.clock = nil;
    }
    [self refreshSnapshot];
    [[NSNotificationCenter defaultCenter] postNotificationName:SCPlaybackDidChangeNotification object:self];
}

@end
