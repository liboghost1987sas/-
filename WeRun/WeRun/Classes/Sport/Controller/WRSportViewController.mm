//
//  WRSportViewController.m
//  WeRun
//
//  Created by 梦想起飞 on 16/3/6.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRSportViewController.h"
#import "BMapKit.h"
#import "AFNetworking.h"
#import "WRUserInfo.h"
#import "NSString+md5.h"
#import "sporttype.h"

//#import "MBProgressHUD+KR.h"我自己加的
//控制是否开始跑步(是否在地图上开始划线)
typedef enum {
    TrailStart  = 1,
    TrailEnd 
}Trail;//路径
@interface WRSportViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
//百度地图的View
@property(nonatomic,strong)BMKMapView *mapView;
//百度地图位置服务
@property(nonatomic,strong)BMKLocationService *bmkLocationService;
//开始跑步的按钮
- (IBAction)startSportBtnClick:(id)sender;//这里是方法
//控制是否开始跑步的属性
@property(nonatomic,assign)Trail/*枚举类型不要带"*"*/ trail;
@property (weak, nonatomic) IBOutlet UIButton *statSportBtn;//这里是属性
//暂停按钮
@property (weak, nonatomic) IBOutlet UIButton *pauseSportBtn;
//起点和终点的大头针
@property(nonatomic,strong)BMKPointAnnotation *startPoint;
@property(nonatomic,strong)BMKPointAnnotation *endPoint;

//遮盖线
@property(nonatomic,strong)BMKPolyline *polyLine;

//用户位置的数组
@property(nonatomic,strong)NSMutableArray *locationArrayM;//这里用NSMutableArray,是没法确定用户具体的经纬度坐标
//保存用户的上一个位置,这里里记录用户的上一个位置是为计算用户的跑步距离,比如抱一个圈
@property(nonatomic,strong)CLLocation *preLoacation;

//运动的总距离
@property(nonatomic,assign)double/*距离是数字就是double类型*/ sumDistance;
//运动的总时间
@property(nonatomic,assign)double sumSportTime;
//运动的总热量
@property(nonatomic,assign)double sumHeat;

//暂停视图
@property (weak, nonatomic) IBOutlet UIView *pauseView;
//继续按钮被点击
- (IBAction)continueBtnClick:(id)sender;
//完成按钮被点击
- (IBAction)finishBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *finishSportView;

// 取消与保存按钮
- (IBAction)cancelSportBtnClick:(id)sender;
- (IBAction)saveSportBtnClick:(id)sender;
//分享
- (IBAction)shareWRSportBtnClick:(id)sender;
- (IBAction)shareSinaBtnClick:(id)sender;

//选择运动模式
- (IBAction)choseSportModel:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *sportModelView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *currentSportModel;
- (IBAction)selectSportModel:(UIButton *)sender;
//当前选中哪一个Button
@property(nonatomic,strong)UIButton *preButton;
//下面是验证，以后要删除
@property (weak, nonatomic) IBOutlet UIButton *currentSelectBtn;
/** 用来标识现在的运动模式 */
@property (assign,nonatomic) enum SportType sportType;
@end

