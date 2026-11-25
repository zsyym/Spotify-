#import <XCTest/XCTest.h>
#import "SCLRCParser.h"
#import "SCLyricsTimeline.h"

@interface SCLyricsTests : XCTestCase
@end
@implementation SCLyricsTests
- (void)testParsingAndTranslation {
    NSString *source = @"[ti:Blue]\r\n[al:Test]\r\n[ar:Sample]\r\n[offset:+100]\r\n[00:08.125][00:02.50]中文\r\n[00:02."
                       @"50]replacement\r\n[00:61]invalid\r\n[01:05]end";
    SCLyricsModel *m = [SCLRCParser parse:source translation:@"[offset:100]\n[00:08.125]translation\n[00:01]unused"];
    XCTAssertEqual(m.kind, SCLyricsTimed);
    XCTAssertEqual(m.lines.count, 3);
    XCTAssertEqualObjects(m.metadata[@"al"], @"Test");
    XCTAssertEqualObjects(m.songName, @"Blue");
    XCTAssertEqualObjects(m.artistName, @"Sample");
    XCTAssertEqualWithAccuracy(m.lines[0].startTime, 2.4, 0.0001);
    XCTAssertEqualObjects(m.lines[0].text, @"replacement");
    XCTAssertNil(m.lines[0].translatedText);
    XCTAssertEqualObjects(m.lines[1].text, @"中文");
    XCTAssertEqualObjects(m.lines[1].translatedText, @"translation");
    XCTAssertEqualWithAccuracy(m.lines[1].startTime, 8.025, 0.00001);
    XCTAssertTrue(m.hasTranslation);
}
- (void)testFallbacks {
    XCTAssertEqual([SCLRCParser parse:@"" translation:nil].kind, SCLyricsUnavailable);
    XCTAssertEqual([SCLRCParser parse:@"[by:writer]\n[ti:Melody]" translation:nil].kind, SCLyricsUnavailable);
    XCTAssertEqual([SCLRCParser parse:@"[00:99]bad\n[00:-5]also bad" translation:nil].kind, SCLyricsInvalid);
    SCLyricsModel *plain = [SCLRCParser parse:@" hello \r\n\r\n你好" translation:nil];
    XCTAssertEqual(plain.kind, SCLyricsPlain);
    XCTAssertEqual(plain.lines.count, 2);
    XCTAssertEqualWithAccuracy(
        [SCLRCParser parse:@"[offset:-500]\n[00:02]a" translation:nil].lines.firstObject.startTime, 2.5, 0.0001);
}
- (void)testRandomAccess {
    NSArray *lines = [SCLRCParser parse:@"[00:01]one\n[00:03]two" translation:nil].lines;
    NSArray *duplicates = @[ lines[0], lines[0], lines[1] ];
    XCTAssertEqual([SCLyricsTimeline indexInLines:@[] atTime:2], NSNotFound);
    XCTAssertEqual([SCLyricsTimeline indexInLines:lines atTime:0], NSNotFound);
    XCTAssertEqual([SCLyricsTimeline indexInLines:duplicates atTime:1], 1);
    XCTAssertEqual([SCLyricsTimeline indexInLines:lines atTime:40], 1);
    XCTAssertEqual([SCLyricsTimeline indexInLines:lines atTime:2], 0);
    XCTAssertEqual([SCLyricsTimeline indexInLines:lines atTime:3], 1);
}
@end
