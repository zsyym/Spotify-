#import "SCSearchResultModel.h"

@implementation SCSearchResultModel

#pragma mark - Lifecycle

- (instancetype)initWithItems:(NSArray<id<SCMusicItem>> *)items {
    if ((self = [super init]))
        _items = items.copy;
    return self;
}

@end
