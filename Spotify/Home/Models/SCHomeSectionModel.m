#import "SCHomeSectionModel.h"

@implementation SCHomeSectionModel

#pragma mark - Lifecycle

- (instancetype)initWithTitle:(NSString *)title kind:(SCHomeSectionKind)kind items:(NSArray<id<SCMusicItem>> *)items {
    if ((self = [super init])) {
        _title = [title copy];
        _kind = kind;
        _items = [items copy];
    }
    return self;
}

@end
