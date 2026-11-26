//
//  SCNeteaseMusicService.m
//  Spotify
//
//  Created by MacBook Air on 2026/11/25.
//

#import "SCNeteaseMusicService.h"

#import "SCNetworkClient.h"
#import "SCPlaylist.h"
#import "SCAlbum.h"
#import <CoreFoundation/CoreFoundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const SCMusicServiceErrorDomain = @"SCNeteaseMusicServiceErrorDomain";
static NSString *const SCAPIResponseCodeKey = @"SCAPIResponseCode";

typedef NS_ENUM(NSInteger, SCMusicServiceErrorCode) {
    SCMusicServiceErrorInvalidResponse = 1,
    SCMusicServiceErrorAPIRejected,
};

static NSError *SCInvalidResponseError(NSString *description) {
    return [NSError errorWithDomain:SCMusicServiceErrorDomain
                               code:SCMusicServiceErrorInvalidResponse
                           userInfo:@{NSLocalizedDescriptionKey : description}];
}

static BOOL SCValidID(id value) {
    if (![value isKindOfClass:NSNumber.class] || CFGetTypeID((__bridge CFTypeRef)value) == CFBooleanGetTypeID() ||
        [value compare:@0] != NSOrderedDescending) return NO;
    if ([value isKindOfClass:NSDecimalNumber.class]) {
        return [[value stringValue] rangeOfCharacterFromSet:
            [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]].location == NSNotFound;
    }
    return !CFNumberIsFloatType((__bridge CFNumberRef)value);
}

static BOOL SCValidIdentifier(NSString *identifier) {
    return identifier.length && [identifier characterAtIndex:0] != '0' &&
        [identifier rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]].location == NSNotFound;
}

static NSURL * _Nullable SCArtworkURL(id raw) {
    if (![raw isKindOfClass:NSString.class]) return nil;
    NSURLComponents *parts = [NSURLComponents componentsWithString:raw];
    if (!parts.host.length) return nil;
    if ([parts.scheme.lowercaseString isEqual:@"http"] && [parts.host.lowercaseString hasSuffix:@".music.126.net"])
        parts.scheme = @"https";
    return [parts.scheme.lowercaseString isEqual:@"https"] ? parts.URL : nil;
}

@interface SCRecommendedPlaylistDTO : NSObject <YYModel>

@property (nonatomic, strong) NSNumber *playlistID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSURL *artworkURL;

- (SCPlaylist *)playlist;

@end

@implementation SCRecommendedPlaylistDTO

#pragma mark - Public Methods

- (SCPlaylist *)playlist {
    SCPlaylist *playlist = [[SCPlaylist alloc] init];
    playlist.remote = YES;
    playlist.identifier = self.playlistID.stringValue;
    playlist.title = self.title;
    playlist.artworkURL = self.artworkURL;
    playlist.artworkName = @"SCCover00";
    return playlist;
}

#pragma mark - YYModel

