#import "SCEditProfileViewController.h"
#import "SCEditProfileView.h"
#import "SCUser.h"
#import <PhotosUI/PhotosUI.h>
#import <ImageIO/ImageIO.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface SCEditProfileViewController () <PHPickerViewControllerDelegate, UITextFieldDelegate>
@property (nonatomic, strong) SCEditProfileView *page;
@property (nonatomic, strong) UIImage *draftPhoto;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) NSUInteger generation;
@end
@implementation SCEditProfileViewController
#pragma mark - Lifecycle

- (void)loadView {
    self.page = [SCEditProfileView new];
    self.view = self.page;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    self.draftPhoto = SCUser.current.photo;
    self.page.field.text = SCUser.current.nickname;
    self.page.field.delegate = self;
    [self.page.field addTarget:self action:@selector(refresh) forControlEvents:UIControlEventEditingChanged];
    [self.page.cancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.page.save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.page.change addTarget:self action:@selector(changePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self refresh];
}

#pragma mark - Actions
- (void)refresh {
    NSString *name = [SCUser trimmedName:self.page.field.text];
    BOOL valid = [SCUser isValidName:name];
    self.page.save.enabled = valid && self.hasChanges && !self.loading && !self.page.field.markedTextRange;
    self.page.change.enabled = !self.loading;
    self.page.hint.text = self.loading
                              ? @"Loading photo…"
                              : (valid ? @"Use up to 30 characters." : @"Enter a name between 1 and 30 characters.");
    [self.page previewName:name photo:self.draftPhoto];
}

- (void)save {
    if (!self.page.save.enabled)
        return;
    [SCUser.current saveName:self.page.field.text photo:self.draftPhoto];
    [self close];
}

- (void)close {
    self.generation++;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel {
    if (!self.hasChanges && !self.loading) {
        [self close];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Discard changes?"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Keep editing" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Discard"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *a) {
                                                [self close];
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)changePhoto {
    [self.view endEditing:YES];
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"Profile photo"
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    [menu addAction:[UIAlertAction actionWithTitle:@"Choose photo"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *a) {
                                               PHPickerConfiguration *config = [PHPickerConfiguration new];
                                               config.selectionLimit = 1;
                                               config.filter = PHPickerFilter.imagesFilter;
                                               PHPickerViewController *picker =
                                                   [[PHPickerViewController alloc] initWithConfiguration:config];
                                               picker.delegate = self;
                                               [self presentViewController:picker animated:YES completion:nil];
                                           }]];
    if (self.draftPhoto)
        [menu addAction:[UIAlertAction actionWithTitle:@"Restore default avatar"
                                                 style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction *a) {
                                                   self.draftPhoto = nil;
                                                   [self refresh];
                                               }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    menu.popoverPresentationController.sourceView = self.page.change;
    menu.popoverPresentationController.sourceRect = self.page.change.bounds;
    [self presentViewController:menu animated:YES completion:nil];
}

#pragma mark - Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)field {
    [field resignFirstResponder];
    return YES;
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (!results.count)
        return;
    self.loading = YES;
    [self refresh];
    NSUInteger generation = ++self.generation;
    __weak typeof(self) weakSelf = self;
    [results.firstObject.itemProvider
        loadFileRepresentationForTypeIdentifier:UTTypeImage.identifier
                              completionHandler:^(NSURL *url, NSError *error) {
                                  CGImageSourceRef source =
                                      url ? CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL) : NULL;
                                  NSDictionary *opts = @{
                                      (__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                      (__bridge NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                      (__bridge NSString *)kCGImageSourceShouldCacheImmediately : @YES,
                                      (__bridge NSString *)kCGImageSourceThumbnailMaxPixelSize : @512
                                  };
                                  CGImageRef thumb = source ? CGImageSourceCreateThumbnailAtIndex(
                                                                  source, 0, (__bridge CFDictionaryRef)opts)
                                                            : NULL;
                                  UIImage *photo = thumb ? [UIImage imageWithCGImage:thumb] : nil;
                                  if (thumb)
                                      CGImageRelease(thumb);
                                  if (source)
                                      CFRelease(source);
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      typeof(self) self = weakSelf;
                                      if (!self || self.generation != generation)
                                          return;
                                      self.loading = NO;
                                      if (photo)
                                          self.draftPhoto = photo;
                                      [self refresh];
                                      if (!photo)
                                          self.page.hint.text = @"Couldn’t load this photo. Try another image.";
                                  });
                              }];
}

#pragma mark - Private Methods

- (BOOL)hasChanges {
    return ![[SCUser trimmedName:self.page.field.text] isEqual:SCUser.current.nickname] ||
           self.draftPhoto != SCUser.current.photo;
}
@end
