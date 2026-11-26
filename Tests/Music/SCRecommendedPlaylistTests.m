#import "SCNeteaseMusicService.h"
#import "SCNetworkClient.h"
#import "SCPlaylist.h"
#import "SCRemoteHomeProvider.h"

extern void SCRunHomeProviderTests(void);

static id fixture;
static NSError *transportError;

// Only the transport boundary is replaced in this offline executable.
@implementation SCNetworkClient

+ (nullable NSURLSessionTask *)GET:(NSString *)path
                        parameters:(nullable NSDictionary<NSString *, id> *)parameters
                           success:(SCNetworkSuccessBlock)success
                           failure:(SCNetworkFailureBlock)failure {
    NSCAssert([path isEqual:@"personalized"] && [parameters[@"limit"] isEqual:@6], @"Endpoint contract changed");
    if (transportError) {
        failure(nil, transportError);
    } else {
        success(nil, fixture);
    }
    return nil;
}

@end

static NSArray<SCPlaylist *> *fetch(id response, BOOL expectSuccess) {
    fixture = response;
    __block NSArray *result;
    __block NSError *error;
    __block NSUInteger callbacks = 0;
    [[SCNeteaseMusicService new] fetchRecommendedPlaylistWithLimit:6
        success:^(NSArray<SCPlaylist *> *items) {
            callbacks++;
            result = items;
        }
        failure:^(NSError *failure) {
            callbacks++;
            error = failure;
        }];
    NSCAssert(callbacks == 1 && (result != nil) == expectSuccess && (error != nil) != expectSuccess,
              @"Unexpected callback for %@",
              response);
    if (transportError) {
        NSCAssert(error == transportError, @"Preserve the original network error");
    } else if (error) {
        NSCAssert([error.domain isEqual:@"SCNeteaseMusicServiceErrorDomain"], @"Unexpected error domain");
    }
    return result;
}

static void verifyProviderResponse(id response, BOOL valid) {
    fixture = response;
    SCRemoteHomeProvider *provider = [SCRemoteHomeProvider new];
    __block BOOL finished = NO;
    [provider loadSectionsWithCompletion:^(NSArray<SCHomeSectionModel *> *sections, NSError *error) {
        if (valid) {
            SCPlaylist *playlist = (SCPlaylist *)sections.lastObject.items.firstObject;
            NSCAssert(!error && [playlist.identifier isEqual:@"17660040122"], @"Sample must reach the home section");
        } else {
            NSCAssert(error && sections.count == 0, @"Invalid API row must reach the Provider error path");
        }
        finished = YES;
    }];
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:2];
    while (!finished && deadline.timeIntervalSinceNow > 0) {
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
    }
    NSCAssert(finished, @"Missing provider completion");
    [provider cancelLoading];
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSCAssert(argc == 2, @"Pass the Phase 0 sample path");
        NSData *sample = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
        id response = [NSJSONSerialization JSONObjectWithData:sample options:0 error:NULL];
        NSArray *items = fetch(response, YES);
        SCPlaylist *playlist = items.firstObject;
        NSCAssert(items.count == 1 && [playlist isKindOfClass:SCPlaylist.class], @"Expected a domain model");
        NSCAssert([playlist.identifier isEqual:@"17660040122"] && [playlist.title isEqual:@"全网超好听的热播歌曲300首"],
                  @"Sample fields changed");
        NSCAssert([playlist.artworkName isEqual:@"SCCover00"] && playlist.tracks.count == 0, @"Unexpected defaults");

        NSString *largeJSON =
            @"{\"code\":200,\"result\":[{\"id\":9007199254740993,\"name\":\" A \"},{\"id\":2,\"name\":\"B\"}]}";
        NSArray<SCPlaylist *> *large =
            fetch([NSJSONSerialization JSONObjectWithData:[largeJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:0
                                                    error:NULL],
                  YES);
        NSCAssert(large.count == 2 && [large[0].identifier isEqual:@"9007199254740993"] &&
                      [large[0].title isEqual:@"A"] && [large[1].identifier isEqual:@"2"],
                  @"Precision or order changed");

        NSCAssert(fetch((@{@"code" : @200, @"result" : @[]}), YES).count == 0, @"Empty result is valid");
        NSString *decimalID = @"10000000000000000001";
        NSNumber *decimal = [NSDecimalNumber decimalNumberWithString:decimalID];
        SCPlaylist *decimalPlaylist = fetch(
                                          @{@"code" : @200,
                                            @"result" : @[ @{@"id" : decimal, @"name" : @"C"} ]},
                                          YES)
                                          .firstObject;
        NSCAssert([decimalPlaylist.identifier isEqual:decimalID], @"Preserve decimal integer digits");
        fetch(
            @{
                @"code" : @200,
                @"result" : @[ @{@"id" : [NSDecimalNumber decimalNumberWithString:@"1.25"], @"name" : @"C"} ]
            },
            NO);
        id null = NSNull.null;
        for (id root in @[
                 null,
                 @[],
                 @{},
                 @{@"code" : @500},
                 @{@"code" : @"200"},
                 @{@"code" : @YES},
                 @{@"code" : @200},
                 @{@"code" : @200,
                   @"result" : null}
             ]) {
            fetch(root, NO);
        }
        NSMutableArray *invalidRows = [NSMutableArray arrayWithArray:@[ null, @{}, @{@"name" : @"A"}, @{@"id" : @1} ]];
        for (id value in @[ null, @YES, @0, @(-1), @1.5, @"1", @[] ]) {
            [invalidRows addObject:@{@"id" : value, @"name" : @"A"}];
        }
        for (id value in @[ null, @123, @"", @"  " ]) {
            [invalidRows addObject:@{@"id" : @1, @"name" : value}];
        }
        for (id invalidRow in invalidRows) {
            fetch(@{@"code" : @200, @"result" : @[ @{@"id" : @1, @"name" : @"Valid"}, invalidRow ]}, NO);
        }
        for (id picture in @[ @"https://example.invalid/a.jpg", NSNull.null, @0, @"relative.jpg" ]) {
            SCPlaylist *item =
                fetch(
                    @{@"code" : @200,
                      @"result" : @[
                          @{@"id" : @1,
                            @"name" : @"Cover",
                            @"picUrl" : picture}
                      ]},
                    YES)
                    .firstObject;
            BOOL valid = [picture isEqual:@"https://example.invalid/a.jpg"];
            NSCAssert(valid ? [item.artworkURL.absoluteString isEqual:picture] : !item.artworkURL, @"Optional artwork");
        }
        verifyProviderResponse(response, YES);
        verifyProviderResponse(@{@"code" : @200, @"result" : @[ NSNull.null ]}, NO);
        SCRunHomeProviderTests();
        transportError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
        fetch(nil, NO);
        puts("Recommended playlist mapping checks passed.");
    }
    return 0;
}
