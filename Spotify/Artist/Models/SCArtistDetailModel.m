#import "SCArtistDetailModel.h"

@implementation SCArtistDetailModel

#pragma mark - Lifecycle

- (instancetype)initWithArtist:(SCArtist *)artist catalog:(SCLocalMusicCatalog *)catalog {
    if ((self = [super init])) {
        _artist = artist;
        NSMutableArray *releases = [NSMutableArray new], *albums = [NSMutableArray new],
                       *singles = [NSMutableArray new], *tracks = [NSMutableArray new], *related = [NSMutableArray new];
        for (SCAlbum *album in catalog.albums) {
            if (![album.artist.identifier isEqual:artist.identifier])
                continue;
            [releases addObject:album];
            if ([album.releaseType isEqual:@"Single"] || [album.releaseType isEqual:@"EP"])
                [singles addObject:album];
            else
                [albums addObject:album];
        }
        for (SCTrack *track in catalog.tracks)
            if ([track.artist.identifier isEqual:artist.identifier])
                [tracks addObject:track];
        for (SCArtist *candidate in catalog.artists)
            if ([artist.relatedArtistIDs containsObject:candidate.identifier] &&
                ![candidate.identifier isEqual:artist.identifier])
                [related addObject:candidate];
        _albums = albums.copy;
        _releases = releases.copy;
        _singles = singles.copy;
        _popular = tracks.copy;
        _related = related.copy;
        _about = [NSString
            stringWithFormat:
                @"%@ is a fictional artist in the local catalog. This collection features %lu %@ across %lu %@.",
                artist.name,
                (unsigned long)tracks.count,
                tracks.count == 1 ? @"track" : @"tracks",
                (unsigned long)releases.count,
                releases.count == 1 ? @"release" : @"releases"];
    }
    return self;
}

@end
