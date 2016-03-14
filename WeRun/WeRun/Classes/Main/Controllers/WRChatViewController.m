//
//  WRChatViewController.m
//  WeRun
//
//  Created by 梦想起飞 on 16/3/4.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRChatViewController.h"
#import "WRXMPPTool.h"
#import "WRUserInfo.h"
#import "UIImageView+WRRoungImage.h"
#import "WRMyMsgTableViewCell.h"

@interface WRChatViewController ()<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hegihtForBottom;
@property (weak, nonatomic) IBOutlet UITextField *sendtextField;
@property(nonatomic,strong)NSFetchedResultsController *fechControl;//结果集控制器
- (IBAction)imageBtnClick:(id)sender;

@end

@implementation WRChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //这里是写加载一次的
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //适应自动布局
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //写了自动布局还要写预估高度，苹果就是这么设定的，没有为什么
    self.tableView.estimatedRowHeight = 70;//这里的预估值写多少都可以，写的差不多数字可以提升加载cell的速度
    [self loadMsg];
}

//加载聊天记录的方法
-(void)loadMsg{
    //获取context
    NSManagedObjectContext *context = [[WRXMPPTool sharedWRXMPPTool].xmppMsgArchStore mainThreadManagedObjectContext];
    // 关联entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //设置条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and bareJidStr = %@" ,[WRUserInfo sharedWRUserInfo].jidStr,[self.friendJid bare]];//当前跟谁聊天
    //设置排序 以时间排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"timestamp"/*时间戳*/ ascending:YES];
    request.predicate = pre;
    request.sortDescriptors = @[sortDes];
    //执行得到结果
    self.fechControl = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    self.fechControl.delegate = self;
    [self.fechControl performFetch:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}
//视图即将可见时调用
//增加监听
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //增加通知
    [[NSNotificationCenter defaultCenter/*通知中心*/]addObserver:self selector:@selector(openKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter/*通知中心*/]addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}
//移除监听
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:/*前面监听方法写的什么这里就写什么*/UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
-(void)openKeyboard:(NSNotification*/*参数传的是通知*/) notification{
    // 拿text的高度约束
    CGRect Keyboardframe = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    //动画时间
    NSTimeInterval durations = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    self.hegihtForBottom.constant = Keyboardframe.size.height;
    [UIImageView animateWithDuration:durations delay/*延时*/:0 options:options animations:^{
        [self.tableView layoutIfNeeded];
        [self scrollTable];//打开textFile时键盘跟着往上面顶
    } completion:^(BOOL finished) {
        //这里暂时不做什么
    }];
}
-(void)closeKeyboard:(NSNotification*/*参数传的是通知*/) notification{
    //动画时间
    NSTimeInterval durations = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    self.hegihtForBottom.constant = 0;
    [UIImageView animateWithDuration:durations delay/*延时*/:0 options:options animations:^{
        [self.tableView layoutIfNeeded];
    } completion:^(BOOL finished) {
        //这里暂时不做什么
    }];
   
}
#pragma mark -- tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fechControl.fetchedObjects.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [[UITableViewCell alloc]init];
    WRMyMsgTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"myMsgCell"/*重用标识在storyboard里的Chat View Controller下myMsgCell里的最右边第三栏Identifier的名字是什么这里就写什么*/];
    XMPPMessageArchiving_Message_CoreDataObject *msgObject = self.fechControl.fetchedObjects[indexPath.row];
      //区分到底是谁发出的信息
    if (msgObject.isOutgoing) {
    //逻辑实现
    }else{
        
    }
    if([msgObject.body hasPrefix:@"text:"]){
        cell.textMsgLabel.text = [msgObject.body substringFromIndex:5];//从第5个字符开始截取
        
    }else if ([msgObject.body hasPrefix:@"image:"]){
        NSString *base64Str = [msgObject.body substringFromIndex:6];
        NSData *imagedata = [[NSData alloc]initWithBase64EncodedString:base64Str options:0/*前面传的是0这里就写0*/];
        cell.imageMsgView.image = [UIImage imageWithData:imagedata];
        
    }
    
    NSData *headImaegData = [[WRXMPPTool sharedWRXMPPTool].xmppvCardAvar photoDataForJID:[XMPPJID jidWithString:[WRUserInfo sharedWRUserInfo].jidStr]];
    
    if (headImaegData) {
        cell.headImageView.image = [UIImage imageWithData:headImaegData];
        
    }else{
        cell.headImageView.image = [UIImage imageNamed:@"YY"];
    }
    
    return cell;
    
 }
//打开相册选择图片
- (IBAction)imageBtnClick:(id)sender {
    UIImagePickerController *pc = [UIImagePickerController new];
    pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pc.delegate = self;
    [self presentViewController:pc animated:YES completion:nil];//显示图片
}
//图片选择
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];//拿到不可编辑的原图
    //测试原图到底占多大内存空间，可以不写这句话
    NSLog(@"image length = %ld",UIImagePNGRepresentation(image).length);
    //图片太大了，要生成缩略图 控制用户的流量 给用户好的体验
    UIImage *image2 = [self thumbnaiWithImage:image size:CGSizeMake(100, 100)];
    NSLog(@"image2 length = %ld",UIImagePNGRepresentation(image2).length);
    NSData *data = UIImageJPEGRepresentation/*JPEG能手动指定图片的质量*/(image2, 0.05);
    NSLog(@"image3 length = %ld",data.length);
    [self sendImageMethod:data];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//生成缩略图的方法
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
//发送图片信息
-(void)sendImageMethod:(NSData *) data{
    //思考怎么把一个二进制转换成文本
    NSString *base64Str/*base64编码*/ = [data base64EncodedStringWithOptions:0];//编码时用0，解码时也用0
//组装消息
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    NSString *dataStr = [NSString stringWithFormat:@"image:%@",base64Str];
    [msg addBody:dataStr];
    //发送消息
    [[WRXMPPTool sharedWRXMPPTool].xmppStream sendElement:msg];
    
}

//发送文本消息
- (IBAction)sendTextMethod:(id)sender {
    NSString *msgText = self.sendtextField.text;
    //组装一个消息
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat"/*这里一般写chat或chatroom*/ to:self.friendJid];
     //自定义一个base64数据标准
    NSString *dataStr = [NSString stringWithFormat:@"text:%@",msgText];
    [msg addBody:dataStr];
    //发送消息
    [[WRXMPPTool sharedWRXMPPTool].xmppStream sendElement:msg];
    
}

//结果集发生变化，刷新。发完消息给别人后，返回结果后，刷新才有效
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];//刷新界面，显示传来的消息
    [self scrollTable];
}
//滚动到表格最后一行
-(void)scrollTable{
    NSInteger index = self.fechControl.fetchedObjects.count - 1;
    if (index < 0) {
        return;//如果行数小于0，则不滚动
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0/*0是最开始的值*/];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom/*滚动到底部*/ animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
