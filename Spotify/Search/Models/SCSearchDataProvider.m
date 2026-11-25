#import "SCSearchDataProvider.h"

@implementation SCSearchDataProvider

#pragma mark - Public Methods

+ (NSArray<NSString *> *)categories {
    return @[
        @"Pop",
        @"Hip-Hop",
        @"Rock",
        @"Electronic",
        @"Jazz",
        @"Classical",
        @"R&B",
        @"Chill",
        @"Workout",
        @"Indie",
        @"Podcasts",
        @"Focus"
    ];
}

- (void)search:(NSString *)query
      category:(NSString *)category
        filter:(NSString *)filter
    completion:(void (^)(SCSearchResultModel *))completion {
    SCLocalMusicCatalog *catalog = SCLocalMusicCatalog.sharedCatalog;
    // Editorial tags for the local releases and playlists; podcasts have no local episodes.
    NSArray *albumTags = @[
        @"Pop Jazz Chill",
        @"Rock Indie Workout",
        @"Pop R&B",
        @"Classical Focus Chill",
        @"Indie Jazz R&B",
        @"Hip-Hop Electronic Workout"
    ];
    NSArray *playlistTags = @[
        @"Pop Indie",
        @"Hip-Hop Pop",
        @"Indie Rock",
        @"Pop Workout",
        @"Chill Jazz",
        @"Electronic R&B",
        @"Classical Focus",
        @"Indie Hip-Hop",
        @"Jazz R&B",
        @"Electronic Chill",
        @"Rock Workout",
        @"Classical Chill"
    ];
    NSMutableArray *items = [NSMutableArray new];
    for (NSUInteger i = 0; i < catalog.albums.count; i++) {
        if (category.length && ![[albumTags[i] componentsSeparatedByString:@" "] containsObject:category])
            continue;
        SCAlbum *album = catalog.albums[i];
        if ([filter isEqual:@"All"] || [filter isEqual:@"Songs"])
            [items addObjectsFromArray:album.tracks];
        if ([filter isEqual:@"All"] || [filter isEqual:@"Artists"])
            [items addObject:album.artist];
        if ([filter isEqual:@"All"] || [filter isEqual:@"Albums"])
            [items addObject:album];
    }
    if ([filter isEqual:@"All"] || [filter isEqual:@"Playlists"]) {
        for (NSUInteger i = 0; i < catalog.playlists.count; i++) {
            if (!category.length || [[playlistTags[i] componentsSeparatedByString:@" "] containsObject:category])
                [items addObject:catalog.playlists[i]];
        }
    }
    NSString *term = [query stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (term.length) {
        [items
            filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<SCMusicItem> item, NSDictionary *bindings) {
                return [item.title localizedCaseInsensitiveContainsString:term] ||
                       ([(NSObject *)item isKindOfClass:SCTrack.class] &&
                        [((SCTrack *)item).artist.name localizedCaseInsensitiveContainsString:term]) ||
                       ([(NSObject *)item isKindOfClass:SCAlbum.class] &&
                        [((SCAlbum *)item).artist.name localizedCaseInsensitiveContainsString:term]);
            }]];
    }
    completion([[SCSearchResultModel alloc] initWithItems:items]);
}

@end
