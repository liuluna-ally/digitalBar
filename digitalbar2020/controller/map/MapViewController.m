////
////  MapViewController.m
////  digitalbar2020
////  地图定位
////  Created by diam on 2020/12/30.
////
//
#import "MapViewController.h"
#import "Reachability.h"
#import "DeviceListViewController.h"
#import "SelectMenuViewController.h"

@interface MapViewController() <CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
//获取用户当前的位置信息
@property (nonatomic) CLLocationManager *locationManager;
//网络不可用
@property NSString *unreachNetwork;
//服务器不可用
@property NSString *unserver;
//提示
@property NSString *tips;
//确定
@property NSString *determine;
//查看详情
@property NSString *viewDetails;
//查找店铺
@property NSString *storeFind;
//请求服务器的返回结果
@property NSMutableArray *results;
@property (strong, nonatomic) UIColor *highlightColor;
//总的搜索结果
@property NSMutableArray *searchResults;
//店名 分店名组合结果
@property NSMutableArray *results1;
@property UITableView *tableView;
@property UISearchBar *searchBar;
@property NSString *mapSearch;
@end

@implementation MapViewController
#pragma mark - 初始化
- (void)viewDidLoad{
    @try {
        [super viewDidLoad];
        //根据本地语言转化
        _unreachNetwork = NSLocalizedString(@"unreachNetwork", nil);
        _unserver = NSLocalizedString(@"unserver", nil);
        _tips = NSLocalizedString(@"Tips", nil);
        _determine = NSLocalizedString(@"determine", nil);
        _viewDetails = NSLocalizedString(@"viewDetails", nil);
        _storeFind = NSLocalizedString(@"storeFind", nil);
        _mapSearch = NSLocalizedString(@"mapSearch", nil);
        //设置代理
        self.mapView.delegate = self;
        
        //设置地图样式
        [self.mapView setMapType:MKMapTypeStandard];
        //是否显示GPS定位（小蓝点)
        [self.mapView setShowsUserLocation:NO];
        
        //初始化位置服务
        _locationManager = [[CLLocationManager alloc] init];
        //设置精度
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        //设置代理
        self.locationManager.delegate = self;
        //开启定位服务
        [self.locationManager startUpdatingLocation];
        
        //检测网络状况
        Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        reach.reachableBlock = ^(Reachability*reach)
        {
            //请求服务器，获取所有店铺的位置信息
            [self loadAllStoreLocation];
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
        //创建navbar
        UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
        nav.barTintColor = [UIColor whiteColor];    
        //创建navbaritem
        UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:_mapSearch];
        [nav pushNavigationItem:navTitle animated:YES];
        [self.view addSubview:nav];
        //创建barbutton 创建系统样式的
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
        //设置barbutton
        navTitle.leftBarButtonItem = item;
        [nav setItems:[NSArray arrayWithObject:navTitle]];
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,60,self.view.frame.size.width,50)];
        self.searchBar.placeholder = self.storeFind;
        [self.view addSubview:self.searchBar];
        self.searchBar.delegate = self;
        //创建tableview
        self.tableView = [[UITableView alloc]init];
        [self.view addSubview: self.tableView];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
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
    

#pragma mark-CLLocationManagerDelegate
/**
 开始定位
 */
