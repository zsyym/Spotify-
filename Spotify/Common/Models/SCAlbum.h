#import "SCMusicItem.h"
#import "SCArtist.h"
#import "SCTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCAlbum : NSObject <SCMusicItem>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *releaseType;
@property (nonatomic, assign) NSInteger releaseYear;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *artworkName;
@property (nonatomic, strong, nullable) SCArtist *artist;
@property (nonatomic, copy) NSArray<SCTrack *> *tracks;

@end

NS_ASSUME_NONNULL_END
