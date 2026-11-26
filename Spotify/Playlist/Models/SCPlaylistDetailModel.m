#import "SCPlaylistDetailModel.h"

@implementation SCPlaylistDetailModel

#pragma mark - Lifecycle

- (instancetype)initWithPlaylist:(SCPlaylist *)playlist {
    if ((self = [super init])) {
        _playlist = playlist;
        _tracks = playlist.tracks;
    }
    return self;
}

#pragma mark - Getters

- (NSString *)trackSummary {
    if (self.playlist.remote) {
        return self.playlist.trackCount ? [NSString stringWithFormat:@"%@ songs · %lu loaded", self.playlist.trackCount,
            (unsigned long)self.tracks.count] : [NSString stringWithFormat:@"%lu songs loaded",(unsigned long)self.tracks.count];
    }
    NSTimeInterval duration = 0;
    for (SCTrack *track in self.playlist.tracks) {
        duration += track.duration;
    }
    NSUInteger count = self.playlist.tracks.count;
    NSString *countText = [NSString stringWithFormat:@"%lu %@", (unsigned long)count, count == 1 ? @"song" : @"songs"];
    return duration >= 60 ? [countText stringByAppendingFormat:@"  ·  %ld min", (long)(duration / 60)] : countText;
}

@end
