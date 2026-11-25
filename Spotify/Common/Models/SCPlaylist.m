#import "SCPlaylist.h"
#import "SCLibraryStore.h"

@implementation SCPlaylist

#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _identifier = @"";
        _title = @"";
        _subtitle = @"";
        _artworkName = @"";
        _creatorName = @"";
        _tracks = @[];
    }
    return self;
}

#pragma mark - Accessors

- (BOOL)isSaved {
    return [SCLibraryStore.sharedStore containsID:self.identifier];
}

- (void)setSaved:(BOOL)saved {
    [SCLibraryStore.sharedStore setSaved:saved identifier:self.identifier];
}

@end
