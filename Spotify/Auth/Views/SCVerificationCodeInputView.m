#import "SCVerificationCodeInputView.h"
#import "SCAuthStyle.h"

static const NSUInteger SCVerificationCodeLength = 6;

@interface SCVerificationCodeInputView () <UITextFieldDelegate>

@property (nonatomic, strong) UIStackView *digitStack;
@property (nonatomic, strong) NSArray<UIView *> *digitBoxes;
@property (nonatomic, strong) NSArray<UILabel *> *digitLabels;

@end

@implementation SCVerificationCodeInputView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self setupUI];
    [self setupConstraints];
    return self;
}

#pragma mark - Public Methods

- (void)clearCode {
    self.textField.text = @"";
    [self updateDigits];
}

#pragma mark - UI Setup

- (void)setupUI {
    NSMutableArray *boxes = [NSMutableArray new];
    NSMutableArray *labels = [NSMutableArray new];
    for (NSUInteger index = 0; index < SCVerificationCodeLength; index++) {
        UIView *box = [UIView new];
        box.backgroundColor = SCAuthColor(0x242424);
        box.layer.cornerRadius = 6;
        box.layer.borderWidth = 1;
        UILabel *label = SCAuthLabel(@"", 24, UIFontWeightBold);
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        label.numberOfLines = 1;
        label.isAccessibilityElement = NO;
        [box addSubview:label];
        [boxes addObject:box];
        [labels addObject:label];
    }
    self.digitBoxes = boxes;
    self.digitLabels = labels;
    self.digitStack = [[UIStackView alloc] initWithArrangedSubviews:self.digitBoxes];
    self.digitStack.spacing = 8;
    self.digitStack.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:self.digitStack];
    _textField = [UITextField new];
    _textField.delegate = self;
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.textContentType = UITextContentTypeOneTimeCode;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.textColor = UIColor.clearColor;
    _textField.tintColor = UIColor.clearColor;
    _textField.accessibilityLabel = @"6-digit verification code";
    _textField.accessibilityHint = @"Type or paste six digits. No real code has been sent.";
    [_textField addTarget:self action:@selector(codeChanged) forControlEvents:UIControlEventEditingChanged];
    [_textField addTarget:self action:@selector(editingBegan) forControlEvents:UIControlEventEditingDidBegin];
    [_textField addTarget:self action:@selector(editingEnded) forControlEvents:UIControlEventEditingDidEnd];
    [self addSubview:_textField];
    [self updateDigits];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.digitStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.height.greaterThanOrEqualTo(@56);
    }];
    for (NSUInteger index = 0; index < SCVerificationCodeLength; index++) {
        UIView *box = self.digitBoxes[index];
        [self.digitLabels[index] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(box).insets(UIEdgeInsetsMake(12, 2, 12, 2));
        }];
    }
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - Actions

- (void)codeChanged {
    // Also normalize system autofill changes that do not pass through the delegate.
    NSMutableString *digits = [NSMutableString new];
    NSString *input = self.textField.text ?: @"";
    for (NSUInteger index = 0; index < input.length && digits.length < SCVerificationCodeLength; index++) {
        unichar character = [input characterAtIndex:index];
        if (character >= '0' && character <= '9')
            [digits appendFormat:@"%C", character];
    }
    if (![input isEqualToString:digits])
        self.textField.text = digits;
    [self updateDigits];
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)editingBegan {
    [self updateDigits];
    [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
}

- (void)editingEnded {
    [self updateDigits];
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}

#pragma mark - Delegate Methods

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    NSString *text = textField.text ?: @"";
    if (NSMaxRange(range) > text.length)
        return NO;
    NSString *candidate = [text stringByReplacingCharactersInRange:range withString:string];
    NSCharacterSet *digits = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    // Pasting a full code replaces a partially typed code instead of overflowing it.
    if (string.length == SCVerificationCodeLength && candidate.length > SCVerificationCodeLength &&
        [string rangeOfCharacterFromSet:digits.invertedSet].location == NSNotFound) {
        textField.text = string;
        [self codeChanged];
        return NO;
    }
    return candidate.length <= SCVerificationCodeLength &&
           [candidate rangeOfCharacterFromSet:digits.invertedSet].location == NSNotFound;
}

- (void)textFieldDidChangeSelection:(UITextField *)textField {
    [self updateDigits];
}

#pragma mark - Private Methods

- (void)updateDigits {
    NSString *code = self.code;
    UITextRange *selection = self.textField.selectedTextRange;
    NSInteger cursor = selection ? [self.textField offsetFromPosition:self.textField.beginningOfDocument
                                                           toPosition:selection.start]
                                 : (NSInteger)code.length;
    NSUInteger activeIndex = MIN((NSUInteger)MAX(cursor, 0), SCVerificationCodeLength - 1);
    for (NSUInteger index = 0; index < SCVerificationCodeLength; index++) {
        self.digitLabels[index].text = index < code.length ? [code substringWithRange:NSMakeRange(index, 1)] : @"";
        BOOL active = self.textField.isFirstResponder && index == activeIndex;
        self.digitBoxes[index].layer.borderColor = SCAuthColor(active ? 0x1ED760 : 0x535353).CGColor;
        self.digitBoxes[index].layer.borderWidth = active ? 2 : 1;
    }
}

#pragma mark - Getters

- (NSString *)code {
    return self.textField.text ?: @"";
}

@end
