#import "SCMusicNavigation.h"

#import "SCPlaylistDetailViewController.h"
#import "SCAlbumDetailViewController.h"
#import "SCArtistDetailViewController.h"
#import "SCLibraryStore.h"
@implementation SCMusicNavigation

#pragma mark - Public Methods

+ (NSString *)descriptionForItem:(id<SCMusicItem>)item {
    if ([(NSObject *)item isKindOfClass:SCPlaylist.class])
        return [@"Playlist · " stringByAppendingString:((SCPlaylist *)item).creatorName];
    if ([(NSObject *)item isKindOfClass:SCAlbum.class])
        return [@"Album · " stringByAppendingString:item.subtitle];
    if ([(NSObject *)item isKindOfClass:SCArtist.class])
        return @"Artist";
    return item.subtitle;
}

+ (void)openItem:(id<SCMusicItem>)item from:(UIViewController *)controller {
    UINavigationController *navigation = controller.navigationController;
    if (navigation.topViewController != controller || navigation.transitionCoordinator)
        return;
    UIViewController *detail;
    if ([(NSObject *)item isKindOfClass:SCPlaylist.class])
        detail = [[SCPlaylistDetailViewController alloc] initWithPlaylist:(SCPlaylist *)item];
    else if ([(NSObject *)item isKindOfClass:SCAlbum.class])
        detail = [[SCAlbumDetailViewController alloc] initWithAlbum:(SCAlbum *)item];
    else if ([(NSObject *)item isKindOfClass:SCArtist.class])
        detail = [[SCArtistDetailViewController alloc] initWithArtist:(SCArtist *)item];
    if (detail)
        [controller.navigationController pushViewController:detail animated:YES];
}

+ (void)showOptionsFor:(id<SCMusicItem>)item from:(UIViewController *)controller {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:item.title
                                                                   message:[self descriptionForItem:item]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    BOOL artist = [(NSObject *)item isKindOfClass:SCArtist.class];
    SCLibraryStore *store = SCLibraryStore.sharedStore;
    BOOL saved = [store containsID:item.identifier];
    NSString *label =
        artist ? (saved ? @"Unfollow" : @"Follow") : (saved ? @"Remove from library" : @"Save to library");
    [alert addAction:[UIAlertAction actionWithTitle:label
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                [store setSaved:!saved identifier:item.identifier];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    [controller presentViewController:alert animated:YES completion:nil];
}

@end
