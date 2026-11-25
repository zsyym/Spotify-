#import "SCLyricsProvider.h"
#import "SCLRCParser.h"
@implementation SCLyricsProvider
#pragma mark - Public Methods

+ (void)loadTrack:(SCTrack *)track completion:(void (^)(SCLyricsModel *))completion {
    NSString *key = track.identifier.copy, *title = track.title.copy, *artist = track.subtitle.copy;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSBundle *bundle = NSBundle.mainBundle;
        NSURL *url = [bundle URLForResource:key withExtension:@"lrc"];
        NSString *source = url ? [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL] : nil;
        NSURL *translation = [bundle URLForResource:[key stringByAppendingString:@"-translation"] withExtension:@"lrc"];
        SCLyricsModel *model = [SCLRCParser parse:source
                                      translation:translation ? [NSString stringWithContentsOfURL:translation
                                                                                         encoding:NSUTF8StringEncoding
                                                                                            error:NULL]
                                                              : nil];
        if (url && !source)
            model.kind = SCLyricsInvalid;
        model.trackID = key;
        model.songName = title;
        model.artistName = artist;
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(model);
        });
    });
}
@end
