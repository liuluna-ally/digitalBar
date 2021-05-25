//
//  RecordViewController.m
//  digitalbar2020
//  反馈记录界面
//  Created by user on 2020/11/16.
//

#import "RecordViewController.h"
#import "FeedBackViewController.h"

@interface RecordViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSString *unreachNetwork;
@property NSString *unserver;
@property NSString *tips;
@property NSString *determine;
@property NSString *queryFailed;
@property NSString *cancel;
@property NSString *delete;
@property NSMutableArray *result; //搜索结果
@property NSMutableArray *showResult; //展示结果
@property NSDictionary *dict; //删除结果
@property NSString *username;
@property NSString *type;

@property (strong, nonatomic) UIAlertAction *okAction;
@property (strong, nonatomic) UIAlertAction *cancelAction;


@end

@implementation RecordViewController
- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        _unreachNetwork = NSLocalizedString(@"unreachNetwork", nil);
        _unserver = NSLocalizedString(@"unserver", nil);
        _tips = NSLocalizedString(@"Tips", nil);
        _determine = NSLocalizedString(@"determine", nil);
        _queryFailed = NSLocalizedString(@"queryFailed", nil);
        _cancel = NSLocalizedString(@"cancel", nil);
        _delete = NSLocalizedString(@"delete", nil);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset = UIEdgeInsetsZero;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if([userDefaults objectForKey:@"username"] && [userDefaults objectForKey:@"type"]){
           self.username = [userDefaults objectForKey:@"username"] ;
           self.type = [userDefaults objectForKey:@"type"] ;
            [self getAllRecord:_username andType:_type];
        }
        
        //1.创建navbar
        UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
        nav.barTintColor = [UIColor whiteColor];    
        //创建navbaritem
        UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:[userDefaults objectForKey:@"type"]];
        [nav pushNavigationItem:navTitle animated:YES];
        [self.view addSubview:nav];
        //创建barbutton 创建系统样式的
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
        //设置barbutton
        navTitle.leftBarButtonItem = item;
        [nav setItems:[NSArray arrayWithObject:navTitle]];
        //2.下拉刷新
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor grayColor];
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
        [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
        self.tableView.refreshControl = refreshControl;
        
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

// 返回按钮按下
- (void)navBackBt:(UIButton *)sender{
    //跳转到下一页面
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedBackViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"feedback"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

//加载数据
-(void)loadData{
    NSLog(@"手动刷新了");
    [self getAllRecord:_username andType:_type];
    //停止刷新
    if ([self.tableView.refreshControl isRefreshing]) {
        [self.tableView.refreshControl endRefreshing];
    }
}

// MARK: - 设置数据源

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        return self.result.count;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    @try {
        //indexPath.section  几组    indexPath.row 几行
        UITableViewCell *cell = [self customCellWithOutXib:tableView withIndexPath:indexPath];
        //添加长按手势
        UILongPressGestureRecognizer * longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellLongPress:)];
        
        longPressGesture.minimumPressDuration=1.0f;//设置长按 时间
        [cell addGestureRecognizer:longPressGesture];
        return cell;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

-(void)cellLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    
    
    if (longRecognizer.state==UIGestureRecognizerStateBegan) {
        //成为第一响应者，需重写该方法
        [self becomeFirstResponder];
        
        CGPoint location = [longRecognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        //可以得到此时你点击的哪一行
        
        // 初始化对话框
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.delete preferredStyle:UIAlertControllerStyleAlert];
        // 确定
        self.okAction = [UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            NSString *row = [NSString stringWithFormat:@"%@", [self.result[indexPath.row] objectForKey:@"id"]];
            NSLog(@"row:%@",row);
            [self deleteRecord:row];
        }];
        self.cancelAction =[UIAlertAction actionWithTitle:self.cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action){
            
        }];
        
        [alert addAction:self.okAction];
        [alert addAction:self.cancelAction];
        
        // 弹出对话框
        [self presentViewController:alert animated:true completion:nil];
        
    }
    
    
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}

