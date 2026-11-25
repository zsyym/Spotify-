#import "SCAlbumDetailView.h"
#import "SCAlbumHeaderView.h"
@interface SCAlbumDetailView ()
@property (nonatomic, strong) SCAlbumDetailModel *model;
@end
@implementation SCAlbumDetailView

#pragma mark - Public Methods

- (void)showModel:(SCAlbumDetailModel *)model {
    self.model = model;
    id<SCMusicItem> item = model.album;
    NSMutableArray *sections =
        [NSMutableArray arrayWithObjects:[SCDetailSection section:SCDetailHero title:nil items:@[ item ]],
                                         [SCDetailSection section:SCDetailControls title:nil items:@[ item ]],
                                         nil];

    if (model.album.tracks.count)
        [sections addObject:[SCDetailSection section:SCDetailTracks title:nil items:model.album.tracks]];
    self.note = model.summary;
    [sections addObject:[SCDetailSection section:SCDetailNote title:nil items:@[ item ]]];
    [self displayItem:item sections:sections];
}

- (Class)heroClass {
    return SCAlbumHeaderView.class;
}

- (void)configureHero:(UICollectionViewCell *)cell {
    SCAlbumHeaderView *hero = (id)cell;
    [hero showAlbum:self.model];
    [hero.artistButton addTarget:self action:@selector(artistTapped) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions

- (void)artistTapped {
    if (self.openArtist)
        self.openArtist();
}

@end
