//
//  DMDHtmlViewController.m
//  Debugger
//
//  Created by iOS_Developer_G on 2019/12/4.
//

#import "DMDHtmlViewController.h"
#import <GBaseLib/GConvenient.h>
#import <GUILib/GTextField.h>
#import <GProtocol/ViewProtocol.h>
#import "DebuggerManager.h"
#import <GConst/HTMLConst.h>
#import <ReactiveObjC/UITextField+RACSignalSupport.h>
#import <ReactiveObjC/RACSignal.h>

@interface DMDHtmlViewController ()<DebuggerPluginDelegate, UITextFieldDelegate>
///>
@property (nonatomic, strong) GTextField *search;
@end
@implementation DMDHtmlViewController

DEBUGER_REGISTER(DMDHtmlViewController.class);

/*! Plugin: 名称 */
+ (NSString *)pluginName {
    return @"HTML";
}
/*! Plugin: 图标 */
+ (UIImage *)pluginIcon {
    return IMAGE(@"doraemon_h5");
}
/*! Plugin: 类型 */
+ (DebugPluginType)pluginType {
    return DebugPluginTypeThird;
}
/*! Plugin: 被点击 */
+ (void)pluginTapAction:(UINavigationController *)navi {
    [navi pushViewController:[DMDHtmlViewController new] animated:YES];
}

#pragma mark - VCLife
///=============================================================================
/// @name VCLife
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"HTML";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *sc = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    sc.backgroundColor = HEX(@"f7f7f7", @"000000");
    [self.view addSubview:sc];
    
    UIView<ViewDelegate> *header = [NSClassFromString(@"DMDAppInfoHeader") new];
    header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    [header viewModel:@{@"title":@"HTML服务器"} action:nil];
    [sc addSubview:header];
    
    UIView *con = [UIView new];
    con.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    con.frame = CGRectMake(0, 50, SCREEN_WIDTH, 44);
    [sc addSubview:con];
    [con addSubview:self.search];
    
    UIView *footer = [NSClassFromString(@"DMDCopyRightFooterView") new];
    footer.frame = CGRectMake(0, con.bottom, SCREEN_WIDTH, footer.height);
    [sc addSubview:footer];
    
    [self.search becomeFirstResponder];
    sc.contentSize = CGSizeMake(sc.width, sc.height+1);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (GTextField *)search {
    if (!_search) {
        _search = [GTextField new];
        _search.frame = CGRectMake(16, 7, self.view.width-32, 30);
        _search.backgroundColor = HEX(@"f2f2f2", @"262628");
        _search.placeholder = @"10.216.98.5:8000";
        _search.leftViewMode = UITextFieldViewModeAlways;
        _search.lvx = 8;
        
        if ([HTML_ROOT_C_VALUE length]) {
            NSURL *url = [NSURL URLWithString:HTML_ROOT_C_VALUE];
            id txt = FORMAT(@"%@", url.host?:@"");
            if (url.port) txt = FORMAT(@"%@:%@", url.host, url.port);
            _search.text = txt;
        }
        
        [_search.rac_textSignal subscribeNext:^(NSString *x) {
            if (x.length < 6 && x.length >=1 ) return;
            id host = x.length ? FORMAT(@"http://%@", x) : @"";
            [[NSUserDefaults standardUserDefaults] setValue:host forKey:HTML_ROOT_C_KEY];
        }];
        _search.delegate = self;
        _search.clearButtonMode = UITextFieldViewModeWhileEditing;
        _search.layer.cornerRadius = 2;
        _search.clipsToBounds = YES;
        _search.font = FONT(12);
    }
    return _search;
}
@end
