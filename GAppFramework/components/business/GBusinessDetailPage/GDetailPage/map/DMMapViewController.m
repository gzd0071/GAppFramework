//
//  DMMapViewController.m
//  GLocation
//
//  Created by iOS_Developer_G on 2019/10/17.
//

#import "DMMapViewController.h"
#import <GBaseLib/GConvenient.h>
#import <GRouter/GRouter.h>
#import <DMUILib/DMAlertActions.h>
#import <MapKit/MapKit.h>
#import <GConst/URDConst.h>
#import <GLocation/GMapView.h>

@interface DMMapViewController ()<GRouterDataDelegate>
///> 视图: 地图
@property (nonatomic, strong) GMapView *map;
///> 数据:
@property (nonatomic, strong) NSDictionary *dict;
///>
@property (nonatomic, assign) CLLocationCoordinate2D coor;
@end

@implementation DMMapViewController

#pragma mark - ROUTER
///=============================================================================
/// @name ROUTER
///=============================================================================

ROUTER_REGISTER(CSCHEME, URD_JOB_MAP);

- (void)routerPassParamters:(id)data {
    self.dict = data;
}

#pragma mark - VC LIFE
///=============================================================================
/// @name VC LIFE
///=============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    self.navigationItem.title = self.dict[@"title"]?:@"工作地点";
    self.coor = CLLocationCoordinate2DMake([self.dict[@"lat"] floatValue], [self.dict[@"lng"] floatValue]);
    [self addViews];
}

#pragma mark - GETTERS
///=============================================================================
/// @name GETTERS
///=============================================================================

- (void)addViews {
    [self.view addSubview:self.map];
    [self addInfoView];
}

- (GMapView *)map {
    if (!_map) {
        GMapPModel *model = [GMapPModel new];
        model.config = GMConfigGestureDisabled | GMConfigUserLocation;
        model.coor = self.coor;
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-162);
        _map = [GMapView viewWithFrame:frame model:model baction:nil];
    }
    return _map;
}

- (void)addInfoView {
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, SCREEN_HEIGHT-162, SCREEN_WIDTH, 162);
    view.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    //阴影
    view.layer.shadowColor = HEX(@"D4D4D4").CGColor;
    view.layer.shadowOffset = CGSizeMake(0, -4);
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowRadius = 2;
    //地址栏
    UILabel *titleLab  = [[UILabel alloc] init];
    titleLab.font      = [UIFont systemFontOfSize:20];
    titleLab.textColor = HEX(@"404040", @"dddddd");
    titleLab.text      = self.dict[@"address"];
    titleLab.frame     = CGRectMake(16, 24, SCREEN_WIDTH-48, 20);
    [view addSubview:titleLab];
    //距离lab
    UILabel *distanceLab = [[UILabel alloc] init];
    NSString *dis = self.dict[@"distance_str"];
    if (dis && dis.length) {
        distanceLab.font = [UIFont systemFontOfSize:14];
        distanceLab.textColor = HEX(@"404040", @"dddddd");
        distanceLab.text = dis;
        [distanceLab sizeToFit];
        distanceLab.frame = CGRectMake(16, CGRectGetMaxY(titleLab.frame)+12, distanceLab.width, 14);
        [view addSubview:distanceLab];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = HEX(@"808080", @"AFAFB0");
        lineView.frame = CGRectMake(CGRectGetMaxX(distanceLab.frame)+8, distanceLab.y+2, 0.5, 10);
        [view addSubview:lineView];
    }
    //区域lab
    UILabel *addressLab = [[UILabel alloc] init];
    NSString *district  = self.dict[@"district"];
    NSString *city      = self.dict[@"city"];
    if (district.length || city.length) {
        addressLab.font = [UIFont systemFontOfSize:14];
        addressLab.textColor = HEX(@"404040", @"dddddd");
        addressLab.text = district.length ? district : city;
        [addressLab sizeToFit];
        addressLab.frame = CGRectMake(CGRectGetMaxX(distanceLab.frame)+16, CGRectGetMaxY(titleLab.frame)+12, addressLab.width, 14);
        [view addSubview:addressLab];
    }
    //按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = HEX(@"FFCC00");
    [button setTitle:@"开始导航" forState:UIControlStateNormal];
    [button setTitleColor:HEX(@"404040", @"dddddd") forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(openThirdNavigation) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(40, 94, SCREEN_WIDTH-80, 44);
    button.layer.cornerRadius = 4;
    [view addSubview:button];
    
    [self.view addSubview:view];
}

#pragma mark - ACTIONS
///=============================================================================
/// @name ACTIONS
///=============================================================================

- (void)openThirdNavigation {
    NSMutableArray *mut = @[].mutableCopy;
    // 百度地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        [mut addObject:[self baiduAction]];
    }
    // 高德地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        [mut addObject:[self gaodeAction]];
    }
    // 苹果地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"map://"]]) {
        [mut addObject:[self appleAction]];
    }
    [mut addObject:[DMAlertActions cancelAction:@"取消"]];
    [DMAlert alert].addActions(mut.copy).type(DMAlertTypeSheet).show(nil);
}

- (DMAlertAction *)baiduAction {
    id block = ^(DMAlertAction *action){
        NSString *urlStr = FORMAT(@"baidumap://map/direction?origin={{我的位置}}&destination=name:%@|latlng:%f,%f&mode=driving&src=app.navi.斗米.斗米", self.dict[@"address"], [self.dict[@"lat"] floatValue], [self.dict[@"lng"] floatValue]);
        NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:url];
    };
    return [DMAlertAction action].title(@"百度地图").handler(block);
}

- (DMAlertAction *)gaodeAction {
    id block = ^(DMAlertAction *action){
        CLLocationCoordinate2D coordinate2d = [self transformFromBaiduToGCJ:self.coor];
        NSString *urlStr = FORMAT(@"iosamap://path?sourceApplication=%@&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&t=0", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"], coordinate2d.latitude, coordinate2d.longitude, self.dict[@"address"]);
        NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:url];
    };
    return [DMAlertAction action].title(@"高德地图").handler(block);
}

- (DMAlertAction *)appleAction {
    id block = ^(DMAlertAction *action){
        CLLocationCoordinate2D coordinate2d = [self transformFromBaiduToGCJ:self.coor];
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate2d addressDictionary:nil]];
        toLocation.name = self.dict[@"address"];
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    };
    return [DMAlertAction action].title(@"苹果地图").handler(block);
}

static const double xPi = M_PI  * 3000.0 / 180.0;
- (CLLocationCoordinate2D)transformFromBaiduToGCJ:(CLLocationCoordinate2D)p {
    double x = p.longitude - 0.0065, y = p.latitude - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * xPi);
    double theta = atan2(y, x) - 0.000003 * cos(x * xPi);
    CLLocationCoordinate2D geoPoint;
    geoPoint.latitude  = z * sin(theta);
    geoPoint.longitude = z * cos(theta);
    return geoPoint;
}

@end
