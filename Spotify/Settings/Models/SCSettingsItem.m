#import "SCSettingsItem.h"
#import "SCUser.h"

@implementation SCSettingsItem
#pragma mark - Public Methods

+ (NSArray<NSString *> *)choicesFor:(NSString *)page {
    if ([page isEqual:@"Volume level"])
        return @[ @"Loud", @"Normal", @"Quiet" ];
    if ([page isEqual:@"Profile visibility"])
        return @[ @"Private", @"Public" ];
    if ([page isEqual:@"Download quality"])
        return @[ @"Low", @"Normal", @"High", @"Very High" ];
    if ([@[ @"Wi-Fi streaming", @"Cellular streaming" ] containsObject:page])
        return @[ @"Automatic", @"Low", @"Normal", @"High", @"Very High" ];
    return nil;
}

+ (NSString *)noteForPage:(NSString *)page {
    if ([page isEqual:@"Playback"] || [page isEqual:@"Audio Quality"])
        return @"Preview controls • Audio playback is simulated.";
    if ([page isEqual:@"Privacy"])
        return @"Session preview • These choices stay on this device for this run.";
    if ([page isEqual:@"Notifications"])
        return @"Preview preferences • Push notifications are inactive.";
    if ([page isEqual:@"Data Saver"])
        return @"Preview preferences • Network and download services are inactive.";
    if ([page isEqual:@"Appearance"])
        return @"Currently available in the preview.";
    return nil;
}

+ (NSArray *)itemsForPage:(NSString *)page {
    NSMutableArray *items = [NSMutableArray new];
    void (^add)(SCSettingKind, NSString *, NSString *, NSString *) =
        ^(SCSettingKind kind, NSString *name, NSString *detail, NSString *symbol) {
            SCSettingsItem *item = [self new];
            item->_kind = kind;
            item->_name = name.copy;
            item->_detail = detail.copy;
            item->_symbol = symbol.copy;
            [items addObject:item];
        };
    NSArray *options = [self choicesFor:page];
    if (options) {
        for (NSString *opt in options)
            add(SCSettingChoice, opt, nil, nil);
        return items;
    }
    if ([page isEqual:@"Settings and privacy"] || [page isEqual:@"Account"])
        add(SCSettingProfile,
            SCUser.current.nickname,
            [page isEqual:@"Account"]
                ? SCUser.current.displayIdentity
                : [NSString stringWithFormat:@"%@  ·  View account", SCUser.current.displayIdentity],
            nil);
    if ([page isEqual:@"Settings and privacy"]) {
        NSArray *links = @[
            @[ @"Account", @"Profile and sign-in", @"person.crop.circle" ],
            @[ @"Data Saver", @"Mobile data preferences", @"antenna.radiowaves.left.and.right" ],
            @[ @"Playback", @"Transitions and volume", @"play.circle" ],
            @[ @"Audio Quality", @"Streaming and downloads", @"waveform" ],
            @[ @"Storage", @"Device space and cache", @"internaldrive" ],
            @[ @"Notifications", @"Music and product updates", @"bell" ],
            @[ @"Privacy", @"Activity and visibility", @"lock" ],
            @[ @"Appearance", @"Theme and language", @"circle.lefthalf.filled" ],
            @[ @"About", @"Version and licenses", @"info.circle" ]
        ];
        for (NSArray *row in links)
            add(SCSettingLink, row[0], row[1], row[2]);
        add(SCSettingUnavailable,
            @"Log out",
            @"Available with the account flow in a later phase.",
            @"rectangle.portrait.and.arrow.right");
    } else if ([page isEqual:@"Account"]) {
        add(SCSettingInfo, @"Email", @"No email linked", nil);
        add(SCSettingLink, @"Edit profile", @"Change your name or photo", @"pencil");
        add(SCSettingUnavailable, @"Change password", @"Requires an authenticated account.", @"key");
    } else if ([page isEqual:@"Playback"]) {
        add(SCSettingSlider, @"Crossfade", @"Blend the end of one track into the next.", nil);
        add(SCSettingSwitch, @"Gapless playback", @"Remove the gap between tracks.", nil);
        add(SCSettingSwitch, @"Automix", @"Smooth transitions in compatible playlists.", nil);
        add(SCSettingSwitch, @"Normalize volume", @"Keep tracks at a consistent level.", nil);
        add(SCSettingLink, @"Volume level", nil, @"speaker.wave.2");
        add(SCSettingSwitch, @"Autoplay", @"Continue after the queue ends.", nil);
    } else if ([page isEqual:@"Audio Quality"]) {
        for (NSString *name in @[ @"Wi-Fi streaming", @"Cellular streaming", @"Download quality" ])
            add(SCSettingLink, name, nil, @"waveform");
    } else if ([page isEqual:@"Data Saver"]) {
        add(SCSettingSwitch, @"Data Saver", @"Prefer lower data usage on mobile.", nil);
        add(SCSettingSwitch, @"Download using cellular", @"Allow downloads over mobile data.", nil);
    } else if ([page isEqual:@"Notifications"]) {
        for (NSString *name in @[ @"Music recommendations", @"New releases", @"Playlist updates", @"Product news" ])
            add(SCSettingSwitch, name, nil, nil);
    } else if ([page isEqual:@"Privacy"]) {
        add(SCSettingSwitch, @"Private session", @"Preview private listening.", nil);
        add(SCSettingSwitch, @"Listening activity", @"Preview sharing your listening activity.", nil);
        add(SCSettingLink, @"Profile visibility", nil, @"eye");
    } else if ([page isEqual:@"Appearance"]) {
        add(SCSettingInfo, @"Theme", @"Dark", nil);
        add(SCSettingInfo, @"Language", @"English", nil);
    } else if ([page isEqual:@"Storage"]) {
        add(SCSettingUsage, @"Storage usage", nil, nil);
        add(SCSettingUnavailable, @"Clear cache", @"No music cache to clear.", nil);
    } else if ([page isEqual:@"About"]) {
        NSBundle *bundle = NSBundle.mainBundle;
        add(SCSettingInfo,
            [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                ?: [bundle objectForInfoDictionaryKey:@"CFBundleName"],
            @"An independent Spotify-style learning project, unaffiliated with Spotify.",
            @"logo");
        add(SCSettingInfo,
            @"Version",
            [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"Unavailable",
            nil);
        add(SCSettingInfo,
            @"Build number",
            [bundle objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"Unavailable",
            nil);
        add(SCSettingLink, @"Open-source licenses", nil, @"doc.text");
    } else if ([page isEqual:@"Open-source licenses"]) {
        for (NSString *name in @[ @"AFNetworking", @"LookinServer", @"Masonry", @"YYModel" ])
            add(SCSettingLink, name, @"License text", @"doc.plaintext");
    } else {
        NSURL *file = [NSBundle.mainBundle URLForResource:[page stringByAppendingString:@"-LICENSE"]
                                            withExtension:@"txt"];
        if (file)
            add(SCSettingInfo,
                page,
                [NSString stringWithContentsOfURL:file encoding:NSUTF8StringEncoding error:NULL],
                nil);
    }
    return items;
}
@end
