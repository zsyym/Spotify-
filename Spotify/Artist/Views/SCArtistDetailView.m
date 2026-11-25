#import "SCArtistDetailView.h"
#import "SCArtistHeaderView.h"
@interface SCArtistDetailView ()
@property (nonatomic, strong) SCArtistDetailModel *model;
@end
@implementation SCArtistDetailView

#pragma mark - Public Methods

- (void)showModel:(SCArtistDetailModel *)model {
    self.model = model;
    id<SCMusicItem> item = model.artist;
    NSMutableArray *sections =
        [NSMutableArray arrayWithObjects:[SCDetailSection section:SCDetailHero title:nil items:@[ item ]],
                                         [SCDetailSection section:SCDetailControls title:nil items:@[ item ]],
                                         nil];

    if (model.popular.count)
        [sections addObject:[SCDetailSection section:SCDetailTracks title:@"Popular" items:model.popular]];
    if (model.releases.count)
        [sections addObject:[SCDetailSection section:SCDetailReleases title:@"Popular Releases" items:model.releases]];
    if (model.albums.count)
        [sections addObject:[SCDetailSection section:SCDetailShelf title:@"Albums" items:model.albums]];
    if (model.singles.count)
        [sections addObject:[SCDetailSection section:SCDetailShelf title:@"Singles & EPs" items:model.singles]];
    if (model.related.count)
        [sections addObject:[SCDetailSection section:SCDetailShelf title:@"Fans Also Like" items:model.related]];
    self.note = model.about;
    [sections addObject:[SCDetailSection section:SCDetailNote title:@"About" items:@[ item ]]];
    [self displayItem:item sections:sections];
}

- (Class)heroClass {
    return SCArtistHeaderView.class;
}

- (void)configureHero:(UICollectionViewCell *)cell {
    SCArtistHeaderView *hero = (id)cell;
    [hero showArtist:self.model.artist];
}

@end
