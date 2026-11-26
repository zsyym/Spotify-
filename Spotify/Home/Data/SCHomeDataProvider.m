#import "SCHomeDataProvider.h"
#import "SCPlaylist.h"
#import "SCLocalMusicCatalog.h"
#import "SCTrack.h"

@implementation SCHomeDataProvider

#pragma mark - Public Methods

- (void)loadSectionsWithCompletion:(SCHomeSectionsCompletion)completion {
    NSArray *recommendations = [SCLocalMusicCatalog.sharedCatalog.playlists subarrayWithRange:NSMakeRange(6, 6)];
    completion([SCHomeDataProvider sectionsWithRecommendedPlaylists:recommendations], nil);
}

+ (NSArray<SCHomeSectionModel *> *)sectionsWithRecommendedPlaylists:(NSArray<SCPlaylist *> *)playlists {
    SCLocalMusicCatalog *catalog = SCLocalMusicCatalog.sharedCatalog;
    return @[
        [[SCHomeSectionModel alloc] initWithTitle:@""
                                             kind:SCHomeSectionKindShortcuts
                                            items:[catalog.playlists subarrayWithRange:NSMakeRange(0, 6)]],
        [[SCHomeSectionModel alloc] initWithTitle:@"Made For You"
                                             kind:SCHomeSectionKindPlaylists
                                            items:[catalog.playlists subarrayWithRange:NSMakeRange(1, 5)]],
        [[SCHomeSectionModel alloc] initWithTitle:@"Recently Played" kind:SCHomeSectionKindAlbums items:catalog.albums],
        [[SCHomeSectionModel alloc] initWithTitle:@"Jump Back In"
                                             kind:SCHomeSectionKindTracks
                                            items:[catalog.featuredTracks subarrayWithRange:NSMakeRange(0, 4)]],
        [[SCHomeSectionModel alloc] initWithTitle:@"Recommended For Today"
                                             kind:SCHomeSectionKindPlaylists
                                            items:playlists]
    ];
}

@end