-(void)startLocation{
    self.locationManager.distanceFilter = 100.0f;
    if ([[[UIDevice currentDevice]systemVersion]doubleValue] >8.0){
        [self.locationManager requestWhenInUseAuthorization];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        _locationManager.allowsBackgroundLocationUpdates =YES;
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
}
/**
 更新位置 获取到新的位置信息时调用 代理方法
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *newLocation = locations[0];
    //获得经纬度
    CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
    NSLog(@"旧的经度：%f,旧的纬度：%f",oldCoordinate.longitude,oldCoordinate.latitude);
    //显示范围，数值越大，范围就越大（后面数字越小 比例约小 可以无限接近0）
    MKCoordinateSpan span = {0.1,0.1};
    MKCoordinateRegion region = {oldCoordinate,span};
    //是否允许缩放，一般都会让缩放的
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    //地图初始化时显示的区域
    [self.mapView setRegion:region];
    // 自己位置显示在地图中间
    [self.mapView setCenterCoordinate:oldCoordinate animated:YES];
    //停止定位
    [manager stopUpdatingLocation];
    //位置的反编码
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> *_Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark *place in placemarks) {
            //            NSLog(@"name,%@",place.name);                      // 位置名
            //            NSLog(@"thoroughfare,%@",place.thoroughfare);      // 街道
            //            NSLog(@"subThoroughfare,%@",place.subThoroughfare);// 子街道
            //            NSLog(@"locality,%@",place.locality);              // 市
            //            NSLog(@"subLocality,%@",place.subLocality); //区
            //            NSLog(@"country,%@",place.country);                // 国家
        }
    }];
}

#pragma mark - 从服务器获取所有店铺的位置信息
-(void)loadAllStoreLocation{
    @try {
        //1.确定请求路径
        NSString *str = @"http://182.61.134.30/map/location/";
        
        NSString *urlString = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
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
                self.results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"解析到的数据为：%@",self.results);
                
            }
            //4.3 离开这个组
            dispatch_group_leave(group);
        }];
        
        //7.执行任务
        [dataTask resume];
        dispatch_group_notify(group, dispatch_get_main_queue(),^{
            //创建对象
            MKPointAnnotation *annotation = nil;
            CLLocationCoordinate2D location1;
            //遍历数组
            for(int i = 0;i<[self.results count];i++){
                NSDictionary * dict = self.results[i];
                annotation = [[MKPointAnnotation alloc] init];
                NSString *address = [dict valueForKey:@"address"];
                NSString *shopname = [dict valueForKey:@"shopname"];
                NSString *location = [dict valueForKey:@"location"];
                NSString *branchname = [dict valueForKey:@"branchname"];
                NSArray  *array = [location componentsSeparatedByString:@","];
                NSLog(@"address  %@,shopname %@,location %@ ,branchname %@",address,shopname,location,branchname);
                NSLog(@"array  %@",array[0]);
                location1 = CLLocationCoordinate2DMake([array[1] doubleValue], [array[0] doubleValue]);
                //设置数据
                annotation.coordinate = location1;
                annotation.title = address;
                NSString *name = [shopname stringByAppendingString:branchname];
                annotation.subtitle = name;
                //在地图上添加标记
                [self.mapView addAnnotation:annotation];
            }
        });
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
}

#pragma mark - 大头针视图的代理方法
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView *customPinView = (MKPinAnnotationView*)[mapView
                                                                    dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!customPinView){
            customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                            reuseIdentifier:@"CustomPinAnnotationView"];
        }
        //iOS9中用pinTintColor代替了pinColor
        customPinView.pinColor = MKPinAnnotationColorPurple;
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
        rightButton.backgroundColor = [UIColor grayColor];
        [rightButton setTitle:_viewDetails forState:UIControlStateNormal];
        customPinView.rightCalloutAccessoryView = rightButton;
        
        // 设置弹出起泡的左面图片
        UIImageView *myCustomImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_450_one"]];
        customPinView.leftCalloutAccessoryView = myCustomImage;
        return customPinView;
    }
    return nil;//返回nil代表使用默认样式
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    //获取店铺名称和位置
    NSString *shopname = view.annotation.subtitle;
//    CLLocationCoordinate2D location = view.annotation.coordinate;
//    NSString *tmpLat = [[NSString alloc] initWithFormat:@"%g", location.latitude];
//    NSString *tmpLong = [[NSString alloc] initWithFormat:@"%g", location.longitude];
//    NSLog(@"latitude is: %@", tmpLat);
//    NSLog(@"longitude is: %@", tmpLong);
//    NSString *str1 = [tmpLong stringByAppendingString:@","];
//    NSString *location1 = [str1 stringByAppendingString:tmpLat];
//    NSLog(@"location1 %@",location1);
    NSLog(@"shopname %@",shopname);
    //存储店铺名称和位置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:shopname forKey:@"shopname"];
//    [defaults setObject:location1 forKey:@"location"];
    [defaults synchronize];
    //进入下一页面
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DeviceListViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"devicelist"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

// MARK: - 设置数据源
//修改行高度的位置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        return self.results1.count;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    @try {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        if (!cell) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 0;
        }
        
        // 由于富文本会覆盖label原本的textColor，所以每次都要重新设置字体颜色
        cell.textLabel.text = self.results1[indexPath.row];
        return cell;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        //保存当前位置信息
        NSString *location = [self.searchResults[indexPath.row] objectForKey:@"location"];
        NSArray  *array = [location componentsSeparatedByString:@","];
        //定位到搜索的位置
        CLLocationCoordinate2D center = {[array[1] doubleValue],[array[0] doubleValue]};
      
        MKCoordinateSpan span;
        span.latitudeDelta = 0.1;
        span.longitudeDelta = 0.1;
        MKCoordinateRegion region = {center,span};
        
        [self.mapView setRegion:region animated:YES];
        self.tableView.frame = CGRectMake(60,80,self.view.frame.size.width-60,0);
        [self.searchBar endEditing:YES];

    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

// MARK: - UISearchBarDelegate

//监听输入框输入
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    @try {
        if (searchText.length) {
            //1.移除列表
            [self.results1 removeAllObjects];
            
            //2.检测网络状态
            Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
            reach.reachableBlock = ^(Reachability*reach)
            {
                //3.请求服务器，实现自动匹配功能
                [self selectResult:searchText];
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
        }
    } @catch (NSException *exception) {
        NSLog(@"搜索异常：%@",exception);
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    @try {
        [searchBar endEditing:YES];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

// MARK: - 设置搜索结果
- (void)selectResult:(NSString *)searchText {
    @try {
        //根据输入框内容，搜索匹配到的内容
        
        //1.确定请求路径
        NSString *keyword = [@"keyword=" stringByAppendingString:searchText];
        NSString *str1 = [keyword stringByAppendingString:@"&"];
        NSString *str2 = [str1 stringByAppendingString:@"type=JSON"];
        NSString *str3 = [@"http://182.61.134.30/map/search?" stringByAppendingString:str2];
        
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
        //4.2.根据会话对象创建一个Task(发送请求）
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if([data length] == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.unserver preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:true completion:nil];
                    
                });
            }
            
            if (error == nil) {
                //5.解析服务器返回的数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    self.searchResults = array;
                    NSLog(@"解析到的数据为searchResults：%@",self.searchResults);
                    
                });
            }
            //4.3 离开这个组
            dispatch_group_leave(group);
        }];
        
        //7.执行任务
        [dataTask resume];
        dispatch_group_notify(group, dispatch_get_main_queue(),^{
            self.results1 = [[NSMutableArray alloc]init];
            for(int i = 0; i<[self.searchResults count];i++){
                NSDictionary *dict = self.searchResults[i];
                NSString *shopname = [dict objectForKey:@"shopname"];
                NSString *branchname = [dict objectForKey:@"branchname"];
                NSString *text = [shopname stringByAppendingString:branchname];
                NSString *addressCategory = [dict objectForKey:@"category"];
                [self.results1 addObject:text];
            }
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableView.frame = CGRectMake(0,110,self.view.frame.size.width,[self.results1 count]*40);
                self.tableView.backgroundColor = [UIColor grayColor];
                [self.tableView reloadData];
            });
        });
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}



@end

