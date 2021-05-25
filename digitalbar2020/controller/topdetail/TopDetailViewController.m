//
//  TopDetailViewController.m
//  digitalbar2020
//  top 详情界面
//  Created by user on 2020/11/18.
//

#import "TopDetailViewController.h"
#import "FunctionListViewController.h"
@interface TopDetailViewController ()
@property NSMutableArray *result;
@property NSString *unreachNetwork;
@property NSString *unserver;
@property NSString *tips;
@property NSString *determine;
@property NSString *number;
@property NSTimer *timer;// 定时器
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation TopDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.unreachNetwork = NSLocalizedString(@"unreachNetwork", nil);
    self.unserver = NSLocalizedString(@"unserver", nil);
    self.tips = NSLocalizedString(@"Tips", nil);
    self.determine = NSLocalizedString(@"determine", nil);
    
    //获取设备类型 设备编号
    NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
    if([device objectForKey:@"type"]){
        NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"type"];
        //创建navbar
        UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
        nav.barTintColor = [UIColor whiteColor];        //创建navbaritem
        UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:type];
        
        [nav pushNavigationItem:navTitle animated:YES];
        [self.view addSubview:nav];
        //创建barbutton 创建系统样式的
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
        //设置barbutton
        navTitle.leftBarButtonItem = item;
        [nav setItems:[NSArray arrayWithObject:navTitle]];
    }
    if([device objectForKey:@"number"]){
        _number = [[NSUserDefaults standardUserDefaults] objectForKey:@"number"];
        [self getTopDetail:_number];
    }
    //任务定时执行
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(action) userInfo:nil repeats:YES];
    //3.下拉刷新
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    self.scrollView.refreshControl = refreshControl;
}

// 返回按钮按下
- (void)navBackBt:(UIButton *)sender{
    //关闭定时器
    [self.timer setFireDate:[NSDate distantFuture]];
    //跳转到下一页面
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FunctionListViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"functionlist"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

//定时执行
-(void)action{
    [self getTopDetail:_number];
}

//加载数据
-(void)loadData{
    NSLog(@"手动刷新了");
    [self getTopDetail:_number];
    //停止刷新
    if ([self.scrollView.refreshControl isRefreshing]) {
        [self.scrollView.refreshControl endRefreshing];
    }
}

#pragma -mark -柱状图初始化
- (void)initZhuView:(NSMutableArray*)name :(NSMutableArray *)values
{
    
   
    NSMutableArray *arrayName = [[NSMutableArray alloc]init];
    [arrayName addObjectsFromArray:name];
    CGFloat width = self.scrollView.frame.size.width-50;
    CGFloat height = 40;
    CGFloat marginTop = 30;
    CGFloat marginX = 30;
   
    //获取计数最大值
    CGFloat maxValue = [[values valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat countW = 0;
    //创建view
    for(int i = 0; i<[arrayName count];i++){
        zhuView = [[UIView alloc] initWithFrame:CGRectMake(marginX, marginTop + (height + marginX)*i, width, height)];
        //添加view
        [self.scrollView addSubview:zhuView];
        //设置控件 左侧
        UILabel *lableName = [[UILabel alloc]init];
        CGFloat nameX = 0;
        CGFloat nameY = 0;
        CGFloat nameH = height;
        CGFloat nameW = 200;
        lableName.frame = CGRectMake(nameX, nameY, nameW, nameH);
        lableName.text = [arrayName objectAtIndex:i];
        lableName.font = [UIFont fontWithName:nil size:12];
        [zhuView addSubview:lableName];
        
        //设置控件 右侧
        UILabel *lableCount = [[UILabel alloc]init];
        CGFloat countX = nameW+10;
        CGFloat countH = 20;
        CGFloat countY = (height-countH)/2;
        if(maxValue != 0){
            countW = [values[i] floatValue]*(zhuView.frame.size.width-nameW-10)/maxValue;
        }
        lableCount.frame = CGRectMake(countX, countY, countW, countH);
        lableCount.backgroundColor = [UIColor orangeColor];
        [zhuView addSubview:lableCount];
        
        //柱状图上的红色的数字Label
        UILabel* numberLB = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(lableCount.frame)+15, 0, 50, 10)];
        [numberLB setFont:[UIFont systemFontOfSize:10]];
        [numberLB setText:values[i]];
        [zhuView addSubview:numberLB];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, zhuView.frame.size.height);
}

#pragma -mark -获取数据
-(void)getTopDetail:(NSString *)number{
    @try {
        NSLog(@"执行了");
        //1.确定请求路径
        NSString *str = [@"no=" stringByAppendingString:number];
        NSString *str1 = [@"http://182.61.134.30/count/details?" stringByAppendingString:str];
        
        NSString *urlString = [str1 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
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
            NSMutableArray *names = [[NSMutableArray alloc]init];
            NSMutableArray *texts = [[NSMutableArray alloc]init];
            if([self.result isKindOfClass:[NSDictionary class]]){
                NSLog(@"为空");
                self.result = nil;
            }else{
                NSDictionary *dict = self.result[0];
                NSLog(@"字典：%@",dict);
                NSString *str = [dict objectForKey:@"counts"];
                NSLog(@"str:%@",str);
                NSString *str1 = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
                NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSArray  *array = [str2 componentsSeparatedByString:@","];
                NSLog(@"array:%@",array);
                for(int i = 0;i < [array count];i++){
                    NSString *str3 = array[i];
                    NSString *str4 = [str3 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    NSArray *array = [str4 componentsSeparatedByString:@":"];
                    [names addObject:array[0]];
                    [texts addObject:array[1]];
                }
                [self initZhuView:names :texts];
            }
        });
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
@end
