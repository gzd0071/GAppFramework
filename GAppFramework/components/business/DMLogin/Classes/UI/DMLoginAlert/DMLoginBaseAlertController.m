//
//  DMLoginAlertController.m
//  test
//
//  Created by JasonLin on 3/23/16.
//

#import "DMLoginBaseAlertController.h"
#import "DMLoginBaseAlertView.h"
#import "DMAlertAnimation.h"

@interface DMLoginBaseAlertController ()  <UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) DMAlertAnimation * animation;
@property (nonatomic) BOOL canTapDismiss;
@end

#define kDialogDimColor [UIColor colorWithWhite:0 alpha:0.7]

@implementation DMLoginBaseAlertController

#pragma mark - Init


- (void)customInitWithTitle:(NSString *)aTitle subtitle:(NSString *)aSubTitle confirmStr:(NSString *)aConfirm cancelStr:(NSString *)aCancel confirmBlock:(void(^)(id))cfmBlock cancelBlock:(void(^)(void))cnlBlock preferredStyle:(DMDialogControllerStyle)aStyle {
    self.titleStr = aTitle;
    self.subtitleStr = aSubTitle;
    self.confirmStr = aConfirm;
    self.cancelStr = aCancel;
    self.preferredStyle = aStyle;
    if (cfmBlock) self.confirmBlock = cfmBlock;
    if (cnlBlock) self.cancelBlock = cnlBlock;
    
    self.canTapDismiss = (self.preferredStyle == DMDialogControllerStyleCenter && self.cancelBlock) ? NO : YES;
    
    [self.view addSubview:self.contentView];
}



#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        self.animation = [[DMAlertAnimation alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kDialogDimColor;
    // 是否可以点击蒙层消失
    self.canTapDismiss = (self.preferredStyle == DMDialogControllerStyleCenter && self.cancelBlock) ? NO : YES;
    if (self.canTapDismiss) {
        self.dismissView = [[UIView alloc] initWithFrame:self.view.frame];
        self.dismissView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.dismissView];
        [self.view sendSubviewToBack:self.dismissView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoverView)];
        tap.numberOfTapsRequired = 1;
        [self.dismissView addGestureRecognizer:tap];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.userInteractionEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.view.userInteractionEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setContentView:(UIView *)contentView {
    _contentView = contentView;
    if (self.contentView.superview != self.view) {
        [self.view addSubview:self.contentView];
    }
    switch (self.preferredStyle) {
        case DMDialogControllerStyleCenter:
            self.contentView.center = self.view.center; break;
        case DMDialogControllerStyleBottom:
            self.contentView.center = CGPointMake(self.view.center.x, [UIScreen mainScreen].bounds.size.height + self.contentView.frame.size.height / 2); break;
        default:
            self.contentView.center = self.view.center; break;
    }
}

- (void)setPreferredStyle:(DMDialogControllerStyle)preferredStyle {
    _preferredStyle = preferredStyle;
    switch (preferredStyle) {
        case DMDialogControllerStyleCenter:
            self.contentView.center = self.view.center; break;
        case DMDialogControllerStyleBottom:
            self.contentView.center = CGPointMake(self.view.center.x, [UIScreen mainScreen].bounds.size.height + self.contentView.frame.size.height / 2); break;
        default:
            self.contentView.center = self.view.center; break;
    }
}

#pragma mark -

- (void)tapCoverView {
    if (self.canTapDismiss) {
        [self dismiss];
    }
}

- (void)dismiss {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.animation;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.animation;
}

#pragma mark - Supports

#pragma mark Add button action

- (void)addButton:(UIButton *)button action:(SEL)selector {
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark Base64 <-> UIImage

+ (UIImage *)base64ToImage:(NSString *)base64ImageStr {
    if (!base64ImageStr)
        return nil;
    base64ImageStr = [base64ImageStr stringByReplacingOccurrencesOfString:@"data:image/gif;base64," withString:@""];
    NSData * decodeImageData = [[NSData alloc] initWithBase64EncodedString:base64ImageStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage * decodeImage = [UIImage imageWithData:decodeImageData];
    
    return decodeImage;
}

+ (NSString *)imageToBase64:(UIImage *)image {
    if (!image)
        return @"";
    
    NSData * encodeImageData = UIImageJPEGRepresentation(image, 1.0f);
    NSString * encodeImageStr = [encodeImageData base64EncodedStringWithOptions:0];
    
    return encodeImageStr;
}

@end
