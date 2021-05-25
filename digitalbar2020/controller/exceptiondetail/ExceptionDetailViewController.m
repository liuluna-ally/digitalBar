//
//  ExceptionDetailViewController.m
//  digitalbar2020
//  异常详情
//  Created by user on 2020/11/16.
//

#import "ExceptionDetailViewController.h"
#import "DeviceDetailViewController.h"

@interface ExceptionDetailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property NSString *unreachNetwork;
@property NSString *unserver;
@property NSString *tips;
@property NSString *determine;
@property NSMutableArray *result;
@property UIImageView *image;
@property NSString *exception;
@property NSString *exceptionCause;
@property NSString *solution;
@property UILabel *cause;
@property NSString *number;
@end

@implementation ExceptionDetailViewController

- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        self.unreachNetwork = NSLocalizedString(@"unreachNetwork", nil);
        self.unserver = NSLocalizedString(@"unserver", nil);
        self.tips = NSLocalizedString(@"Tips", nil);
        self.determine = NSLocalizedString(@"determine", nil);
        self.exception = NSLocalizedString(@"exception", nil);
        self.exceptionCause = NSLocalizedString(@"exceptionCause", nil);
        self.solution = NSLocalizedString(@"solution", nil);
        //1.获取设备类型
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //2.创建navbar
        UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
        nav.barTintColor = [UIColor whiteColor];    
        //创建navbaritem
        UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle: [defaults objectForKey:@"type"]];
        [nav pushNavigationItem:navTitle animated:YES];
        [self.scrollView addSubview:nav];
        //创建barbutton 创建系统样式的
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
        //设置barbutton
        navTitle.leftBarButtonItem = item;
        [nav setItems:[NSArray arrayWithObject:navTitle]];
        //3.获取异常详情
        if([defaults objectForKey:@"number"]){
            self.number = [defaults objectForKey:@"number"];
            [self getExceptionDetail:_number];
        }
        //4.创建控件
        //创建异常图片
        self.image = [[UIImageView alloc]init];
        self.image.frame = CGRectMake(30, 100, 48, 48);
        [self.scrollView addSubview:self.image];
        
        //创建异常
        UILabel *exception = [[UILabel alloc]init];
        CGFloat marginLeft = 30;
        CGFloat exceptionX = self.view.frame.size.width-CGRectGetMaxX(self.image.frame)-marginLeft-80;
        exception.frame = CGRectMake(exceptionX, 100, 120, 48);
        exception.text = self.exception;
        exception.textColor = [UIColor redColor];
        exception.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:exception];
        
        //创建异常原因
        self.cause = [[UILabel alloc]init];
        CGFloat reasonY = CGRectGetMaxY(self.image.frame)+ 60;
        self.cause.frame = CGRectMake(30, reasonY, 200, 48);
        self.cause.text = self.exceptionCause;
        [self.scrollView addSubview:self.cause];
        //5.下拉刷新
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor grayColor];
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
        [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
        self.scrollView.refreshControl = refreshControl;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

// 返回按钮按下
- (void)navBackBt:(UIButton *)sender{
    //跳转到下一页面
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DeviceDetailViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"devicedetail"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

//加载数据
-(void)loadData{
    NSLog(@"手动刷新了");
    [self getExceptionDetail:_number];
    //停止刷新
    if ([self.scrollView.refreshControl isRefreshing]) {
        [self.scrollView.refreshControl endRefreshing];
    }
}


-(void)getExceptionDetail:(NSString *)number{
    @try {
        //1.确定请求路径
        NSString *str = [@"no=" stringByAppendingString:number];
        NSString *str1 = [str stringByAppendingString:@"&"];
        NSString *str2 = [str1 stringByAppendingString:@"type=JSON"];
        NSString *str3 = [@"http://182.61.134.30/error/details?" stringByAppendingString:str2];
        
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
            if([self.result isKindOfClass:[NSDictionary class]]){
               NSLog(@"为空");
                self.result = nil;
            }else{
                NSDictionary *dict = self.result[0];
                if(![[dict objectForKey:@"reason"] isEqual:@"null"] && ![[dict objectForKey:@"solution"] isEqual:@"null"]){
                    NSString *reason = [dict objectForKey:@"reason"];
                    NSLog(@"reason :%@",reason );
                    NSData *jsonData = [reason dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *err;
                    NSArray *arrResaon = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&err];
                    NSLog(@"arrResaon :%@",arrResaon );
                    NSMutableArray *reasons = [[NSMutableArray alloc]init];
                    for(int i = 0; i<[arrResaon count];i++){
                        NSDictionary *dict = arrResaon[i];
                        NSString *strReason = [dict objectForKey:[NSString stringWithFormat:@"%d",(i+1)]];
                        [reasons addObject:strReason];
                    }
                    
                    //设置异常原因控件
                    CGFloat marginTop = 20;
                    CGFloat marginX = 50;
                    CGFloat padd = 10;
                    CGFloat reasonH = 20;
                    UILabel *reasonView = nil;
                    for(int i = 0;i < [reasons count];i++){
                        reasonView = [[UILabel alloc]init];
                        reasonView.frame = CGRectMake(marginX, CGRectGetMaxY(self.cause.frame)+marginTop+(reasonH + padd)*i, self.view.frame.size.width, reasonH);
                        NSString *text = [[NSString stringWithFormat:@"%d",(i+1)] stringByAppendingString:@". "];
                        NSString *text1 = [text stringByAppendingString:reasons[i]];
                        reasonView.text = text1;
                        [self.scrollView addSubview: reasonView];
                    }
                   
                    NSString *solution = [dict objectForKey:@"solution"];
                    NSLog(@"solution :%@",solution);
                    NSData *jsonData1 = [solution dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *err1;
                    NSArray *arrSolution = [NSJSONSerialization JSONObjectWithData:jsonData1
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&err1];
                    NSLog(@"arrSolution :%@",arrSolution );
                    NSMutableArray *solutions = [[NSMutableArray alloc]init];
                    for(int i = 0; i<[arrSolution count];i++){
                        NSDictionary *dict = arrSolution[i];
                        NSString *strSolution = [dict objectForKey:[NSString stringWithFormat:@"%d",(i+1)]];
                        [solutions addObject:strSolution];
                    }
                    
                    //设置异常原因控件
                    CGFloat solutionmarginTop = 0;
                    if(CGRectGetMaxY(reasonView.frame) == 0){
                        solutionmarginTop = CGRectGetMaxY(self.cause.frame)+20;
                    }else{
                        solutionmarginTop = CGRectGetMaxY(reasonView.frame)+20;
                    }
                    
                    //创建solution
                    UILabel *solutionLabel = [[UILabel alloc]init];
                    solutionLabel.frame = CGRectMake(30, solutionmarginTop, 200, 48);
                    solutionLabel.text = self.solution;
                    [self.scrollView addSubview:solutionLabel];
                    UILabel *solutionView = nil;
                    for(int i = 0;i < [solutions count];i++){
                        solutionView = [[UILabel alloc]init];
                        solutionView.frame = CGRectMake(marginX, CGRectGetMaxY(solutionLabel.frame)+marginTop+(reasonH + padd)*i, self.view.frame.size.width, reasonH);
                        NSString *text = [[NSString stringWithFormat:@"%d",(i+1)] stringByAppendingString:@". "];
                        NSString *text1 = [text stringByAppendingString:solutions[i]];
                        solutionView.text = text1;
                        [self.scrollView addSubview: solutionView];
                    }
                    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(solutionView.frame));
                    
                }
                
                NSString *type = [dict objectForKey:@"type"];
                if([type isEqual:@"Camera"]){
                    self.image.image = [UIImage imageNamed:@"camera"];
                }else if([type isEqual:@"AiStick"]){
                    self.image.image = [UIImage imageNamed:@"aistick"];
                }else if([type isEqual:@"4G"]){
                    self.image.image = [UIImage imageNamed:@"_4g"];
                }else if([type isEqual:@"Software"]){
                    self.image.image = [UIImage imageNamed:@"software"];
                }else if([type isEqual:@"RFID_3"]){
                    self.image.image = [UIImage imageNamed:@"rfid_3"];
                }else if([type isEqual:@"Weight_4"]){
                    self.image.image = [UIImage imageNamed:@"weight"];
                }else if([type isEqual:@"Infrared_1"]){
                    self.image.image = [UIImage imageNamed:@"infrared_1"];
                }else if([type isEqual:@"RFID_0"]){
                    self.image.image = [UIImage imageNamed:@"rfid_0"];
                }
            }
        });
           
    } @catch (NSException *exception){
        NSLog(@"%@",exception);
    }
}

@end
