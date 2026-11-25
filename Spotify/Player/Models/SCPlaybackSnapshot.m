#import "SCPlaybackSnapshot.h"

@implementation SCPlaybackSnapshot

#pragma mark - Lifecycle

- (instancetype)initWithQueue:(NSArray<SCTrack *> *)queue
                        index:(NSUInteger)index
                       source:(NSString *)source
                      playing:(BOOL)playing
                     progress:(NSTimeInterval)progress
                         mode:(SCPlaybackMode)mode
                     favorite:(BOOL)favorite {
    if ((self = [super init])) {
        _queue = [queue copy];
        _index = index;
        _track = index < queue.count ? queue[index] : nil;
        _duration = MAX(0, _track.duration);
        _source = [source copy];
        _playing = playing;
        _progress = progress;
        _mode = mode;
        _favorite = favorite;
    }
    return self;
}

@end
