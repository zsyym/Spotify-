#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SCLyricsKind) { SCLyricsUnavailable, SCLyricsTimed, SCLyricsPlain, SCLyricsInvalid };
@interface SCLyricLine : NSObject
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *translatedText;
@end

@interface SCLyricsModel : NSObject
@property (nonatomic, copy) NSString *trackID;
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, assign) SCLyricsKind kind;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *metadata;
@property (nonatomic, copy) NSArray<SCLyricLine *> *lines;
@property (nonatomic, assign) BOOL hasTranslation;
@end
