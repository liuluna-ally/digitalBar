//
//  DeviceListViewController.m
//  digitalbar2020
//  设备列表页面
//  Created by user on 2020/11/11.
//

#import "DeviceListViewController.h"
#import "Reachability.h"
#import "FunctionListViewController.h"
#import "ConfigurationDetailViewController.h"
#import "SelectMenuViewController.h"

#pragma mark - DeviceListViewController
@interface DeviceListViewController () <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *lb_position;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *searchResults;
@property NSString *unreachNetwork;
@property NSString *unserver;
@property NSString *tips;
@property NSString *determine;
@property NSString *shopname;
@property NSString *deviceType;
@property NSString *deviceNumber;
@property NSString *deviceNo;
@property NSString *devicelist;
@end


@implementation DeviceListViewController

- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        _unreachNetwork = NSLocalizedString(@"unreachNetwork", nil);
        _unserver = NSLocalizedString(@"unserver", nil);
        _tips = NSLocalizedString(@"Tips", nil);
        _determine = NSLocalizedString(@"determine", nil);
        _deviceType = NSLocalizedString(@"deviceType", nil);
        _deviceNumber = NSLocalizedString(@"deviceNumber", nil);
        _devicelist = NSLocalizedString(@"devicelist", nil);
        
        //1.创建navbar
        UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
        nav.barTintColor = [UIColor whiteColor];    
        //创建navbaritem
        UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:self.devicelist];
        [nav pushNavigationItem:navTitle animated:YES];
        [self.view addSubview:nav];
        //创建barbutton 创建系统样式的
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
        //设置barbutton
        navTitle.leftBarButtonItem = item;
        [nav setItems:[NSArray arrayWithObject:navTitle]];
        //2.设置title
        //获取店名
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"shopname"]){
            _shopname = [[NSUserDefaults standardUserDefaults] objectForKey:@"shopname"];
            NSLog(@"1111 %@",_shopname);
              self.lb_position.text = _shopname;
        }
        //3.设置数据源
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset = UIEdgeInsetsZero;
        //4.检测网络
        Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        reach.reachableBlock = ^(Reachability*reach)
        {
            //2.1.请求服务器，实现获取设备列表功能
           [self getDeviceList:self.shopname];
            
        };
        
        reach.unreachableBlock = ^(Reachability*reach)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.unreachNetwork preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:true completion:nil];
            });
        };
        [reach startNotifier];
        //5.下拉刷新
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
    SelectMenuViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"selectmenu"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

//加载数据
-(void)loadData{
    NSLog(@"手动刷新了");
    [self getDeviceList:self.shopname];
    //停止刷新
    if ([self.tableView.refreshControl isRefreshing]) {
        [self.tableView.refreshControl endRefreshing];
    }
}
#pragma mark - 获取设备列表
//获取设备列表
-(void)getDeviceList:(NSString *) value{
    @try {
        //1.确定请求路径
        //根据位置查询设备列表
        NSURL *url = nil;
        NSString *str = [@"shopname=" stringByAppendingString:value];
        NSString *str1 = [str stringByAppendingString:@"&"];
        NSString *str2 = [str1 stringByAppendingString:@"type=JSON"];
        NSString *str3 = [@"http://182.61.134.30/device/shopname/list?" stringByAppendingString:str2];
        NSString *urlString = [str3 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSLog(@"urlString:%@",urlString);
        url = [NSURL URLWithString:urlString];
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
                self.searchResults = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"解析到的数据为：%@",self.searchResults);
                
            }
            //4.3 离开这个组
            dispatch_group_leave(group);
        }];
        
        //7.执行任务
        [dataTask resume];
        dispatch_group_notify(group, dispatch_get_main_queue(),^{
            if([self.searchResults isKindOfClass:[NSDictionary class]]){
                NSLog(@"为空");
                self.searchResults = nil;
            }
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                NSDictionary *dict = self.searchResults[0];
                NSString *shopname = [dict valueForKey:@"shopname"];
                self.lb_position.text = shopname;
            });
        });
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

#pragma mark -/*****************显示数据源方法****************************/
//默认显示1组数据
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//每组显示几行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    @try {
        return [self.searchResults count];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
}

//修改行高度的位置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}