@implementation WRSportViewController
// 懒加载
//这里是getter方法
-(NSMutableArray *)locationArrayM{
    if (!_locationArrayM) {
        _locationArrayM = [NSMutableArray array];
    }
    return _locationArrayM;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView  = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    self.trail = TrailEnd;
    //将mapView永远插入到bounds的最下层
    [self.view insertSubview:self.mapView atIndex:0];
    [self setMapViewProperty];
    [self setLocationServiceInit];
    self.mapView.delegate = self;
    self.bmkLocationService.delegate = self;
    //启动定位服务
    [self.bmkLocationService startUserLocationService];
    //给暂停按钮增加手势识别
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]initWithTarget/*哪一个目标对象*/:self action:@selector(pauseBtnSwipe)];
    gesture.direction = UISwipeGestureRecognizerDirectionDown;
    //增加手势识别
    [self.pauseSportBtn addGestureRecognizer:gesture];
    self.preButton = self.currentSelectBtn;
    self.sportType = SportTypeRun;
    
    
}
//滑动暂停按钮 的逻辑
-(void)pauseBtnSwipe{
    /** 停止定位服务 */
    [self.bmkLocationService stopUserLocationService];
    self.pauseView.hidden = NO;
    self.pauseSportBtn.hidden = YES;
    
}
//位置服务初始化设置
-(void)setLocationServiceInit{
    self.bmkLocationService = [[BMKLocationService alloc]init];
    //距离过滤器
    [BMKLocationService setLocationDistanceFilter:10];//10米定位1回
    //期望的精度
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];//最高精度
    self.mapView.rotateEnabled = NO;//允许旋转
    self.mapView.showMapScaleBar = YES;//比例尺
    self.mapView.mapScaleBarPosition = CGPointMake(self.view.frame.size.width - 50, self.view.frame.size.height - 50);//设定比例尺显示到哪里去了
    //设置定位图层的自定义显示
    BMKLocationViewDisplayParam  *displayPara = [[BMKLocationViewDisplayParam alloc]init];
    displayPara.isAccuracyCircleShow = NO;
    displayPara.isRotateAngleValid = NO;
    displayPara.locationViewOffsetX = 0;//这里是定位x修正
    displayPara.locationViewOffsetY = 0;//这里是定位y修正
    [self.mapView updateLocationViewWithParam:displayPara];
}
//百度地图View的设置
-(void)setMapViewProperty{
    self.mapView.showsUserLocation = YES;//这个非常重要
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
}
//用户位置更新
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    NSLog(@"用户位置变化:%lf:%lf",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [self.mapView updateLocationData:userLocation];
    //如果程序刚进来self.trail == TrailEnd 然后...
    if(self.trail == TrailEnd){
        BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.001,0.001))];
        [self.mapView setRegion:adjustRegion animated:YES];
    }
    //判断用户是否在户外
    if (userLocation.location.horizontalAccuracy > kCLLocationAccuracyNearestTenMeters) {
//        [MBProgressHUD showMessage:@"请到户外跑步才能使这款软件有意义"];//我自己加的
        return;
    }
    //开始运动
    if (self.trail == TrailStart) {
        //开始记录用户的位置(连续追踪)
        [self startTarilRouterWithUserLocation:userLocation];
        [self.mapView setRegion:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.002, 0.002))];
    }
    
}
//用户路径追踪
-(void)startTarilRouterWithUserLocation:(BMKUserLocation *)userLocation{
    if(self.preLoacation){
//      计算当前点和前一个点的距离
        double distance = [userLocation.location distanceFromLocation:self.preLoacation];
        self.sumDistance += distance;
    }
        self.preLoacation = userLocation.location;
     //把用户当前位置,放入数组
    [self.locationArrayM addObject:userLocation.location];
    //根据数组中的位置,绘制到地图上
    [self drawWalkLine];
}

//划线
-(void)drawWalkLine{
    NSInteger count =  self.locationArrayM.count;
    //结构体
    //栈里的内存自动回收,堆里的内存要手工释放
    int x;
    //这是c语言的动态内存分配
    //    BMKMapPoint *points = (BMKMapPoint *)malloc(sizeof(BMKMapPoint)*count);
    BMKMapPoint *points = new/*new在C++里表示堆分配*/BMKMapPoint[count];
    //把locationArrm中的位置转换成BMKMapPoint存入points对应的堆内存中
    [self.locationArrayM enumerateObjectsUsingBlock/*这是OC封装的for循环*/:^(CLLocation* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //结构体里不能加*
        //根据位置坐标装换成一个点对象
        BMKMapPoint point = BMKMapPointForCoordinate(obj.coordinate);
        //points指针
        points[idx] = point;
        
    }];
    //移除原有的线
    if (self.polyLine) {
        [self.mapView removeOverlay:self.polyLine];//如果原来有路径值就移除
    }
    self.polyLine = [BMKPolyline polylineWithPoints:points count:count];
    //把折线绘制到地图上
    [self.mapView addOverlay:self.polyLine];
    //C语言 释放堆内存
    //free(points);
    //C++的堆内存释放
    delete[] points;
    
    
    
}
//折线如何显示
-(BMKOverlayView *) mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class] ]) {
        BMKPolylineView *polyLineView = [[BMKPolylineView alloc]initWithOverlay:overlay];
        polyLineView.lineWidth = 5.0;
        polyLineView.strokeColor = [UIColor greenColor];
        return polyLineView;
        
    }
    return nil;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


