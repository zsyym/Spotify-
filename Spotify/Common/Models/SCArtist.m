#import "SCArtist.h"

@implementation SCArtist

#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _identifier = @"";
        _name = @"";
        _relatedArtistIDs = @[];
        _artworkName = @"";
    }
    return self;
}

#pragma mark - Getters

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return @"Artist";
}

@end
