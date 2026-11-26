//
//  SCNeteaseMusicService.h
//  Spotify
//
//  Created by MacBook Air on 2026/11/25.
//

#import <Foundation/Foundation.h>

@class SCPlaylist, SCTrack;

NS_ASSUME_NONNULL_BEGIN

typedef void (^SCRecommendPlaylistSuccessBlock)(NSArray<SCPlaylist *> *playlists);
typedef void (^SCMusicServiceFailureBlock)(NSError *error);

@protocol SCRecommendedPlaylistProviding <NSObject>

- (nullable NSURLSessionTask *)fetchRecommendedPlaylistWithLimit:(NSUInteger)limit
                                                         success:(SCRecommendPlaylistSuccessBlock)success
                                                         failure:(SCMusicServiceFailureBlock)failure;

@end

@protocol SCPlaylistDetailProviding <NSObject>
- (nullable NSURLSessionTask *)fetchPlaylist:(NSString *)identifier
                                    success:(void (^)(SCPlaylist *playlist))success
                                    failure:(SCMusicServiceFailureBlock)failure;
- (nullable NSURLSessionTask *)fetchTracksForPlaylist:(NSString *)identifier
                                               limit:(NSUInteger)limit
                                              offset:(NSUInteger)offset
                                             success:(void (^)(NSArray<SCTrack *> *tracks))success
                                             failure:(SCMusicServiceFailureBlock)failure;
@end

@interface SCNeteaseMusicService : NSObject <SCRecommendedPlaylistProviding, SCPlaylistDetailProviding>
@end

NS_ASSUME_NONNULL_END