//点击开始跑步的按钮
- (IBAction)startSportBtnClick:(id)sender {
    
    self.statSportBtn.hidden = YES;
    self.pauseSportBtn.hidden = NO;
    self.trail = TrailStart;//把trail的状态改成TrailStart;
    //产生一个大头针代表运动起点的开始
    self.startPoint = [self createPointAnnotion:self.bmkLocationService.userLocation.location titile:@"起点"];
    //把用户当前位置放入 locationArrayM
//    [self.locationArrayM addObject:self.bmkLocationService.userLocation.location];
}
//用来产生大头针的方法
-(BMKPointAnnotation *)createPointAnnotion:(CLLocation *)location titile:(NSString *)title{
    BMKPointAnnotation *point = [BMKPointAnnotation new];
    point.coordinate = location.coordinate;
    point.title = title;
    //添加大头针
    [self.mapView addAnnotation:point];
    return point;
}
//显示大头针
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    //如果大头针是点类型的
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *view = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        //如果是起点就设置起点图片,否则设置终点图片
        if(self.startPoint/*这里代表self.startpoint有值就是终点不要弄混*/){
            view.image = [UIImage imageNamed:@"定位-终"];
        }else{
            view.image = [UIImage imageNamed:@"定位－起"];
        }
        view.animatesDrop = YES;
        view.draggable = NO;
        return view;
    }
    return nil;
}
//继续按钮点击
- (IBAction)continueBtnClick:(id)sender {
    self.pauseView.hidden = YES;
    self.pauseSportBtn.hidden = NO;
    
    [self.bmkLocationService startUserLocationService];
    
    
}
/**
 *  点击完成按钮
 * 1.把用户的位置点 都显示在地图的显示范围内
 * 2.出现一个视图,可以取消本地运动保存本次运动的数据可以分享本地运动数据
 分享到运动圈,如果是sina第三方登录 就可以分享到第三方登录
 *
 */

- (IBAction)finishBtnClick:(id)sender {
    self.pauseView.hidden = YES;
    self.trail = TrailEnd;
    [self.bmkLocationService stopUserLocationService];
    self.endPoint = [self createPointAnnotion:[self.locationArrayM lastObject] titile:@"终点"];
    [self mapViewFitForRectForPolyLine];
    //完成热量、时间的计算
    //这里用重构
    CLLocation *firstLoc = [self.locationArrayM firstObject];
    CLLocation *lastLoc = [self.locationArrayM lastObject];
    self.sumSportTime = lastLoc.timestamp.timeIntervalSince1970 - firstLoc.timestamp.timeIntervalSince1970;
    self.sumHeat = (self.sumSportTime/3600.0)*700;
    
    //显示运动完成界面
    self.finishSportView.hidden = NO;
    
}
//根据折线对象中的点,算出显示范围
-(void)mapViewFitForRectForPolyLine{
    //最小的x、y最大的x、y
    CGFloat ltX,ltY,maxX,maxY;
    //如果用户点击的过快就会出BUG，后面写避免逻辑
    if (self.polyLine.pointCount < 2/*测定用户的起始点位置一共小于2个就返回*/) {
        return;
    }
    BMKMapPoint pt = self.polyLine.points[0];
    ltX = pt.x;
    maxX = pt.x;
    ltY = pt.y;
    maxY = pt.y;
    //取出每一个点
    for (int i = 1/*0已经取走了所以是第二个点*/; i < _polyLine.pointCount; i++) {
        BMKMapPoint temp = self.polyLine.points[i];
        if(temp.x < ltX){
            ltX = temp.x;
        }
        if (temp.y < ltY) {
            ltY = temp.y;
        }
        if (temp.x > maxX) {
            maxX = temp.x;
            
        }
        if (temp.y > maxY) {
            maxY = temp.y;
        }
    }
    //得到一个矩形
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX - 40, ltY - 60);
    rect.size = BMKMapSizeMake((maxX - ltX) + 80 , (maxY-ltY) + 120);
    [self.mapView setVisibleMapRect:rect];
    
}


