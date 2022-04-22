//
//  ViewController.m
//  ReLocation
//
//  Created by TTian on 2022/4/21.
//
/**
 卖好车定位 30.289365438269165 119.99907767216793
 */
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ChangeLoction.h"
@interface ViewController ()<CLLocationManagerDelegate>

@property(nonatomic, strong)CLLocationManager *locationManager;
// 经度
@property (weak, nonatomic) IBOutlet UILabel *longitudeLab;
// 纬度
@property (weak, nonatomic) IBOutlet UILabel *latitudeLab;
// 市
@property (weak, nonatomic) IBOutlet UILabel *localityLab;
// 区
@property (weak, nonatomic) IBOutlet UILabel *subLocalityLab;
// 街道
@property (weak, nonatomic) IBOutlet UILabel *thoroughfareLab;

// 具体位置
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@end

@implementation ViewController
//iOS，原生坐标系为 WGS-84
- (void)viewDidLoad {
    [super viewDidLoad];
    [self startLocation];
    // Do any additional setup after loading the view.
    //如果要想知道任意位置的坐标
    //1.去高德地图http://lbs.amap.com/console/show/picker，选中自己坐标
    // 杭州余杭杭州师范大学附属仓前实验中学 119.998395,30.287791
    // 有用的位置 119.999456,30.28891
    // 卖好车定位 30.289365438269165 119.99907767216793
    // 郑东新区规划局 113.758891,34.774666
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(30.289365438269165,119.99907767216793);
    CLLocationCoordinate2D WGSlocation2D = [ChangeLoction gcj02ToWgs84:location2D];
    NSLog(@"纬度：%f,经度：%f",WGSlocation2D.latitude , WGSlocation2D.longitude);
//    //3.去ReLocation.gpx修改经纬度
    self.longitudeLab.text = [NSString stringWithFormat:@"%f",WGSlocation2D.longitude];
    self.latitudeLab.text = [NSString stringWithFormat:@"%f",WGSlocation2D.latitude];
}


-(void)startLocation{
    //判断定位是否允许
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 1.0;
        [_locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    } else {
        //如果没有授权定位，提示开启
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"允许定位" message:@"请在设置中打开定位" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ensure = [UIAlertAction actionWithTitle:@"打开定位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                NSLog(@"%d",success);
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:ensure];
        [alertVC addAction:cancel];
        [self.navigationController presentViewController:alertVC animated:YES completion:nil];
    }
}
#pragma mark - CLLocationManagerDelegate
//更新用户位置
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"%@",locations);
    //当前所在城市的坐标值
    CLLocation *currLocation = [locations lastObject];
    NSLog(@"当前纬度:%lf 当前经度:%lf 当前高度:%lf", currLocation.coordinate.latitude, currLocation.coordinate.longitude,currLocation.altitude);
   
    //根据经纬度反编译地址信息
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {

        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks[0];
            NSLog(@"当前用户所在城市：%@",placeMark.locality);
            NSLog(@"%@",placeMark.country);//当前国家
            NSLog(@"%@",placeMark.locality);//当前城市
            NSLog(@"%@",placeMark.subLocality);//当前位置
            NSLog(@"%@",placeMark.thoroughfare);//当前街道
            NSLog(@"%@",placeMark.name);//具体地址  市  区  街道

            NSString *address = [NSString stringWithFormat:@"%@%@%@",placeMark.locality,placeMark.subLocality,placeMark.name];
            NSLog(@"%@",address);
            self.localityLab.text = [NSString stringWithFormat:@"%@",placeMark.locality];
            self.subLocalityLab.text = [NSString stringWithFormat:@"%@",placeMark.subLocality];
            self.thoroughfareLab.text = [NSString stringWithFormat:@"%@",placeMark.thoroughfare];
            self.nameLab.text = [NSString stringWithFormat:@"%@",placeMark.name];
        } else if (error == nil && placemarks.count == 0) {
            NSLog(@"没有地址返回");
        } else if (error) {
            NSLog(@"%@",error);
        }
    }];
}

//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        //访问被拒绝
        NSLog(@"位置访问被拒绝");
    } else if (error.code == kCLErrorLocationUnknown) {
        NSLog(@"无法获取用户信息");
    }
}

@end
