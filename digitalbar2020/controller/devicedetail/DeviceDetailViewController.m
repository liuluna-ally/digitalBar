//
//  DeviceDetailViewController.m
//  digitalbar2020
//  设备详情界面
//  Created by user on 2020/11/13.
//

#import "DeviceDetailViewController.h"
#import <Foundation/Foundation.h>
#import "FunctionListViewController.h"
#import "ExceptionDetailViewController.h"

@interface DeviceDetailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property NSDictionary *dictStatus; //解析的结果 硬件状态
@property NSDictionary *dictConfig;//解析结果 配置
@property NSMutableArray *result;
@property NSString *configurationDetail;
@property NSString *hardwareStatus;
@property NSString *unreachNetwork;
@property NSString *unserver;
@property NSString *tips;
@property NSString *determine;
@property UIView *configView;
@property NSString *number;
@property (nonatomic,assign) NSInteger refreshTag;
@end

@implementation DeviceDetailViewController

- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        self.unreachNetwork = NSLocalizedString(@"unreachNetwork", nil);
        self.unserver = NSLocalizedString(@"unserver", nil);
        self.tips = NSLocalizedString(@"Tips", nil);
        self.determine = NSLocalizedString(@"determine", nil);
        self.configurationDetail = NSLocalizedString(@"configurationDetails", nil);
        self.hardwareStatus = NSLocalizedString(@"hardwareStatus", nil);
        //1.创建navbar
        UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
        nav.barTintColor = [UIColor whiteColor];
        //获取设备类型
        NSUserDefaults *de_type = [NSUserDefaults standardUserDefaults];
        if([de_type objectForKey:@"type"]){
            NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"type"];
            //设置头部内容
            //创建navbaritem
            UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:type];
            [nav pushNavigationItem:navTitle animated:YES];
            [self.view addSubview:nav];
            //创建barbutton 创建系统样式的
            UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
            //设置barbutton
            navTitle.leftBarButtonItem = item;
            [nav setItems:[NSArray arrayWithObject:navTitle]];
        }
        //2.准备数据
        if([de_type objectForKey:@"number"]){
            self.number = [[NSUserDefaults standardUserDefaults] objectForKey:@"number"];
            [self getDeviceDetail:_number];
        }
        //3.下拉刷新
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor grayColor];
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
        [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
        self.scrollView.refreshControl = refreshControl;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

/**
 返回按钮按下
 */
- (void)navBackBt:(UIButton *)sender{
    //跳转到下一页面
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FunctionListViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"functionlist"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

//加载数据
-(void)loadData{
    NSLog(@"手动刷新了");
    [self getDeviceDetail:_number];
    //停止刷新
    if ([self.scrollView.refreshControl isRefreshing]) {
        [self.scrollView.refreshControl endRefreshing];
    }
}



#pragma mark - 获取设备详情
//获取设备详情
-(void)getDeviceDetail:(NSString *)number{
    @try {
        //1.确定请求路径
        NSString *str = [@"no=" stringByAppendingString:number];
        NSString *str1 = [str stringByAppendingString:@"&"];
        NSString *str2 = [str1 stringByAppendingString:@"type=JSON"];
        NSString *str3 = [@"http://182.61.134.30/device/details?" stringByAppendingString:str2];
        
        NSString *urlString = [str3 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSLog(@"urlString:%@",urlString);
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
            NSString *config;
            NSString *status;
            NSDictionary *dict = self.result[0];
            config = [dict objectForKey:@"config"];
            status = [dict objectForKey:@"status"];
            NSLog(@"config:%@",config);
            NSData *jsonData = [config dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            self.dictConfig = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:NSJSONReadingMutableContainers
                                                                error:&err];
            NSLog(@"dictConfig:%@",self.dictConfig);
            
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                //3.设置控件
                NSArray *names = [self.dictConfig allKeys];
                NSArray *counts = [self.dictConfig allValues];
                for(int i = 0;i<[self.dictConfig count] + 1;i++){
                    self.configView = [[UIView  alloc]init];
                    CGFloat marginTop = 70;
                    CGFloat configW = self.scrollView.frame.size.width;
                    CGFloat configH = 40;
                    CGFloat configX = 0;
                    self.configView.frame = CGRectMake(configX, marginTop + (configH+20)*i, configW, configH);
                    [self.scrollView addSubview:self.configView];
                    if(i == 0){
                        //设置控件
                        UILabel *lableName = [[UILabel alloc]init];
                        CGFloat nameX = 20;
                        CGFloat nameY = 0;
                        CGFloat nameH = configH;
                        CGFloat nameW = configW;
                        lableName.frame = CGRectMake(nameX, nameY, nameW, nameH);
                        lableName.text = self.configurationDetail;
                        lableName.textColor = [UIColor blueColor];
                        [self.configView addSubview:lableName];
                    }else{
                        //设置控件 左侧
                        UILabel *lableName = [[UILabel alloc]init];
                        CGFloat nameX = 20;
                        CGFloat nameY = 0;
                        CGFloat nameH = configH;
                        CGFloat nameW = 120;
                        lableName.frame = CGRectMake(nameX, nameY, nameW, nameH);
                        lableName.text = names[i-1];
                        [self.configView addSubview:lableName];
                        
                        //设置控件 右侧
                        UILabel *lableCount = [[UILabel alloc]init];
                        CGFloat countX = self.configView.frame.size.width -140;
                        CGFloat countY = 0;
                        CGFloat countH = configH;
                        CGFloat countW = 120;
                        lableCount.frame = CGRectMake(countX, countY, countW, countH);
                        lableCount.text = [NSString stringWithFormat:@"%@",counts[i-1]];
                        lableCount.textAlignment = NSTextAlignmentCenter;
                        [self.configView addSubview:lableCount];
                    }
                    
                }
            });
            
            
            NSData *jsonStatus = [status dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            self.dictStatus= [NSJSONSerialization JSONObjectWithData:jsonStatus
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
            NSLog(@"dictStatus:%ld",[self->_dictStatus count]);
            
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //3.设置控件
                NSArray *names = [self.dictStatus allKeys];
                NSArray *status = [self.dictStatus allValues];
                UIView *statusViews = nil;
                for(int i = 0;i<[self.dictStatus count] + 1;i++){
                    statusViews = [[UIView  alloc]init];
                    CGFloat marginTop = CGRectGetMaxY(self.configView.frame)+20;
                    CGFloat configW = self.scrollView.frame.size.width;
                    CGFloat configH = 40;
                    CGFloat configX = 0;
                    statusViews.frame = CGRectMake(configX, marginTop + (configH+20)*i, configW, configH);
                    [self.scrollView addSubview:statusViews];
                    if(i == 0){
                        //设置控件
                        UILabel *lableName = [[UILabel alloc]init];
                        CGFloat nameX = 20;
                        CGFloat nameY = 0;
                        CGFloat nameH = configH;
                        CGFloat nameW = configW;
                        lableName.frame = CGRectMake(nameX, nameY, nameW, nameH);
                        lableName.text = self.hardwareStatus;
                        lableName.textColor = [UIColor blueColor];
                        [statusViews addSubview:lableName];
                    }else{
                        //设置控件 左侧
                        UILabel *lableName = [[UILabel alloc]init];
                        CGFloat nameX = 20;
                        CGFloat nameY = 0;
                        CGFloat nameH = configH;
                        CGFloat nameW = 120;
                        lableName.frame = CGRectMake(nameX, nameY, nameW, nameH);
                        lableName.text = names[i-1];
                        [statusViews addSubview:lableName];
                        
                        //设置控件 右侧
                        UIButton *btnCount = [[UIButton alloc]init];
                        CGFloat countX = statusViews.frame.size.width -140;
                        CGFloat countY = 0;
                        CGFloat countH = configH;
                        CGFloat countW = 120;
                        btnCount.frame = CGRectMake(countX, countY, countW, countH);
                        [btnCount setTitle:[NSString stringWithFormat:@"%@",status[i-1]] forState:UIControlStateNormal];
                        btnCount.titleLabel.textAlignment = NSTextAlignmentCenter;
                        if([[NSString stringWithFormat:@"%@",status[i-1]] isEqual:@"NG"]){
                            [btnCount setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                        }else{
                            [btnCount setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
                        }
                        //设置点击事件
                        btnCount.tag = i-1;
                        [btnCount addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
                        [statusViews addSubview:btnCount];
                        
                    }
                }
                //设置scrollview的内容大小
                
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, (statusViews.frame.size.height) * ([self.dictConfig count]+5)+ (self.configView.frame.size.height)* ([self->_dictStatus count]+5));
                
            });
        });
    } @catch (NSException *exception){
        NSLog(@"%@",exception);
    }
}

/**
 点击事件
 */
-(void)click:(UIButton *)btn{
    @try {
        NSLog(@"点击了  %ld",btn.tag);
        NSString *msg = [btn currentTitle];
        NSLog(@"msg  %@",msg);
        if([msg isEqual:@"NG"]){
            //进入下一页面
            UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ExceptionDetailViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"exceptiondetail"];
            viewController.modalPresentationStyle = 0;
            [self presentViewController:viewController animated:YES completion:nil];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
@end