- (IBAction)cancelSportBtnClick:(id)sender {
    [self.bmkLocationService startUserLocationService];//重新启动服务
    self.finishSportView.hidden = YES;
    //状态清理
    self.statSportBtn.hidden = NO;
    [self cleanState];
    //调整显示区域
    BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(self.bmkLocationService.userLocation.location.coordinate, BMKCoordinateSpanMake(0.02, 0.02))];
    [self.mapView setRegion:adjustRegion animated:YES];
    
}
//状态清理
-(void)cleanState{
    self.sumDistance = 0.0;
    self.sumHeat = 0.0;
    self.sumSportTime = 0.0;
    
    //把运动的总时间 消耗的热量 运动模式
    //清空位置数组
    [self.locationArrayM removeAllObjects];
    
    if (self.startPoint) {
        [self.mapView removeAnnotation:self.startPoint];
        self.startPoint = nil;//关键的一句话，虽然起点终点的在地图上去掉了，但指针是悬空的会有隐患！！
    }
    if (self.endPoint) {
        [self.mapView removeAnnotation:self.endPoint];
        self.endPoint = nil;
    }
    if (self.polyLine) {
        [self.mapView removeOverlay:self.polyLine];
        self.polyLine = nil;
    }
}
//点击保存按钮 把数据保存到服务器
- (IBAction)saveSportBtnClick:(id)sender {
    [self saveSportDataToServer];
    [self cancelSportBtnClick:nil];//清理状态
    
}
//这是保存数据到服务器的方法
-(void)saveSportDataToServer{
    //url找“上传运动数据接口”
    NSString *url =  [NSString stringWithFormat:@"http://%@:8080/allRunServer/addSportData.jsp",WRXMPPHOSTNAME];
    //请求参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //参照服务器上写什么这里写什么
    parameters[@"username"] = [WRUserInfo sharedWRUserInfo].userName;
    parameters[@"md5password"] = [[WRUserInfo sharedWRUserInfo].userPasswd md5StrXor];
    parameters[@"sportType"] = @(self.sportType);
    //data这个参数
    CLLocation *firstLoc = [self.locationArrayM firstObject];
    CLLocation *lastLoc = [self.locationArrayM lastObject];
    NSString *dataStr = [NSString stringWithFormat:@"%lf|%lf|%lf@%lf|%lf|%lf",firstLoc.timestamp.timeIntervalSince1970,firstLoc.coordinate.latitude,firstLoc.coordinate.longitude,lastLoc.timestamp.timeIntervalSince1970,lastLoc.coordinate.latitude,lastLoc.coordinate.longitude];
    parameters[@"data"] = dataStr;
    //运动的距离、热量、时间
    parameters[@"sportDistance"/*sportDistance是allRunServer文档里这么写的*/] = @(self.sumDistance);
    double st = lastLoc.timestamp.timeIntervalSince1970 - firstLoc.timestamp.timeIntervalSince1970;
    parameters[@"sportTimeLen"] = @(st);
    parameters[@"sportHeat"] = @((st/3600.0)*[self getHeatOnHourForSportType:self.sportType]);//这里要根据运动模式得到热量
    parameters[@"sportStartTime"] = @(firstLoc.timestamp.timeIntervalSince1970);
    /* 计算总共的距离 热量  总运动时间
     爬楼梯1500级（不计时） 250卡
     快走（一小时8公里） 　　 555卡
     快跑(一小时12公里） 700卡
     单车(一小时9公里) 245卡
     单车(一小时16公里) 415卡
     单车(一小时21公里) 655卡
     舞池跳舞 300卡
     健身操 300卡
     骑马 350卡
     网球 425卡
     爬梯机 680卡
     手球 600卡
     桌球 300卡
     慢走(一小时4公里) 255卡
     慢跑(一小时9公里) 655卡
     游泳(一小时3公里) 550卡
     有氧运动(轻度) 275卡
     有氧运动(中度) 350卡
     高尔夫球(走路自背球杆) 270卡
     锯木 400卡
     体能训练 300卡
     走步机(一小时6公里) 345卡
     轮式溜冰 350卡
     跳绳 660卡
     郊外滑雪(一小时8公里) 600卡
     练武术 790 */
    
    
    //发送请求
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    [manger POST:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"allRunSever请求成功：%@",responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"allRunSever请求失败：%@",error);
    }];
}

//根据运动模式 得到一个小时消耗的热量
-(double)getHeatOnHourForSportType:(enum SportType)type{
  
            double  heat = 0.0;
            switch (type) {
                case SportTypeSkiing:
                    heat = 450.0;
                    break;
                case SportTypeRun:
                    heat = 700.0;
                    break;
                case SportTypeFree:
                    heat = 300.0;
                    break;
                case SportTypeBike:
                    heat = 500.0;
                default:
                    break;
            }
    return heat;
}
//获取截图
-(UIImage *)takeImage{
    UIImage *image = [self.mapView takeSnapshot];
    return image;
}

