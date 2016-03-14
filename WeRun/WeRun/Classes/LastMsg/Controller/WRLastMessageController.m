//
//  WRLastMessageController.m
//  WeRun
//
//  Created by 梦想起飞 on 16/3/5.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRLastMessageController.h"
#import "WRXMPPTool.h"
#import "WRUserInfo.h"
#import "UIImageView+WRRoungImage.h"
#import "WRChatViewController.h"

@interface WRLastMessageController ()<NSFetchedResultsControllerDelegate>
@property(nonatomic,strong)NSFetchedResultsController *fechControl;
- (IBAction)backBtnClick:(id)sender;

@end

@implementation WRLastMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadLastMsg];
    
}
//加载最后消息的方法
-(void)loadLastMsg{
    /** 获取context */
    NSManagedObjectContext *context =
    [[WRXMPPTool sharedWRXMPPTool].xmppMsgArchStore mainThreadManagedObjectContext];
    /** 关联entity */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:
                               @"XMPPMessageArchiving_Contact_CoreDataObject"];
    /** 设置条件 */
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[WRUserInfo sharedWRUserInfo].jidStr];
    /** 设置排序 以聊天时间排序 */
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp"/*时间戳与时间戳名字不同不能混写，要看清楚*/ ascending:YES];
    request.predicate = pre;
    request.sortDescriptors = @[sortDes];
    /** 执行得到结果 */
    self.fechControl = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error  = nil;
    self.fechControl.delegate = self;
    [self.fechControl performFetch:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.fechControl.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    XMPPMessageArchiving_Contact_CoreDataObject *obj = self.fechControl.fetchedObjects[indexPath.row];
    if([obj.mostRecentMessageBody hasPrefix:@"image:"]){
        cell.textLabel.text = @"图片";
    }else if([obj.mostRecentMessageBody hasPrefix:@"text:"]){
        cell.textLabel.text = [obj.mostRecentMessageBody substringFromIndex:5];//这里截取text:不让用户看见
        
    }
    
    return cell;
}

- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //先取出对象
    XMPPMessageArchiving_Contact_CoreDataObject *obj = self.fechControl.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"chatSegue2" sender:obj.bareJid/*好友的JID*/];
    
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id vc = segue.destinationViewController;
    if ([vc isKindOfClass:[WRChatViewController class]]) {
        WRChatViewController *des = (WRChatViewController *)vc;
        des.friendJid = sender;
        
    }
}
@end
