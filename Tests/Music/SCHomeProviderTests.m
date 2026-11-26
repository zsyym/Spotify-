#import "SCRemoteHomeProvider.h"
#import "SCNeteaseMusicService.h"
#import "SCPlaylist.h"

@interface SCControlledMusicService : NSObject <SCRecommendedPlaylistProviding>
@property (nonatomic, copy) SCRecommendPlaylistSuccessBlock success;
@property (nonatomic, copy) SCMusicServiceFailureBlock failure;
@property (nonatomic, strong) NSURLSessionTask *task;
@end

@implementation SCControlledMusicService

- (NSURLSessionTask *)fetchRecommendedPlaylistWithLimit:(NSUInteger)limit
                                                success:(SCRecommendPlaylistSuccessBlock)success
                                                failure:(SCMusicServiceFailureBlock)failure {
    NSCAssert(limit == 6, @"Expected six recommendations");
    self.success = success;
    self.failure = failure;
    // Suspended task supplies real cancellation semantics without sending a request.
    self.task = [NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:@"https://example.invalid/"]];
    return self.task;
}

@end

static void drainMainQueue(void) {
    __block BOOL drained = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        drained = YES;
    });
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:2];
    while (!drained && deadline.timeIntervalSinceNow > 0) {
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
    }
    NSCAssert(drained, @"Main queue stalled");
}

void SCRunHomeProviderTests(void) {
    SCControlledMusicService *service = [SCControlledMusicService new];
    SCRemoteHomeProvider *remote = [[SCRemoteHomeProvider alloc] initWithService:service];
    id<SCHomeDataProviding> source = remote;
    __block NSArray<SCHomeSectionModel *> *local;
    [[SCHomeDataProvider new] loadSectionsWithCompletion:^(NSArray *sections, NSError *error) {
        NSCAssert(!error, @"Local catalog failed");
        local = sections;
    }];
    SCPlaylist *playlist = [SCPlaylist new];
    playlist.identifier = @"9007199254740993";
    playlist.title = @"Remote";
    playlist.artworkURL = [NSURL URLWithString:@"https://example.invalid/art.jpg"];
    __block NSArray<SCHomeSectionModel *> *result;
    __block NSError *received;
    __block NSUInteger calls = 0;
    SCHomeSectionsCompletion record = ^(NSArray *sections, NSError *error) {
        NSCAssert(NSThread.isMainThread, @"Expected main-thread delivery");
        calls++;
        result = sections;
        received = error;
    };
    [source loadSectionsWithCompletion:record];
    NSURLSessionTask *first = service.task;
    SCRecommendPlaylistSuccessBlock stale = service.success;
    [source loadSectionsWithCompletion:record];
    NSCAssert(first.state != NSURLSessionTaskStateSuspended, @"Superseded task must be cancelled");
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        service.success(@[ playlist ]);
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    stale(@[]);
    drainMainQueue();
    NSCAssert(calls == 1 && !received && result.count == 5 && local.count == 5, @"Latest load must win");
    for (NSUInteger i = 0; i < result.count; i++) {
        NSCAssert([local[i].title isEqual:result[i].title] && local[i].kind == result[i].kind,
                  @"Section order changed");
        if (i < 4) {
            NSCAssert([local[i].items isEqual:result[i].items], @"Local section content changed");
        }
    }
    NSCAssert(local.lastObject.items.count == 6 && result.lastObject.items.count == 1 &&
                  result.lastObject.items.firstObject == playlist,
              @"Must preserve remote item identity");
    [source loadSectionsWithCompletion:record];
    service.success(@[]);
    drainMainQueue();
    NSCAssert(calls == 2 && !received && result.count == 5 && !result.lastObject.items.count, @"Empty contract");
    NSError *expected = [NSError errorWithDomain:@"Test" code:1 userInfo:nil];
    [source loadSectionsWithCompletion:record];
    service.failure(expected);
    drainMainQueue();
    NSCAssert(calls == 3 && received == expected && !result.count, @"Error must propagate");
    [source loadSectionsWithCompletion:record];
    service.success(@[ playlist ]);
    [remote cancelLoading];
    service.failure(expected);
    drainMainQueue();
    NSCAssert(calls == 3 && service.task.state != NSURLSessionTaskStateSuspended, @"Cancelled callback escaped");
    [source loadSectionsWithCompletion:record];
    __weak SCRemoteHomeProvider *weakProvider = remote;
    remote = nil;
    source = nil;
    service.success(@[ playlist ]);
    drainMainQueue();
    NSCAssert(!weakProvider && calls == 3 && service.task.state != NSURLSessionTaskStateSuspended,
              @"Provider lifetime");
    puts("Home provider checks passed.");
}
