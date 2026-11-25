#import "SCLocalMusicCatalog.h"

@implementation SCLocalMusicCatalog

#pragma mark - Lifecycle

+ (instancetype)sharedCatalog {
    static SCLocalMusicCatalog *catalog;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        catalog = [self new];
    });
    return catalog;
}

- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    // Fictional local fixtures. A future API-backed provider can implement the same protocol.
    NSArray<NSString *> *names = @[
        @"Liked Songs",
        @"Daily Mix 1",
        @"Discover Weekly",
        @"On Repeat",
        @"Chill Vibes",
        @"Night Drive",
        @"Soft Focus",
        @"Fresh Finds",
        @"Golden Hour",
        @"After Hours",
        @"Weekend Energy",
        @"Slow Mornings"
    ];
    NSArray<NSString *> *descriptions = @[
        @"Your favorites, in one place.",
        @"A little familiar. A little new.",
        @"A new world of sound, every week.",
        @"The songs you keep coming back to.",
        @"Take a breath. Find your rhythm.",
        @"For the long way home.",
        @"Less noise. More flow.",
        @"Your next favorite starts here.",
        @"Warm sounds for fading light.",
        @"When the city quiets down.",
        @"Turn up your off-duty hours.",
        @"Ease into a brand-new day."
    ];
    NSMutableArray<SCPlaylist *> *playlists = [NSMutableArray new];
    NSMutableArray<SCTrack *> *tracks = [NSMutableArray new];
    NSMutableArray<SCAlbum *> *albums = [NSMutableArray new];
    NSArray<NSString *> *artistNames =
        @[ @"Luna Park", @"Northbound", @"Mira Sol", @"The Quiet Hours", @"Velvet Coast", @"Daylight Radio" ];
    NSArray<NSArray<NSString *> *> *albumSongs = @[
        @[ @"Somewhere in Blue", @"Window Seat", @"A Thousand Windows", @"The Last Ferry" ],
        @[ @"Last Train Home", @"Signal Lights", @"Platform Nine", @"Between Stations" ],
        @[ @"Stay a Little Longer", @"Marigold", @"East-Facing Room", @"Late Checkout" ],
        @[ @"A Softer World", @"Paperback", @"A Letter in June", @"Sleepwalking" ],
        @[ @"Coastline", @"Salt Air", @"Low Tide", @"Sea Glass" ],
        @[ @"First Light", @"Morning Edition", @"Shortwave", @"After the Rain" ]
    ];
    NSMutableArray<SCTrack *> *featuredTracks = [NSMutableArray new];
    NSArray<NSString *> *albumNames =
        @[ @"Blue Reverie", @"City in Motion", @"Sunroom", @"Between the Lines", @"Coastal Memory", @"A New Day" ];
    for (NSUInteger index = 0; index < artistNames.count; index++) {
        SCArtist *artist = [SCArtist new];
        artist.identifier = [NSString stringWithFormat:@"local-artist-%lu", (unsigned long)index];
        artist.name = artistNames[index];
        SCAlbum *album = [SCAlbum new];
        album.identifier = [NSString stringWithFormat:@"local-album-%lu", (unsigned long)index];
        album.title = albumNames[index];
        // Fictional release years and editorial recommendations in the local catalog.
        album.releaseYear = 2020 + index;
        artist.relatedArtistIDs = @[
            [NSString stringWithFormat:@"local-artist-%lu", (unsigned long)((index + 2) % artistNames.count)],
            [NSString stringWithFormat:@"local-artist-%lu", (unsigned long)((index + 4) % artistNames.count)]
        ];
        album.artist = artist;
        album.subtitle = artist.name;
        album.artworkName = [NSString stringWithFormat:@"SCCover%02lu", (unsigned long)(index + 6)];
        NSMutableArray<SCTrack *> *albumTracks = [NSMutableArray new];
        for (NSString *title in albumSongs[index]) {
            NSUInteger trackID = index + albumTracks.count * artistNames.count;
            SCTrack *track = [SCTrack new];
            track.identifier = [NSString stringWithFormat:@"local-track-%lu", (unsigned long)trackID];
            track.albumIdentifier = album.identifier;
            track.title = title;
            track.artist = artist;
            track.subtitle = artist.name;
            track.duration = 178 + index * 17 + albumTracks.count * 5;
            track.artworkName = album.artworkName;
            [albumTracks addObject:track];
        }
        artist.artworkName = album.artworkName;
        album.tracks = albumTracks;
        [tracks addObjectsFromArray:albumTracks];
        [featuredTracks addObject:albumTracks.firstObject];
        [albums addObject:album];
    }
    for (NSUInteger index = 0; index < names.count; index++) {
        SCPlaylist *playlist = [SCPlaylist new];
        playlist.identifier = [NSString stringWithFormat:@"local-playlist-%lu", (unsigned long)index];
        playlist.title = names[index];
        playlist.subtitle = descriptions[index];
        playlist.artworkName = [NSString stringWithFormat:@"SCCover%02lu", (unsigned long)index];
        playlist.creatorName = index == 0 ? @"You" : (index < 6 ? @"Studio Selects" : @"The Listening Room");
        NSMutableArray<SCTrack *> *playlistTracks = [NSMutableArray new];
        NSUInteger songCount = 16 + index % 5;
        for (NSUInteger position = 0; position < songCount; position++) {
            // Step across albums while keeping every track in this playlist unique.
            [playlistTracks addObject:tracks[(index * 7 + position * 5) % tracks.count]];
        }
        playlist.tracks = playlistTracks;
        [playlists addObject:playlist];
    }

    _tracks = tracks.copy;
    _albums = albums.copy;
    _artists = [albums valueForKey:@"artist"];
    _featuredTracks = featuredTracks.copy;
    _playlists = playlists.copy;
    return self;
}

@end
