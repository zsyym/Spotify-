#import "SCMusicItem.h"
#import "SCTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCPlaylist : NSObject <SCMusicItem>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *artworkName;
@property (nonatomic, copy) NSString *creatorName;
@property (nonatomic, assign, getter=isSaved) BOOL saved;
@property (nonatomic, copy) NSArray<SCTrack *> *tracks;

@end

NS_ASSUME_NONNULL_END
