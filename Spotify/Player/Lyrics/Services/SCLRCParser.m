#import "SCLRCParser.h"

@implementation SCLRCParser
#pragma mark - Public Methods

+ (SCLyricsModel *)parse:(NSString *)source translation:(NSString *)translation {
    SCLyricsModel *model = [self parseDocument:source];
    if (model.kind != SCLyricsTimed || !translation.length)
        return model;
    NSMutableDictionary *byTime = [NSMutableDictionary new];
    SCLyricsModel *translated = [self parseDocument:translation];
    if (translated.kind == SCLyricsTimed)
        for (SCLyricLine *line in translated.lines)
            byTime[@(llround(line.startTime * 1000))] = line.text;
    for (SCLyricLine *line in model.lines) {
        line.translatedText = byTime[@(llround(line.startTime * 1000))];
        if (line.translatedText.length)
            model.hasTranslation = YES;
    }
    return model;
}

#pragma mark - Private Methods

+ (SCLyricsModel *)parseDocument:(NSString *)source {
    NSRegularExpression *stamp =
        [NSRegularExpression regularExpressionWithPattern:@"^\\[([0-9]{1,7}):([0-5][0-9])(?:\\.([0-9]{1,3}))?\\]"
                                                  options:0
                                                    error:NULL];
    NSRegularExpression *tag = [NSRegularExpression regularExpressionWithPattern:@"^\\[([a-zA-Z]+):([^\\]]*)\\]$"
                                                                         options:0
                                                                           error:NULL];
    NSMutableDictionary *metadata = [NSMutableDictionary new], *timed = [NSMutableDictionary new];
    NSMutableArray *plain = [NSMutableArray new];
    BOOL malformed = NO;
    NSCharacterSet *spaces = NSCharacterSet.whitespaceAndNewlineCharacterSet;
    for (NSString *raw in [source componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet]) {
        NSString *line = [raw stringByTrimmingCharactersInSet:spaces];
        if (!line.length)
            continue;
        NSTextCheckingResult *meta = [tag firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
        if (meta) {
            metadata[[line substringWithRange:[meta rangeAtIndex:1]].lowercaseString] =
                [line substringWithRange:[meta rangeAtIndex:2]];
            continue;
        }
        NSMutableArray *times = [NSMutableArray new];
        while ([line hasPrefix:@"["]) {
            NSTextCheckingResult *match = [stamp firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
            if (!match) {
                malformed = YES;
                line = @"";
                break;
            }
            long long minutes = [line substringWithRange:[match rangeAtIndex:1]].longLongValue,
                      seconds = [line substringWithRange:[match rangeAtIndex:2]].longLongValue;
            NSRange fraction = [match rangeAtIndex:3];
            NSInteger ms = fraction.location == NSNotFound
                               ? 0
                               : [[line substringWithRange:fraction] stringByPaddingToLength:3
                                                                                  withString:@"0"
                                                                             startingAtIndex:0]
                                     .integerValue;
            [times addObject:@((minutes * 60 + seconds) * 1000 + ms)];
            line = [[line substringFromIndex:NSMaxRange(match.range)] stringByTrimmingCharactersInSet:spaces];
        }
        if (!line.length)
            continue;
        if (times.count) {
            for (NSNumber *time in times)
                timed[time] = line;
        } else {
            SCLyricLine *item = [SCLyricLine new];
            item.text = line;
            [plain addObject:item];
        }
    }
    SCLyricsModel *model = [SCLyricsModel new];
    model.metadata = metadata;
    model.songName = metadata[@"ti"];
    model.artistName = metadata[@"ar"];
    if (!timed.count) {
        model.lines = plain;
        model.kind = plain.count ? SCLyricsPlain : (malformed ? SCLyricsInvalid : SCLyricsUnavailable);
        return model;
    }
    double offset = 0;
    NSString *offsetText = metadata[@"offset"];
    if (offsetText) {
        NSScanner *scanner = [NSScanner scannerWithString:offsetText];
        long long value;
        if ([scanner scanLongLong:&value] && scanner.isAtEnd)
            offset = value;
    }
    NSMutableArray<SCLyricLine *> *lines = [NSMutableArray new];
    for (NSNumber *time in [timed.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        SCLyricLine *item = [SCLyricLine new];
        item.text = timed[time];
        item.startTime = MAX(0, (time.doubleValue - offset) / 1000.0);
        if (lines.count && lines.lastObject.startTime == item.startTime)
            [lines removeLastObject];
        [lines addObject:item];
    }
    model.kind = SCLyricsTimed;
    model.lines = lines;
    return model;
}
@end
