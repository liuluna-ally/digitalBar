//
//  SearchViewController.m
//  digitalbar2020
//  搜索
//  Created by user on 2020/11/9.
//

#import "SearchViewController.h"
//#import "UILabel+SearchText.h"
#import "Reachability.h"
#import "DeviceListViewController.h"
#import "SelectMenuViewController.h"

@interface SearchViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIColor *highlightColor;
@property NSMutableArray *searchResults;//总的搜索结果
@property NSMutableArray *results; //店名 分店名组合结果
@property NSString *userCategory; //获取当前用户的category
//获取文本
@property NSString *storeFind;
@property NSString *unreachNetwork;
@property NSString *unserver;
@property NSString *tips;
@property NSString *determine;
@property NSString *search;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        _storeFind = NSLocalizedString(@"storeFind", nil);
        self.searchBar.placeholder = _storeFind;
        _unreachNetwork = NSLocalizedString(@"unreachNetwork", nil);
        _unserver = NSLocalizedString(@"unserver", nil);
        _tips = NSLocalizedString(@"Tips", nil);
        _determine = NSLocalizedString(@"determine", nil);
        _search = NSLocalizedString(@"search", nil);
        _searchBar.delegate = self;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset = UIEdgeInsetsZero;
        //创建navbar
        UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
        nav.barTintColor = [UIColor whiteColor];    
        //创建navbaritem
        UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:self.search];
        [nav pushNavigationItem:navTitle animated:YES];
        [self.view addSubview:nav];
        //创建barbutton 创建系统样式的
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
        //设置barbutton
        navTitle.leftBarButtonItem = item;
        [nav setItems:[NSArray arrayWithObject:navTitle]];
        //获取用户的category
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"category"]){
            self.userCategory = [[NSUserDefaults standardUserDefaults] objectForKey:@"category"];
        }
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

// MARK: - 设置数据源

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        return self.results.count;
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
        cell.textLabel.text = self.results[indexPath.row];
        return cell;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        //保存当前位置信息
        NSString *shopname = self.results[indexPath.row];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:shopname forKey:@"shopname"];
        [defaults synchronize];
        //跳转到下一页面
        UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DeviceListViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"devicelist"];
        viewController.modalPresentationStyle = 0;
        [self presentViewController:viewController animated:YES completion:nil];
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
            [self.results removeAllObjects];
            
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
            self.results = [[NSMutableArray alloc]init];
            for(int i = 0; i<[self.searchResults count];i++){
                NSDictionary *dict = self.searchResults[i];
                NSString *shopname = [dict objectForKey:@"shopname"];
                NSString *branchname = [dict objectForKey:@"branchname"];
                NSString *text = [shopname stringByAppendingString:branchname];
                NSString *addressCategory = [dict objectForKey:@"category"];
                if([self.userCategory isEqual:addressCategory]){
                    if ([text containsString:searchText]) {
                        [self.results addObject:text];
                    }
                }
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
@end
