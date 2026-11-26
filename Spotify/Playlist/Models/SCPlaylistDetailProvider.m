#import "SCPlaylistDetailProvider.h"
static const NSUInteger SCPageSize = 30;

@interface SCPlaylistDetailProvider ()
@property (nonatomic, strong) id<SCPlaylistDetailProviding> service;
@property (nonatomic, strong, readwrite) SCPlaylist *playlist;
@property (nonatomic, copy, readwrite) NSArray<SCTrack *> *tracks;
@property (nonatomic, copy) NSArray<SCTrack *> *prefix;
@property (nonatomic, readwrite) BOOL loadingMetadata;
@property (nonatomic, readwrite) BOOL loadingPage;
@property (nonatomic, readwrite) BOOL hasMore;
@property (nonatomic, strong, readwrite) NSError *metadataError;
@property (nonatomic, strong, readwrite) NSError *pageError;
@property (nonatomic, strong) NSURLSessionTask *metadataTask;
@property (nonatomic, strong) NSURLSessionTask *pageTask;
@property (nonatomic) NSUInteger generation;
@end

@implementation SCPlaylistDetailProvider

#pragma mark - Lifecycle

- (instancetype)initWithPlaylist:(SCPlaylist *)playlist service:(id<SCPlaylistDetailProviding>)service {
    if ((self = [super init])) {
        _playlist = playlist;
        _service = service;
        _tracks = @[];
    }
    return self;
}

- (void)dealloc {
    [_metadataTask cancel];
    [_pageTask cancel];
}

#pragma mark - Public Methods

- (void)cancel {
    self.generation++;
    [self.metadataTask cancel];
    [self.pageTask cancel];
    self.metadataTask = nil;
    self.pageTask = nil;
    self.loadingPage = NO;
    self.loadingMetadata = NO;
}

- (void)refresh {
    [self cancel];
    self.tracks = @[];
    self.prefix = @[];
    self.pageError = nil;
    self.hasMore = YES;
    [self retryMetadata];
}

- (void)retryMetadata {
    if (self.loadingMetadata) return;
    self.loadingMetadata = YES;
    self.metadataError = nil;
    [self notifyChange];
    NSUInteger generation = self.generation;
    __weak typeof(self) weakSelf = self;
    void (^finish)(SCPlaylist *, NSError *) = ^(SCPlaylist *playlist, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || self.generation != generation || !self.loadingMetadata) return;
            self.metadataTask = nil;
            self.loadingMetadata = NO;
            self.metadataError = error;
            if (playlist) {
                self.prefix = playlist.tracks;
                playlist.tracks = self.tracks;
                self.playlist = playlist;
                if (playlist.trackCount && self.tracks.count >= playlist.trackCount.unsignedIntegerValue)
                    self.hasMore = NO;
            }
            if (!self.tracks.count && self.hasMore && !self.loadingPage && !self.pageError) [self loadNextPage];
            else [self notifyChange];
        });
    };
    self.metadataTask = [self.service fetchPlaylist:self.playlist.identifier success:^(SCPlaylist *playlist) {
        finish(playlist,nil);
    } failure:^(NSError *error) { finish(nil,error); }];
}

- (void)loadNextPage {
    if (!self.hasMore || self.loadingPage || self.loadingMetadata) return;
    self.loadingPage = YES;
    self.pageError = nil;
    [self notifyChange];
    NSUInteger offset = self.tracks.count;
    NSUInteger generation = self.generation;
    __weak typeof(self) weakSelf = self;
    void (^finish)(NSArray<SCTrack *> *, NSError *, BOOL) = ^(NSArray<SCTrack *> *rows, NSError *error, BOOL fromAPI) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || self.generation != generation || offset != self.tracks.count || !self.loadingPage) return;
            self.loadingPage = NO;
            self.pageTask = nil;
            self.pageError = error;
            if (!error) {
                self.tracks = [self.tracks arrayByAddingObjectsFromArray:rows];
                self.hasMore = (!fromAPI || rows.count == SCPageSize) &&
                    (!self.playlist.trackCount || self.tracks.count < self.playlist.trackCount.unsignedIntegerValue);
            }
            [self notifyChange];
        });
    };
    if (offset < self.prefix.count) {
        NSUInteger length = MIN(SCPageSize, self.prefix.count-offset);
        finish([self.prefix subarrayWithRange:NSMakeRange(offset,length)],nil,NO);
        return;
    }
    self.pageTask = [self.service fetchTracksForPlaylist:self.playlist.identifier limit:SCPageSize offset:offset
        success:^(NSArray<SCTrack *> *rows) { finish(rows,nil,YES); }
        failure:^(NSError *error) { finish(nil,error,YES); }];
}

#pragma mark - Private Methods

- (void)notifyChange {
    if (self.didChange) self.didChange();
}

@end
