//
//  WRFriendsViewController.m
//  WeRun
//
//  Created by 梦想起飞 on 16/3/3.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRFriendsViewController.h"
#import "WRXMPPTool.h"
#import "WRUserInfo.h"
#import "UIImageView+WRRoungImage.h"
#import "WRFriendCell.h"
#import "WRChatViewController.h"

@interface WRFriendsViewController ()<NSFetchedResultsControllerDelegate>/*回去查NSFetchedResultsControllerDelegate的作用*/
//@property(nonatomic,strong)NSArray *friends;
//结果集控制器
- (IBAction)backBtnClick:(id)sender;
@property(nonatomic,strong)NSFetchedResultsController *fetchController;
@end

@implementation WRFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //加载好友
    [self loadFriend];
    
}
-(void)loadFriend{
    //获取上下文
    NSManagedObjectContext  *context =[[WRXMPPTool sharedWRXMPPTool].xmppRoserStore mainThreadManagedObjectContext];
    //关联实体 这里用XMPPRoster.xcdatamodel中的XMPPUserCoreDataStorageObject
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    //设置过滤条件  NSPredicate这里是意思是过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[WRUserInfo sharedWRUserInfo].jidStr];
    request.predicate = pre;
    //排序 (以姓名排序)
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors  = @[sortDes];//这里是request要求包装成数组，就需要强转
    //获取数据
    NSError *error = nil;
    //后面写的是结果集控制器返回的结果，用于删除联系人并同步显示到界面上
    self.fetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchController.delegate = self;
    [self.fetchController performFetch:&error];
    if (error) {
        NSLog(@"获取数据%@",error);
    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.fetchController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *identifer = @"friendCell";
    WRFriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifer];
    //取数据在friends数组里面取得其中一个frend名称
//    XMPPUserCoreDataStorageObject *friend = self.friends[indexPath.row];
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    //这里想取得头像不能用photo属性,因为photo里什么也没有.在xmppvCardAvar里找
    NSData *data = [[WRXMPPTool sharedWRXMPPTool].xmppvCardAvar photoDataForJID:friend.jid];
    if (data) {
        cell.headImageView.image = [UIImage imageWithData:data];
        
    }else{
        //如果没有头像就用默认的头像
        cell.headImageView.image = [UIImage imageNamed:@"YY"];
    }
    [cell.headImageView setRoundlayer];//头像画圆圈
    cell.userNameLabel.text = friend.jidStr;
    switch ([friend.sectionNum intValue]) {
        case 0://0就是在线
            cell.friendStatusLabel.text = @"在线";
            break;
        case 1:
            cell.friendStatusLabel.text = @"离开";
            break;
        case 2:
            cell.friendStatusLabel.text = @"离线";
            break;
        default:
            break;
    }
    
    return cell;
}
//数据变化
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];//刷新
}
//删除模式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除好友
        [[WRXMPPTool sharedWRXMPPTool].xmppRoser removeUser:friend.jid];//要删除谁，把谁的JID告诉xmppRoser即可
        
    }
}

//跳转之前设置参数 (就是Main.storyBoard 里面的一根跳转线名称chatSegue)
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id desVc = segue.destinationViewController;
    if ([desVc isKindOfClass:[WRChatViewController class]]) {
        WRChatViewController *des = desVc;
        des.friendJid = sender;
        
    }
}
//选中某一行 进行跳转
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPUserCoreDataStorageObject *f = self.fetchController.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"chatSegue" sender:f.jid];
}

- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