+ (nullable NSDictionary *)modelCustomPropertyMapper {
    return @{@"playlistID" : @"id", @"title" : @"name"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dictionary {
    id rawID = dictionary[@"id"];
    id rawName = dictionary[@"name"];
    if (!SCValidID(rawID) || ![rawName isKindOfClass:NSString.class]) return NO;
    self.artworkURL = SCArtworkURL(dictionary[@"picUrl"]);
    self.title = [self.title stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return self.title.length > 0;
}

@end

// Both artist credits and album summaries contain id/name pairs.
@interface SCNeteaseCreditDTO : NSObject <YYModel>
@property (nonatomic, strong) NSNumber *sourceID;
@property (nonatomic, copy) NSString *name;
@end
@implementation SCNeteaseCreditDTO
+ (nullable NSDictionary *)modelCustomPropertyMapper { return @{@"sourceID": @"id"}; }
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)row {
    return [row[@"name"] isKindOfClass:NSString.class] && self.name.length > 0;
}
@end

@interface SCNeteaseTrackDTO : NSObject <YYModel>
@property (nonatomic, strong) NSNumber *sourceID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray<SCNeteaseCreditDTO *> *artists;
@property (nonatomic, strong) SCNeteaseCreditDTO *album;
@property (nonatomic, strong) NSNumber *milliseconds;
@property (nonatomic, copy) NSString *picture;
@end
@implementation SCNeteaseTrackDTO
+ (nullable NSDictionary *)modelCustomPropertyMapper {
    return @{@"sourceID": @"id", @"artists": @"ar", @"album": @"al", @"milliseconds": @"dt", @"picture": @"al.picUrl"};
}
+ (nullable NSDictionary *)modelContainerPropertyGenericClass { return @{@"artists": SCNeteaseCreditDTO.class}; }
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)row {
    if (!SCValidID(row[@"id"]) || ![row[@"name"] isKindOfClass:NSString.class] || !self.name.length) return NO;
    id duration = row[@"dt"];
    if (duration && duration != NSNull.null &&
        (![duration isKindOfClass:NSNumber.class] || CFGetTypeID((__bridge CFTypeRef)duration)==CFBooleanGetTypeID() ||
         [duration doubleValue]<0)) return NO;
    id credits = row[@"ar"];
    if (credits && credits != NSNull.null && (![credits isKindOfClass:NSArray.class] || [credits count]!=self.artists.count)) return NO;
    id album = row[@"al"];
    return !album || album == NSNull.null || [album isKindOfClass:NSDictionary.class];
}
- (SCTrack *)track {
    SCTrack *track = [SCTrack new];
    track.identifier = self.sourceID.stringValue;
    track.title = self.name;
    NSMutableArray *credits = [NSMutableArray array];
    for (SCNeteaseCreditDTO *dto in self.artists) {
        SCArtist *artist = [SCArtist new];
        artist.identifier = SCValidID(dto.sourceID) ? dto.sourceID.stringValue : @"";
        artist.name = dto.name;
        [credits addObject:artist];
    }
    track.artists = credits;
    track.artist = credits.firstObject;
    track.subtitle = [[credits valueForKey:@"name"] componentsJoinedByString:@", "];
    if (self.album.name.length) {
        SCAlbum *album = [SCAlbum new];
        album.title = self.album.name;
        album.identifier = SCValidID(self.album.sourceID) ? self.album.sourceID.stringValue : @"";
        track.album = album;
        track.albumIdentifier = album.identifier;
    }
    track.duration = self.milliseconds.doubleValue / 1000.0;
    track.artworkName = @"SCCover00";
    track.artworkURL = SCArtworkURL(self.picture);
    return track;
}
@end

static NSArray<SCTrack *> * _Nullable SCMapTracks(id rows) {
    if (![rows isKindOfClass:NSArray.class]) return nil;
    NSArray *dtos = [NSArray yy_modelArrayWithClass:SCNeteaseTrackDTO.class json:rows];
    if (!dtos || dtos.count != [rows count]) return nil;
    NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:dtos.count];
    for (SCNeteaseTrackDTO *dto in dtos) [tracks addObject:[dto track]];
    return tracks.copy;
}

@implementation SCNeteaseMusicService

#pragma mark - Public Methods

- (nullable NSURLSessionTask *)fetchRecommendedPlaylistWithLimit:(NSUInteger)limit
                                                         success:(SCRecommendPlaylistSuccessBlock)success
                                                         failure:(SCMusicServiceFailureBlock)failure {
    return [self getPath:@"personalized" parameters:@{@"limit": @(limit)} success:^(NSDictionary *json) {
            id result = json[@"result"];
            if (![result isKindOfClass:NSArray.class]) {
                failure(SCInvalidResponseError(@"Expected a playlist array in result."));
                return;
            }
            NSArray *rows = result;
            NSMutableArray<SCPlaylist *> *playlists = [NSMutableArray arrayWithCapacity:rows.count];
            for (id row in rows) {
                SCRecommendedPlaylistDTO *dto = [row isKindOfClass:NSDictionary.class]
                                                    ? [SCRecommendedPlaylistDTO yy_modelWithDictionary:row]
                                                    : nil;
                if (!dto) {
                    NSString *message = [NSString stringWithFormat:@"Invalid recommended playlist at result[%lu].",
                                                                   (unsigned long)playlists.count];
                    failure(SCInvalidResponseError(message));
                    return;
                }
                [playlists addObject:[dto playlist]];
            }
            success([playlists copy]);
        }
        failure:failure];
}

