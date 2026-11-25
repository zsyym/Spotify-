#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCMusicItem <NSObject>
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;
@property (nonatomic, copy, readonly) NSString *artworkName;

@end

NS_ASSUME_NONNULL_END
