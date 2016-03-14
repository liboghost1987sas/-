//
//  WRSportRecordViewController.m
//  WeRun
//
//  Created by 梦想起飞 on 16/3/9.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRSportRecordViewController.h"
#import "sporttype.h"
#import "WRUserInfo.h"
#import "WRXMPPTool.h"
#import "NSString+md5.h"
#import "AFNetworking.h"
#import "WRSportRecord.h"
#import "WRSportRecordTableViewCell.h"

@interface WRSportRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
//用来存放运动记录的数组
@property(nonatomic,strong)NSMutableArray *sportDatas;//可以用懒加载
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//当前选中的按钮
@property (weak, nonatomic) IBOutlet UIButton *currentSelected;
//选择运动模式的方法
- (IBAction)selectSportModel:(UIButton *)sender;
//记录前一个选中的button
@property(nonatomic,strong)UIButton *preSelected;


@end

@implementation WRSportRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.sportDatas = [NSMutableArray array];
    self.preSelected = self.currentSelected;//前一个选中的按钮赋值成当前选中的按钮.这是默认状态
    [self loadSportRecordFromWebServerByType:SportTypeRun];
}
//从web服务器上根据类型获取运动记录的数据
-(void)loadSportRecordFromWebServerByType:(enum SportType) type{
    NSString *url = [NSString  stringWithFormat:@"http://%@:8080/allRunServer/queryUserDataByType.jsp",WRXMPPHOSTNAME];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [WRUserInfo sharedWRUserInfo].userName;
    parameters[@"md5password"] = [[WRUserInfo sharedWRUserInfo].userPasswd md5StrXor];
#warning 下面要改
    parameters[@"sportType"] = @(SportTypeRun);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SportRecord%@",responseObject);
        NSArray *array = responseObject[@"sportData"];
        //清除上一次的数据
        [self.sportDatas removeAllObjects];
        
        //使用KVC把字典转成模型
        for(int i =0;i < array.count;i++){
            WRSportRecord *rec = [[WRSportRecord alloc]init];
            [rec setValuesForKeysWithDictionary:array[i]];
            [self.sportDatas addObject:rec];
            
        }
        [self.tableView reloadData];//刷新
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"SportRecord错误%@",error);

    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark --UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sportDatas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WRSportRecordTableViewCell *cell  = [self.tableView dequeueReusableCellWithIdentifier:@"sportRecCell"];
    WRSportRecord *rec = self.sportDatas[indexPath.row];
    //MVC MVVM(Service)
    [cell setSportRecordData:rec];
    return cell;
}
- (IBAction)selectSportModel:(UIButton *)sender {
    if (self.currentSelected == sender) {
        return;
    }
    self.currentSelected = sender;
    self.currentSelected.selected = YES;
    self.preSelected.selected = NO;
    self.preSelected = self.currentSelected;
    //根据选择的模式不同加载不同的数据
    [self loadSportRecordFromWebServerByType:sender.tag];
    
}
@end
