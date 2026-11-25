#import "SCMusicItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCArtist : NSObject <SCMusicItem>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSArray<NSString *> *relatedArtistIDs;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artworkName;

@end

NS_ASSUME_NONNULL_END