//通过代码自定义cell
-(UITableViewCell *)customCellWithOutXib:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath{
    @try {
        //定义标识符
        static NSString *customCellIndentifier = @"CustomCellIndentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customCellIndentifier];
        
        //定义新的cell
        if(cell == nil){
            //使用默认的UITableViewCell,但是不使用默认的image与text，改为添加自定义的控件
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIndentifier];
            //反馈内容
            CGRect contentRect = CGRectMake(20, 20, 96, 96);
            UILabel *contentLabel = [[UILabel alloc]initWithFrame:contentRect];
            contentLabel.tag = contentTag;
            contentLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            [cell.contentView addSubview:contentLabel];
            
            //联系方式
            CGRect contactRect = CGRectMake(20, 100, 200, 24);
            UILabel *contatcLabel = [[UILabel alloc]initWithFrame:contactRect];
            contatcLabel.tag = contactTag;
            contatcLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            [cell.contentView addSubview:contatcLabel];
            
            //时间
            CGRect timeRect = CGRectMake(300, 100, 200, 24);
            UILabel *timeLabel = [[UILabel alloc]initWithFrame:timeRect];
            timeLabel.tag = timeTag;
            timeLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            
            [cell.contentView addSubview:timeLabel];
        }
        //获得行数
        
        //取得相应行数的数据
        NSDictionary *dict = self.result[indexPath.row];
        
        //设置内容
        UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:contentTag];
        NSString *content = [dict objectForKey:@"content"];
        contentLabel.text = content;
        //设置联系方式
        UILabel *contactLabel = (UILabel *)[cell.contentView viewWithTag:contactTag];
        NSString *contact = [dict objectForKey:@"contact"];
        contactLabel.text = contact;
        
        //设置时间
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:timeTag];
        NSString *time = [dict objectForKey:@"createtime"];
        NSLog(@"获取到的string类型的时间：%@",time);
        //NSString转NSDate
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *date=[formatter dateFromString:time];
        NSLog(@"date111 %@",date);
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init] ;
        [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateStr = [formatter1 stringFromDate:date];
        NSLog(@"date222 %@",dateStr);
        timeLabel.text = dateStr;
        
        return cell;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

//修改行高度的位置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

-(void)getAllRecord:(NSString *)username andType:(NSString *)type{
    @try {
        NSString *name = [@"username=" stringByAppendingString:username];
        NSString *recordType = [@"type=" stringByAppendingString:type];
        NSString *str1 = [name stringByAppendingString:@"&"];
        NSString *str2 = [str1 stringByAppendingString:recordType];
        NSString *str3 = [@"http://182.61.134.30/feedback/select?" stringByAppendingString:str2];
        NSString *urlString = [str3 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL*url=[NSURL URLWithString:urlString];
        
        //2.创建请求对象
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        //3.获得会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        
        //4.创建一个组
        dispatch_group_t group = dispatch_group_create();
        //4.1 将请求加入组中
        dispatch_group_enter(group);
        //4.2 根据会话对象创建一个Task(发送请求）
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if([data length] == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.unserver preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:true completion:nil];
                    
                });
            }
            
            if (error == nil) {
                //6.解析服务器返回的数据
                self.result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"解析到的数据为：%@",self.result);
            }
            //4.3 离开这个组
            dispatch_group_leave(group);
        }];
        
        //7.执行任务
        [dataTask resume];
        dispatch_group_notify(group, dispatch_get_main_queue(),^{
            if([self.result isKindOfClass:[NSDictionary class]]){
                NSLog(@"为空");
                self.result = nil;
            }
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

-(void)deleteRecord:(NSString *)row{
    @try {
        //1.创建会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        //创建一个组
        dispatch_group_t group = dispatch_group_create();
        //将请求加入组中
        dispatch_group_enter(group);
        //2.根据会话对象创建task
        NSURL *url = [NSURL URLWithString:@"http://182.61.134.30:80/feedback/delete"];
        
        //3.创建可变的请求对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        //4.修改请求方法为POST
        request.HTTPMethod = @"POST";
        
        //5.设置请求体
        NSString *str = [@"id=" stringByAppendingString:row];
        request.HTTPBody = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        //6.根据会话对象创建一个Task(发送请求）
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if([data length]==0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.unserver preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:true completion:nil];
                    
                });
                
            }else{
                //7.解析数据
                self.dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"dict:%@",self.dict);
             
                
            }
            //离开这个组
            dispatch_group_leave(group);
        }];
        
        //8.执行任务
        [dataTask resume];
        dispatch_group_notify(group, dispatch_get_main_queue(),^{
            NSString *result = [self.dict objectForKey:@"success"];
            NSLog(@"结果为:%@",result);
            if([result isEqual:@"true"]){
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                if([userDefaults objectForKey:@"username"] && [userDefaults objectForKey:@"type"]){
                    NSString *username = [userDefaults objectForKey:@"username"] ;
                    NSString *type = [userDefaults objectForKey:@"type"] ;
                    
                    [self getAllRecord:username andType:type];
                }
            }
        });
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
@end
