#import "SCAlbum.h"
#import "SCPlaylist.h"

@interface SCLocalMusicCatalog : NSObject
@property (class, nonatomic, readonly) SCLocalMusicCatalog *sharedCatalog;
@property (nonatomic, copy, readonly) NSArray<SCTrack *> *tracks;
@property (nonatomic, copy, readonly) NSArray<SCAlbum *> *albums;
@property (nonatomic, copy, readonly) NSArray<SCPlaylist *> *playlists;
@property (nonatomic, copy, readonly) NSArray<SCArtist *> *artists;
@property (nonatomic, copy, readonly) NSArray<SCTrack *> *featuredTracks;
@end
