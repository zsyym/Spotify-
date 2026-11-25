#import "SCStorageUsageView.h"
#import "SCMusicStyle.h"

@interface SCStorageUsageView ()
@property (nonatomic, strong) UIStackView *stack;
@property (nonatomic, strong) UIView *bar;
@property (nonatomic, copy) NSArray<UILabel *> *legend;
@property (nonatomic, copy) NSArray<CALayer *> *segments;
@property (nonatomic, copy) NSArray<NSNumber *> *fractions;
@end
@implementation SCStorageUsageView
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupUI];
        [self setupConstraints];
        [self measure];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = 0, width = self.bar.bounds.size.width;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (NSUInteger i = 0; i < self.fractions.count; i++) {
        CGFloat next = MIN(width, x + width * self.fractions[i].doubleValue);
        self.segments[i].frame = (CGRect){CGPointMake(x, 0), CGSizeMake(MAX(0, next - x), self.bar.bounds.size.height)};
        x = next;
    }
    [CATransaction commit];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.stack = [UIStackView new];
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.spacing = 12;
    [self addSubview:self.stack];
    UILabel *title = SCMusicLabel(19, UIFontWeightBold);
    title.text = @"Device storage";
    [self.stack addArrangedSubview:title];
    self.bar = [UIView new];
    self.bar.clipsToBounds = YES;
    self.bar.layer.cornerRadius = 5;
    self.bar.backgroundColor = SCMusicColor(SCColorCard);
    [self.stack addArrangedSubview:self.bar];
    NSMutableArray *labels = [NSMutableArray new], *layers = [NSMutableArray new];
    NSArray *names =
        @[ @"App storage (installed bundle)", @"Music cache", @"Downloads", @"Other used space", @"Available storage" ];
    NSArray *colors = @[ @(SCColorBrand), @0xE5A87E, @0xB598DD, @0x82758F, @0xA4B4BB ];
    for (NSUInteger i = 0; i < names.count; i++) {
        CALayer *segment = [CALayer layer];
        segment.backgroundColor = SCMusicColor([colors[i] unsignedIntValue]).CGColor;
        [self.bar.layer addSublayer:segment];
        [layers addObject:segment];
        UILabel *label = SCMusicLabel(14, UIFontWeightMedium);
        label.text = names[i];
        label.textColor = SCMusicColor([colors[i] unsignedIntValue]);
        [labels addObject:label];
        [self.stack addArrangedSubview:label];
    }
    self.legend = labels;
    self.segments = layers;
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(16, 16, 16, 16));
    }];
    [self.bar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(10);
    }];
}

#pragma mark - Private Methods

- (void)measure {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSFileManager *fm = NSFileManager.defaultManager;
        NSDictionary *disk = [fm attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
        NSURL *bundle = NSBundle.mainBundle.bundleURL;
        unsigned long long appBytes = 0;
        __block BOOL complete = YES;
        NSDirectoryEnumerator *files = [fm enumeratorAtURL:bundle
                                includingPropertiesForKeys:@[ NSURLIsRegularFileKey, NSURLFileSizeKey ]
                                                   options:0
                                              errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                  complete = NO;
                                                  return YES;
                                              }];
        for (NSURL *url in files) {
            NSDictionary *attrs = [url resourceValuesForKeys:@[ NSURLIsRegularFileKey, NSURLFileSizeKey ] error:NULL];
            if (!attrs) {
                complete = NO;
                continue;
            }
            if ([attrs[NSURLIsRegularFileKey] boolValue])
                appBytes += [attrs[NSURLFileSizeKey] unsignedLongLongValue];
        }
        NSNumber *total = disk[NSFileSystemSize], *free = disk[NSFileSystemFreeSize];
        double used = MAX(0, total.doubleValue - free.doubleValue);
        NSArray *sizes = @[
            complete && files ? @(appBytes) : NSNull.null,
            @0,
            @0,
            total && free && complete && files ? @(MAX(0, used - appBytes)) : NSNull.null,
            free ?: NSNull.null
        ];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showSizes:sizes total:total];
        });
    });
}

- (void)showSizes:(NSArray *)sizes total:(NSNumber *)total {
    NSArray *names =
        @[ @"App storage (installed bundle)", @"Music cache", @"Downloads", @"Other used space", @"Available storage" ];
    NSMutableArray *fractions = [NSMutableArray new];
    BOOL valid = total.doubleValue > 0 && ![sizes containsObject:NSNull.null];
    for (NSUInteger i = 0; i < sizes.count; i++) {
        NSNumber *value = sizes[i];
        NSString *size = value == (id)NSNull.null
                             ? @"Unavailable"
                             : [NSByteCountFormatter stringFromByteCount:value.longLongValue
                                                              countStyle:NSByteCountFormatterCountStyleFile];
        if (i == 1 || i == 2)
            size = @"0 B · inactive";
        self.legend[i].text = [NSString stringWithFormat:@"●   %@   ·   %@", names[i], size];
        [fractions addObject:@(valid ? MIN(1, value.doubleValue / total.doubleValue) : 0)];
    }
    self.fractions = fractions;
    [self setNeedsLayout];
}
@end
