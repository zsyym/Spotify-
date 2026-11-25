#import "SCLocalMusicCatalog.h"
@interface SCArtistDetailModel : NSObject
@property (nonatomic, strong, readonly) SCArtist *artist;
@property (nonatomic, copy, readonly) NSArray<SCTrack *> *popular;
@property (nonatomic, copy, readonly) NSArray<SCAlbum *> *releases;
@property (nonatomic, copy, readonly) NSArray<SCAlbum *> *albums;
@property (nonatomic, copy, readonly) NSArray<SCAlbum *> *singles;
@property (nonatomic, copy, readonly) NSArray<SCArtist *> *related;
@property (nonatomic, copy, readonly) NSString *about;
- (instancetype)initWithArtist:(SCArtist *)artist catalog:(SCLocalMusicCatalog *)catalog;
@end
