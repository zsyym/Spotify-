#import "SCRemoteHomeProvider.h"
#import "SCNeteaseMusicService.h"
#import "SCPlaylist.h"

static const NSUInteger SCRecommendationLimit = 6;

@interface SCRemoteHomeProvider ()
@property (nonatomic, strong) id<SCRecommendedPlaylistProviding> service;
@property (nonatomic, strong, nullable) NSURLSessionTask *task;
@property (nonatomic, assign) NSUInteger generation;
@end

@implementation SCRemoteHomeProvider

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithService:[SCNeteaseMusicService new]];
}

- (instancetype)initWithService:(id<SCRecommendedPlaylistProviding>)service {
    if ((self = [super init])) {
        _service = service;
    }
    return self;
}

- (void)dealloc {
    [_task cancel];
}

#pragma mark - Public Methods

- (void)loadSectionsWithCompletion:(SCHomeSectionsCompletion)completion {
    [self cancelLoading];
    NSUInteger generation = self.generation;
    __weak typeof(self) weakSelf = self;
    void (^deliver)(NSArray<SCPlaylist *> *, NSError *) = ^(NSArray<SCPlaylist *> *playlists, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || generation != self.generation) {
                return;
            }
            self.generation++;
            self.task = nil;
            completion(error ? @[] : [SCHomeDataProvider sectionsWithRecommendedPlaylists:playlists], error);
        });
    };
    self.task = [self.service fetchRecommendedPlaylistWithLimit:SCRecommendationLimit
        success:^(NSArray<SCPlaylist *> *playlists) {
            deliver(playlists, nil);
        }
        failure:^(NSError *error) {
            deliver(nil, error);
        }];
}

- (void)cancelLoading {
    NSAssert(NSThread.isMainThread, @"Load and cancel home requests on the main thread.");
    self.generation++;
    [self.task cancel];
    self.task = nil;
}

@end
