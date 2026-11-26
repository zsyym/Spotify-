#import "SCArtworkImageView.h"
#import <AFNetworking/AFImageDownloader.h>
#import <AFNetworking/AFHTTPSessionManager.h>

static AFImageDownloader *SCPlaylistArtworkDownloader(void) {
    static AFImageDownloader *downloader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[AFImageDownloader alloc] init];
        AFHTTPResponseSerializer *serializer = downloader.sessionManager.responseSerializer;
        // The artwork CDN serves some JPEGs with this alias.
        serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"image/jpg"];
    });
    return downloader;
}

@interface SCArtworkImageView ()
@property (nonatomic, strong) AFImageDownloadReceipt *receipt;
@property (nonatomic, strong) NSUUID *binding;
@property (nonatomic, copy) NSURL *representedURL;
@end
@implementation SCArtworkImageView
#pragma mark - Public Methods
- (void)showURL:(NSURL *)url placeholderName:(NSString *)name {
    if (self.binding && [url isEqual:self.representedURL]) return;
    self.representedURL = url;
    [self cancelArtworkLoad];
    self.image = [UIImage imageNamed:name];
    if (url) {
        NSUUID *binding = [NSUUID UUID];
        self.binding = binding;
        __weak typeof(self) weakSelf = self;
        self.receipt = [SCPlaylistArtworkDownloader()
            downloadImageForURLRequest:[NSURLRequest requestWithURL:url]
                         withReceiptID:binding
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   __strong typeof(weakSelf) self = weakSelf;
                                   if (self.binding != binding)
                                       return;
                                   self.image = image;
                                   self.receipt = nil;
                               }
                               failure:nil];
    }
}
- (void)cancelArtworkLoad {
    self.binding = nil;
    if (self.receipt)
        [SCPlaylistArtworkDownloader() cancelTaskForImageDownloadReceipt:self.receipt];
    self.receipt = nil;
}

- (void)dealloc {
    if (_receipt)
        [SCPlaylistArtworkDownloader() cancelTaskForImageDownloadReceipt:_receipt];
}

@end
