#import "SCAlbumDetailModel.h"

@implementation SCAlbumDetailModel

#pragma mark - Lifecycle

- (instancetype)initWithAlbum:(SCAlbum *)album {
    if ((self = [super init])) {
        _album = album;
        _releaseInfo = album.releaseYear
                           ? [NSString stringWithFormat:@"%@  ·  %ld", album.releaseType, (long)album.releaseYear]
                           : album.releaseType;
        NSUInteger total = 0;
        for (SCTrack *track in album.tracks)
            total += MAX(0, track.duration);
        _summary = [NSString stringWithFormat:@"%lu %@  ·  %lu min %lu sec",
                                              (unsigned long)album.tracks.count,
                                              album.tracks.count == 1 ? @"song" : @"songs",
                                              (unsigned long)(total / 60),
                                              (unsigned long)(total % 60)];
    }
    return self;
}

@end