- (nullable NSURLSessionTask *)fetchPlaylist:(NSString *)identifier success:(void (^)(SCPlaylist *))success
                                    failure:(SCMusicServiceFailureBlock)failure {
    if (!SCValidIdentifier(identifier)) { failure(SCInvalidResponseError(@"Invalid playlist ID.")); return nil; }
    return [self getPath:@"playlist/detail" parameters:@{@"id": identifier} success:^(NSDictionary *json) {
        NSDictionary *row = json[@"playlist"];
        SCRecommendedPlaylistDTO *dto = [row isKindOfClass:NSDictionary.class] ?
            [SCRecommendedPlaylistDTO yy_modelWithDictionary:row] : nil;
        if (!dto || ![dto.playlistID.stringValue isEqual:identifier]) {
            failure(SCInvalidResponseError(@"Unexpected playlist metadata.")); return;
        }
        SCPlaylist *playlist = [dto playlist];
        playlist.subtitle = [row[@"description"] isKindOfClass:NSString.class] ? row[@"description"] : @"";
        id creator = row[@"creator"];
        id nickname = [creator isKindOfClass:NSDictionary.class] ? creator[@"nickname"] : nil;
        playlist.creatorName = [nickname isKindOfClass:NSString.class] ? nickname : @"";
        playlist.artworkURL = SCArtworkURL(row[@"coverImgUrl"]);
        id total = row[@"trackCount"];
        if (SCValidID(total) || ([total isKindOfClass:NSNumber.class] && CFGetTypeID((__bridge CFTypeRef)total)!=CFBooleanGetTypeID() && [total isEqual:@0])) playlist.trackCount = total;
        NSArray *tracks = SCMapTracks(row[@"tracks"]);
        NSArray *ids = row[@"trackIds"];
        // An incomplete preview may omit unavailable entries. Only reuse a verified ordered prefix.
        if ([ids isKindOfClass:NSArray.class] && tracks.count <= ids.count) {
            NSUInteger prefix = 0;
            for (SCTrack *track in tracks) {
                id entry = ids[prefix];
                id sourceID = [entry isKindOfClass:NSDictionary.class] ? entry[@"id"] : nil;
                if (!SCValidID(sourceID) || ![[sourceID stringValue] isEqual:track.identifier]) break;
                prefix++;
            }
            playlist.tracks = [tracks subarrayWithRange:NSMakeRange(0,prefix)] ?: @[];
        }
        success(playlist);
    } failure:failure];
}

- (nullable NSURLSessionTask *)fetchTracksForPlaylist:(NSString *)identifier limit:(NSUInteger)limit
                                              offset:(NSUInteger)offset success:(void (^)(NSArray<SCTrack *> *))success
                                             failure:(SCMusicServiceFailureBlock)failure {
    if (!SCValidIdentifier(identifier) || !limit) { failure(SCInvalidResponseError(@"Invalid playlist page.")); return nil; }
    return [self getPath:@"playlist/track/all" parameters:@{@"id":identifier,@"limit":@(limit),@"offset":@(offset)}
        success:^(NSDictionary *json) {
            NSArray *tracks = SCMapTracks(json[@"songs"]);
            if (!tracks || tracks.count > limit) { failure(SCInvalidResponseError(@"Invalid songs page.")); return; }
            success(tracks);
        } failure:failure];
}

#pragma mark - Private Methods

- (nullable NSURLSessionTask *)getPath:(NSString *)path parameters:(NSDictionary *)parameters
                                success:(void (^)(NSDictionary *))success failure:(SCMusicServiceFailureBlock)failure {
    return [SCNetworkClient GET:path
        parameters:parameters
        success:^(NSHTTPURLResponse *_Nullable response, id _Nullable responseObject) {
            if (![responseObject isKindOfClass:NSDictionary.class]) {
                failure(SCInvalidResponseError(@"Expected a JSON object from music service."));
                return;
            }
            NSDictionary *json = responseObject;
            id code = json[@"code"];
            if (![code isKindOfClass:NSNumber.class] || CFGetTypeID((__bridge CFTypeRef)code) == CFBooleanGetTypeID()) {
                failure(SCInvalidResponseError(@"Expected a numeric API code."));
                return;
            }
            if (![code isEqualToNumber:@200]) {
                NSString *description =
                    [NSString stringWithFormat:@"Music request returned API code %@", code];
                NSError *error =
                    [NSError errorWithDomain:SCMusicServiceErrorDomain
                                        code:SCMusicServiceErrorAPIRejected
                                    userInfo:@{NSLocalizedDescriptionKey : description, SCAPIResponseCodeKey : code}];
                failure(error);
                return;
            }
            success(json);
        } failure:^(NSHTTPURLResponse * _Nullable response, NSError *error) { failure(error); }];
}
@end
NS_ASSUME_NONNULL_END
