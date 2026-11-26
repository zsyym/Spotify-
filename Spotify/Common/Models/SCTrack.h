#import "SCMusicItem.h"
#import "SCArtist.h"

NS_ASSUME_NONNULL_BEGIN

@class SCAlbum;

@interface SCTrack : NSObject <SCMusicItem>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy, nullable) NSString *albumIdentifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *artworkName;
@property (nonatomic, strong, nullable) SCArtist *artist;
@property (nonatomic, copy) NSArray<SCArtist *> *artists;
@property (nonatomic, strong, nullable) SCAlbum *album;
@property (nonatomic, copy, nullable) NSURL *artworkURL;
@property (nonatomic, assign) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
