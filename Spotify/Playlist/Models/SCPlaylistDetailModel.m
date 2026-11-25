#import "SCPlaylistDetailModel.h"

@implementation SCPlaylistDetailModel

#pragma mark - Lifecycle

- (instancetype)initWithPlaylist:(SCPlaylist *)playlist {
    if ((self = [super init])) {
        _playlist = playlist;
    }
    return self;
}

#pragma mark - Getters

- (NSString *)trackSummary {
    NSTimeInterval duration = 0;
    for (SCTrack *track in self.playlist.tracks) {
        duration += track.duration;
    }
    NSUInteger count = self.playlist.tracks.count;
    NSString *countText = [NSString stringWithFormat:@"%lu %@", (unsigned long)count, count == 1 ? @"song" : @"songs"];
    return duration >= 60 ? [countText stringByAppendingFormat:@"  ·  %ld min", (long)(duration / 60)] : countText;
}

@end