//生成缩略图
//从“WRChatViewController”里拿来
- (UIImage*) thumbnaiWithImage:(UIImage*)image size:(CGSize) size{
    UIImage *newImage = nil;
    if (image == nil) {
        newImage = nil;
    }else{
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newImage;
}

//点击分享主程序图标,把数据分享到运动圈
- (IBAction)shareWRSportBtnClick:(id)sender {
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServer/addTopic.jsp",WRXMPPHOSTNAME];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [WRUserInfo sharedWRUserInfo].userName;
    parameters[@"md5password"] = [[WRUserInfo sharedWRUserInfo].userPasswd md5StrXor];
    if(self.sumDistance <= 0.0){
        return;//这里是为防止BUG用的
    }
    NSString *dataStr = [NSString stringWithFormat:@"本次运动的总距离是%.1lf米,运动总时间是%.1lf秒，消耗总热量是%.4lf卡",self.sumDistance,self.sumSportTime,self.sumHeat];
    parameters[@"content"] = dataStr;
#warning 这里我去写反地理编码！！
    parameters[@"address"] = @"武汉";
    CLLocation *lastLoc = [self.locationArrayM lastObject];
    parameters[@"latitude"] = @(lastLoc.coordinate.latitude);
    parameters[@"longitude"] = @(lastLoc.coordinate.longitude);
    //开始压缩图片
    UIImage *image = [self takeImage];
    UIImage *newImage = [self thumbnaiWithImage:image size:CGSizeMake(200.0, (200.0/image.size.width/*这里的结果是比例系数*/)*image.size.height/*比例系数x高度*/)];
    NSData *imagedata = UIImagePNGRepresentation(newImage);
    [manger POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSDate *date = [NSDate date];//拿到当前时间
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyyMMddHHmmss"/*在windows下“yyyy-mm”会出BUG*/];
        NSString *dateStr = [format stringFromDate:date];
        NSString *fName/*formName*/ = [NSString stringWithFormat:@"%@%@.png",[WRUserInfo sharedWRUserInfo].userName,dateStr];
        [formData appendPartWithFileData:imagedata name:@"pig" fileName:fName/*想办法让用户每次上传图片的文件名都不一样！*/ mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败%@",error);
    }];
    //保存逻辑
    [self saveSportDataToServer];
    
}
//把运动数据和图片分享到微博
- (IBAction)shareSinaBtnClick:(id)sender {
    if ([WRUserInfo sharedWRUserInfo].isSinaLogin) {
        [self saveSportDataToSina];
        [self cancelSportBtnClick:nil];
    }else{
        NSLog(@"请使用新浪登录");
    }
}

- (IBAction)choseSportModel:(id)sender {
    //把0置成1，把1置成0
    self.sportModelView.hidden = !self.sportModelView.hidden;
}
//发送运动数据到sina的方法
-(void)saveSportDataToSina{
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    NSString *url = @"https://upload.api.weibo.com/2/statuses/upload.json";
    NSMutableDictionary *parameters=[NSMutableDictionary dictionary];
    parameters[@"access_token"] = [WRUserInfo sharedWRUserInfo].userPasswd;//这里写userPasswd是因为当初是用的access_token做的userPasswd，没有单独写成属性。所以才这么写
    NSString *statuesStr = [NSString stringWithFormat:@"本次运动的总距离是%.1lf米,运动总时间是%.1lf秒，消耗总热量是%.4lf卡",self.sumDistance,self.sumSportTime,self.sumHeat];
    //微博文本内容
    parameters[@"status"] = statuesStr;
    [manger POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImagePNGRepresentation([self takeImage]) name:@"pic" fileName:@"sport.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"发微博成功");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发微博失败%@",error);
    }];
}
- (IBAction)selectSportModel:(UIButton *)sender {
    NSLog(@"tag = %ld",sender.tag);
    if (sender == self.preButton) {
        return;
    }//当前选中的button和默认的button一样就return
    //当前按钮就是选中的
    self.currentSelectBtn = sender;//如果不是就把sender值赋值给当前选中的button
    //之前的按钮设置成非选中的
    self.preButton.selected = NO;//把原来的置成NO
    //当前按钮设置成选中的
    sender.selected = YES;//把当前的置成YES
    //把之前选中的button值赋值给现在选中的button
    self.preButton = self.currentSelectBtn;
    self.currentSportModel.image = sender.imageView.image;
    /** 把现在选择的运动模式 赋值 */
    switch ((sender.tag -100)) {
        case SportTypeBike:
            self.sportType = SportTypeBike;
            break;
        case SportTypeFree:
            self.sportType = SportTypeFree;
            break;
        case SportTypeRun:
            self.sportType = SportTypeRun;
            break;
        case SportTypeSkiing:
            self.sportType = SportTypeSkiing;
            break;
        default:
            break;
    }

    
}
@end
