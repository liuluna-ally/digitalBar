//
//  ConfigurationDetailViewController.m
//  digitalbar2020
//  配置详情
//  Created by user on 2020/11/16.
//

#import "ConfigurationDetailViewController.h"
#import "DeviceListViewController.h"

@interface ConfigurationDetailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property NSString *unreachNetwork;
@property NSString *unserver;
@property NSString *tips;
@property NSString *determine;
@property NSMutableArray *result; //解析的结果
@property NSDictionary *dictConfig;//解析结果 配置
@property UIView *configViews;
@property NSString *number;


@end

@implementation ConfigurationDetailViewController

- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        self.unreachNetwork = NSLocalizedString(@"unreachNetwork", nil);
        self.unserver = NSLocalizedString(@"unserver", nil);
        self.tips = NSLocalizedString(@"Tips", nil);
        self.determine = NSLocalizedString(@"determine", nil);
        //1.获取数据
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"type"]){
            NSString *type = [defaults objectForKey:@"type"];
            UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
            nav.barTintColor = [UIColor whiteColor];
            //2.创建navbaritem
            UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:type];
            [nav pushNavigationItem:navTitle animated:YES];
            [self.view addSubview:nav];
            //创建barbutton 创建系统样式的
            UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
            //设置barbutton
            navTitle.leftBarButtonItem = item;
            [nav setItems:[NSArray arrayWithObject:navTitle]];
        }
        
        if([defaults objectForKey:@"number"]){
            self.number = [defaults objectForKey:@"number"];
            [self getConfiguration:_number];
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
    DeviceListViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"devicelist"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

//加载数据
-(void)loadData{
    NSLog(@"手动刷新了");
    [self getConfiguration:_number];
    //停止刷新
    if ([self.scrollView.refreshControl isRefreshing]) {
        [self.scrollView.refreshControl endRefreshing];
    }
}

/**
 从服务器获取信息
 */
-(void)getConfiguration:(NSString *)number{
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
            //for(int i = 0; i<[self.result count];i++){
            NSDictionary *dict = self.result[0];
            config = [dict objectForKey:@"config"];
            NSData *jsonData = [config dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            self.dictConfig = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:NSJSONReadingMutableContainers
                                                                error:&err];
            NSLog(@"config1111 %@",self.dictConfig);
            
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置控件
                NSArray *names = [self.dictConfig allKeys];
                NSArray *counts = [self.dictConfig allValues];
                for(int i = 0;i<[self.dictConfig count];i++){
                    self.configViews = [[UIView  alloc]init];
                    CGFloat marginTop = 70;
                    CGFloat configW = self.view.frame.size.width;
                    CGFloat configH = 40;
                    CGFloat configX = 0;
                    self.configViews.frame = CGRectMake(configX, marginTop + (configH+20)*i, configW, configH);
                    [self.scrollView addSubview:self.configViews];
                    //设置控件 左侧
                    UILabel *lableName = [[UILabel alloc]init];
                    CGFloat nameX = 20;
                    CGFloat nameY = 0;
                    CGFloat nameH = configH;
                    CGFloat nameW = 120;
                    lableName.frame = CGRectMake(nameX, nameY, nameW, nameH);
                    lableName.text = names[i];
                    [self.configViews addSubview:lableName];
                    
                    //设置控件 右侧
                    UILabel *lableCount = [[UILabel alloc]init];
                    CGFloat countX = self.configViews.frame.size.width -140;
                    CGFloat countY = 0;
                    CGFloat countH = configH;
                    CGFloat countW = 120;
                    lableCount.frame = CGRectMake(countX, countY, countW, countH);
                    lableCount.text = [NSString stringWithFormat:@"%@",counts[i]];
                    lableCount.textAlignment = NSTextAlignmentCenter;
                    [self.configViews addSubview:lableCount];
                }
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,  (self.configViews.frame.size.height)* ([self->_dictConfig count]+5));
            });
        });
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

@end