//每一组的每一行中显示什么数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    @try {
        //indexPath.section  几组    indexPath.row 几行
        UITableViewCell *cell = [self customCellWithOutXib:tableView withIndexPath:indexPath];
        return cell;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
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
            //设备状态标志
            CGRect statusRect = CGRectMake(2, 20, 32, 32);
            UIImageView *statusImage = [[UIImageView alloc]initWithFrame:statusRect];
            statusImage.tag = statusTag;
            [cell.contentView addSubview:statusImage];
            
            //设备图片
            CGRect imageRect = CGRectMake(40, 10, 64, 64);
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageRect];
            imageView.tag = imageTag;
            
            //为图片添加边框
            CALayer *layer = [imageView layer];
            layer.cornerRadius = 8;
            layer.borderColor = [[UIColor whiteColor]CGColor];
            layer.borderWidth = 1;
            layer.masksToBounds = YES;
            [cell.contentView addSubview:imageView];
            
            //设备类型
            CGRect typeRect = CGRectMake(110, 15, 64, 24);
            UILabel *typeLabel = [[UILabel alloc]initWithFrame:typeRect];
            typeLabel.text = self.deviceType;
            typeLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            [cell.contentView addSubview:typeLabel];
            
            //设备类型数据
            CGRect deviceTypeRect = CGRectMake(190, 15, 120, 24);
            UILabel *deviceTypeLabel = [[UILabel alloc]initWithFrame:deviceTypeRect];
            deviceTypeLabel.tag = typeTag;
            deviceTypeLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            [cell.contentView addSubview:deviceTypeLabel];
            
            //设备编号
            CGRect numberRect = CGRectMake(110, 55, 64, 24);
            UILabel *numberLabel = [[UILabel alloc]initWithFrame:numberRect];
            numberLabel.text = self.deviceNumber;
            numberLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            [cell.contentView addSubview:numberLabel];
            
            //设备编号数据
            CGRect deviceNumberRect = CGRectMake(190, 55, 120, 24);
            UILabel *deviceNumberLabel = [[UILabel alloc]initWithFrame:deviceNumberRect];
            deviceNumberLabel.tag = numberTag;
            deviceNumberLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            
            [cell.contentView addSubview:deviceNumberLabel];
        }
        //获得行数
        
        //取得相应行数的数据（
        NSDictionary *dict = self.searchResults[indexPath.row];
        //设置状态标识
        UIImageView *statusV = (UIImageView *)[cell.contentView viewWithTag:statusTag];
        NSString *status = [dict objectForKey:@"STATUS"];
        NSString *details = [dict objectForKey:@"details"];
        if([status isEqual:@"NG"] && [details isEqual:@"4G"]){
            statusV.image = [UIImage imageNamed:@"error_4g"];
        }else if([status isEqual:@"NG"] && [details isEqual:@"AiStick"]){
            statusV.image = [UIImage imageNamed:@"error_aistick"];
        }else if([status isEqual:@"NG"] && [details isEqual:@"Camera"]){
            statusV.image = [UIImage imageNamed:@"error_camera"];
        }
        else if([status isEqual:@"NG"] && [details isEqual:@"Software"]){
            statusV.image = [UIImage imageNamed:@"error_software"];
        }else if([status isEqual:@"NG"] && [details isEqual:@"Infrared_1"]){
            statusV.image = [UIImage imageNamed:@"error_infrared_1"];
        }else if([status isEqual:@"NG"] && [details isEqual:@"RFID_0"]){
            statusV.image = [UIImage imageNamed:@"error_rfid_0"];
        }else if([status isEqual:@"NG"] && [details isEqual:@"RFID_3"]){
            statusV.image = [UIImage imageNamed:@"error_rfid_3"];
        }else if([status isEqual:@"NG"] && [details isEqual:@"Weight_4"]){
            statusV.image = [UIImage imageNamed:@"error_weight"];
        }
        else{
            statusV.image = [UIImage imageNamed:@"_true"];
        }
        
        //设置设备图片
        UIImageView *imageV = (UIImageView *)[cell.contentView viewWithTag:imageTag];
        NSString *image = [dict objectForKey:@"image"];
        imageV.image = [UIImage imageNamed:image];
        
        //设置设备类型
        UILabel *typeLabel = (UILabel *)[cell.contentView viewWithTag:typeTag];
        NSString *type = [dict objectForKey:@"type"];
        typeLabel.text = type;
        //设置设备编号
        UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:numberTag];
        NSString *no = [dict objectForKey:@"NO"];
        numberLabel.text = no;
        
        //设置右侧箭头
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

//点击一行执行的动作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        NSDictionary *dict = self.searchResults[indexPath.row];
        
        NSString *type = [dict objectForKey:@"type"];
        NSString *number = [dict objectForKey:@"NO"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:type forKey:@"type"];
        [defaults setObject:number forKey:@"number"];
        [defaults synchronize];
        
        NSString *status = [dict objectForKey:@"STATUS"];
        NSString *details = [dict objectForKey:@"details"];
        UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if([status isEqual:@"NG"] && [details isEqual:@"4G"]){
            UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ConfigurationDetailViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"configurationdetail"];
            viewController.modalPresentationStyle = 0;
            [self presentViewController:viewController animated:YES completion:nil];
        }else{
            UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FunctionListViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"functionlist"];
            viewController.modalPresentationStyle = 0;
            [self presentViewController:viewController animated:YES completion:nil];
        }
    } @catch (NSException *exception) {   
        NSLog(@"%@",exception);
    }
}

@end
