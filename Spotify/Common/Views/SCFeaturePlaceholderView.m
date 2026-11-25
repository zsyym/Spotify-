#import "SCFeaturePlaceholderView.h"
#import "SCMusicStyle.h"

@interface SCFeaturePlaceholderView ()

@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, copy) NSString *symbolName;
@property (nonatomic, strong) UIStackView *stack;
@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation SCFeaturePlaceholderView

#pragma mark - Lifecycle

- (instancetype)initWithTitle:(NSString *)title symbol:(NSString *)symbol {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    _pageTitle = [title copy];
    _symbolName = [symbol copy];
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = SCMusicColor(0x121212);
    self.iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:self.symbolName]];
    self.iconView.tintColor = SCMusicColor(0xB3B3B3);
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *title = SCMusicLabel(28, UIFontWeightBold);
    title.text = self.pageTitle;
    title.textAlignment = NSTextAlignmentCenter;
    UILabel *note = SCMusicLabel(15, UIFontWeightRegular);
    note.text = @"Details coming soon.";
    note.textColor = SCMusicColor(0xB3B3B3);
    note.textAlignment = NSTextAlignmentCenter;
    note.numberOfLines = 0;
    self.stack = [[UIStackView alloc] initWithArrangedSubviews:@[ self.iconView, title, note ]];
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.alignment = UIStackViewAlignmentCenter;
    self.stack.spacing = 20;
    [self addSubview:self.stack];
    [title setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.mas_centerY);
        make.leading.greaterThanOrEqualTo(self).offset(24);
        make.trailing.lessThanOrEqualTo(self).offset(-24);
        make.top.greaterThanOrEqualTo(self.mas_safeAreaLayoutGuideTop).offset(24);
        make.bottom.lessThanOrEqualTo(self.mas_safeAreaLayoutGuideBottom).offset(-24);
    }];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(48);
    }];
}

@end
