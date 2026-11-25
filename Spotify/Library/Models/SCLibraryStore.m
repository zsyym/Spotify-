#import "SCLibraryStore.h"

NSNotificationName const SCLibraryDidChange = @"SCLibraryDidChange";
static NSString *const SCSavedKey = @"SCLibrarySaved.v1";
static NSString *const SCPlayedKey = @"SCLibraryPlayed.v1";

@interface SCLibraryStore ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *addedDates;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *playedDates;
@end
@implementation SCLibraryStore

#pragma mark - Lifecycle

+ (instancetype)sharedStore {
    static SCLibraryStore *store;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        store = [self new];
    });
    return store;
}

- (instancetype)init {
    if ((self = [super init])) {
        NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
        NSDictionary *initial = @{
            @"local-playlist-0" : @8,
            @"local-playlist-4" : @6,
            @"local-album-1" : @5,
            @"local-artist-4" : @4,
            @"local-playlist-2" : @3,
            @"local-album-3" : @2,
            @"local-artist-1" : @1
        };
        _addedDates = ([defaults dictionaryForKey:SCSavedKey] ?: initial).mutableCopy;
        SCPlaylist *liked = SCLocalMusicCatalog.sharedCatalog.playlists.firstObject;
        if (![defaults dictionaryForKey:SCSavedKey]) {
            for (SCTrack *track in liked.tracks)
                _addedDates[track.identifier] = @1;
        }
        [self updateLikedSongs];
        _playedDates = ([defaults dictionaryForKey:SCPlayedKey]
                            ?: @{@"local-album-3" : @4, @"local-playlist-4" : @3, @"local-artist-1" : @2})
                           .mutableCopy;
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)containsID:(NSString *)identifier {
    return self.addedDates[identifier] != nil;
}

- (void)setSaved:(BOOL)saved identifier:(NSString *)identifier {
    if (!identifier.length || saved == [self containsID:identifier])
        return;
    if (saved)
        self.addedDates[identifier] = @(NSDate.date.timeIntervalSince1970);
    else
        [self.addedDates removeObjectForKey:identifier];
    if ([SCLocalMusicCatalog.sharedCatalog.tracks
            indexOfObjectPassingTest:^BOOL(SCTrack *track, NSUInteger index, BOOL *stop) {
                return [track.identifier isEqual:identifier];
            }] != NSNotFound)
        [self updateLikedSongs];
    [NSUserDefaults.standardUserDefaults setObject:self.addedDates forKey:SCSavedKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:SCLibraryDidChange
                                                        object:self
                                                      userInfo:@{@"savedIdentifier" : identifier}];
}

- (void)recordPlayedIDs:(NSArray<NSString *> *)identifiers {
    NSNumber *now = @(NSDate.date.timeIntervalSince1970);
    for (NSString *identifier in identifiers)
        self.playedDates[identifier] = now;
    [NSUserDefaults.standardUserDefaults setObject:self.playedDates forKey:SCPlayedKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:SCLibraryDidChange object:self];
}

- (NSArray<SCLibraryItemModel *> *)itemsForFilter:(NSString *)filter query:(NSString *)query sort:(NSString *)sort {
    SCLocalMusicCatalog *catalog = SCLocalMusicCatalog.sharedCatalog;
    NSMutableArray *results = [NSMutableArray new];
    NSArray *groups = @[ catalog.playlists, catalog.artists, catalog.albums ];
    NSArray *types = @[ @"Playlists", @"Artists", @"Albums" ];
    NSSet *offlineSamples = [NSSet setWithArray:@[ @"local-playlist-4", @"local-album-1" ]];
    for (NSUInteger i = 0; i < groups.count; i++) {
        if (filter.length && ![filter isEqual:@"Downloaded"] && ![filter isEqual:types[i]])
            continue;
        for (id<SCMusicItem> item in groups[i]) {
            if (![self containsID:item.identifier])
                continue;
            BOOL offline = [offlineSamples containsObject:item.identifier];
            if ([filter isEqual:@"Downloaded"] && !offline)
                continue;
            if (query.length && ![item.title localizedCaseInsensitiveContainsString:query] &&
                ![item.subtitle localizedCaseInsensitiveContainsString:query])
                continue;
            SCLibraryItemModel *row = [SCLibraryItemModel new];
            row.item = item;
            row.downloaded = offline;
            row.added = self.addedDates[item.identifier].doubleValue;
            row.played = self.playedDates[item.identifier].doubleValue;
            [results addObject:row];
        }
    }
    [results sortUsingComparator:^NSComparisonResult(SCLibraryItemModel *a, SCLibraryItemModel *b) {
        if (![sort isEqual:@"Alphabetical"]) {
            double x = [sort isEqual:@"Recently Played"] ? a.played : a.added;
            double y = [sort isEqual:@"Recently Played"] ? b.played : b.added;
            if (x != y)
                return x > y ? NSOrderedAscending : NSOrderedDescending;
        }
        return [a.item.title localizedCaseInsensitiveCompare:b.item.title];
    }];
    return results;
}

#pragma mark - Private Methods

- (void)updateLikedSongs {
    SCLocalMusicCatalog *catalog = SCLocalMusicCatalog.sharedCatalog;
    NSMutableArray *tracks = [NSMutableArray new];
    for (SCTrack *track in catalog.tracks)
        if ([self containsID:track.identifier])
            [tracks addObject:track];
    catalog.playlists.firstObject.tracks = tracks;
}

@end
