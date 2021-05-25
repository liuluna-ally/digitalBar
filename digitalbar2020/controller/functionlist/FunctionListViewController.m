//
//  FunctionListViewController.m
//  digitalbar2020
//  功能列表界面
//  Created by user on 2020/11/12.
//

#import "FunctionListViewController.h"
#import "DeviceDetailViewController.h"
#import "FeedBackViewController.h"
#import "TopDetailViewController.h"
#import "DeviceListViewController.h"

@interface FunctionListViewController ()

@property NSString *authority;

@property NSString *determine;
@property NSString *error;
@property NSString *tips;
@property NSString *unserver;
@property NSString *operationSuccess;
@property NSString *operationFailed;
@property NSString *deviceDetail;
@property NSString *topDetail;
@property NSString *feedback;
@property (nonatomic) NSString *shutdown;
@property NSString *restart;
@property NSString *clear;
@property NSMutableArray *functions;

@end

@implementation FunctionListViewController

- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        _tips = NSLocalizedString(@"Tips", nil);
        _determine = NSLocalizedString(@"determine", nil);
        _error = NSLocalizedString(@"usernameError", nil);
        _unserver = NSLocalizedString(@"unserver", nil);
        _operationSuccess = NSLocalizedString(@"operationSuccess", nil);
        _operationFailed = NSLocalizedString(@"operationFailed", nil);
        _deviceDetail = NSLocalizedString(@"deviceDetail", nil);
        _topDetail = NSLocalizedString(@"topDetail", nil);
        _feedback = NSLocalizedString(@"feedback", nil);
        _shutdown = NSLocalizedString(@"shutdown", nil);
        _restart = NSLocalizedString(@"restart", nil);
        _clear = NSLocalizedString(@"clear", nil);
        
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
        
        //2. 准备数据
        //数据
        _functions = [[NSMutableArray alloc]init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"image"] = @"device_detail";
        dict[@"name"] = self.deviceDetail;
        [_functions addObject:dict];

        NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]init];
        dict1[@"image"] = @"top_detail";
        dict1[@"name"] = self.topDetail;
        [_functions addObject:dict1];

        NSMutableDictionary *dict2 = [[NSMutableDictionary alloc]init];
        dict2[@"image"] = @"feedback";
        dict2[@"name"] = self.feedback;
        [_functions addObject:dict2];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"authority"]){
            self.authority = [[NSUserDefaults standardUserDefaults] objectForKey:@"authority"];
            if([self.authority isEqual:@"0"] || [self.authority isEqual:@"1"]){
                NSMutableDictionary *dict3 = [[NSMutableDictionary alloc]init];
                dict3[@"image"] = @"shutdown";
                dict3[@"name"] = self.shutdown;
                [_functions addObject:dict3];

                NSMutableDictionary *dict4 = [[NSMutableDictionary alloc]init];
                dict4[@"image"] = @"restart";
                dict4[@"name"] = self.restart;
                [_functions addObject:dict4];

                NSMutableDictionary *dict5 = [[NSMutableDictionary alloc]init];
                dict5[@"image"] = @"clear";
                dict5[@"name"] = self.clear;
                [_functions addObject:dict5];

            }else if([self.authority isEqual:@"2"]){
                NSMutableDictionary *dict3 = [[NSMutableDictionary alloc]init];
                dict3[@"image"] = @"shutdown";
                dict3[@"name"] = self.shutdown;
                [_functions addObject:dict3];

                NSMutableDictionary *dict4 = [[NSMutableDictionary alloc]init];
                dict4[@"image"] = @"restart";
                dict4[@"name"] = self.restart;
                [_functions addObject:dict4];
            }
        }
        
        //3.创建小uiview
        CGFloat screenW = self.view.frame.size.width;
        CGFloat functionW = 75;
        CGFloat functionH = 90;
        CGFloat marginTop = 80;
        int column = 3;
        CGFloat marginX = (screenW - functionW*column)/(column+1);
        CGFloat marginY = marginX;
        for(int i = 0; i < [_functions count]; i++){
            UIView *functionView = [[UIView alloc]init];
            functionView.frame = CGRectMake(marginX + (functionW+marginX)*(i%column), marginTop+(marginY+functionH)*(i/column), functionW, functionH);
            [self.view addSubview:functionView];
            //创建uibutton
            UIButton *button = [[UIButton alloc]init];
            CGFloat buttonW = 32;
            CGFloat buttonH = 32;
            button.frame = CGRectMake((functionView.frame.size.width-buttonW)*0.5, 0, buttonW, buttonH);
            NSDictionary *dict =  _functions[i];
            NSString *imageName = [dict valueForKey:@"image"];
            [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            //设置tag
            button.tag = i;
            //添加点击事件
            [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            [functionView addSubview:button];
            //创建lable
            UILabel *lable = [[UILabel alloc]init];
            CGFloat lableW = functionView.frame.size.width;
            CGFloat lableH = 20;
            CGFloat lableX = 0;
            CGFloat lableY = buttonH+10;
            NSString *name = [dict valueForKey:@"name"];
            lable.frame = CGRectMake(lableX, lableY, lableW, lableH);
            // 居中对齐
            lable.textAlignment = NSTextAlignmentCenter;
            lable.text = name;
            [functionView addSubview:lable];
        }
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

/**
 点击事件
 */
-(void)click:(UIButton *)btn{
    @try {
        NSLog(@"点击了  %ld",btn.tag);
        if(btn.tag == 0){
            UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DeviceDetailViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"devicedetail"];
            viewController.modalPresentationStyle = 0;
            [self presentViewController:viewController animated:YES completion:nil];
        }else if(btn.tag == 1){
            UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TopDetailViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"topdetail"];
            viewController.modalPresentationStyle = 0;
            [self presentViewController:viewController animated:YES completion:nil];
        }else if(btn.tag == 2){
            UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FeedBackViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"feedback"];
            viewController.modalPresentationStyle = 0;
            [self presentViewController:viewController animated:YES completion:nil];
        }else if(btn.tag == 3){
            [self shutdownDevice];
        }else if(btn.tag == 4){
            [self restartDevice];
        }else if(btn.tag == 5){
            [self clearData];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

- (void)clearData {
    @try {
        //1.创建会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        //2.根据会话对象创建task
        NSURL *url = [NSURL URLWithString:@"http://182.61.134.30:80/count/clear"];

        //3.创建可变的请求对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

        //4.修改请求方法为POST
        request.HTTPMethod = @"POST";

        //5.设置请求体
        NSString *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"number"];
        NSString *no = [@"no=" stringByAppendingString:number];
        request.HTTPBody = [no dataUsingEncoding:NSUTF8StringEncoding];

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
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"解析的数据为：%@",dict);
                NSString *result = [dict objectForKey:@"success"];
                NSLog(@"操作结果为:%@",result);
                if([result isEqual:@"true"]){
                    dispatch_async(dispatch_get_main_queue(), ^{

                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.operationSuccess preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:true completion:nil];

                    });

                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{

                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.operationFailed preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:true completion:nil];

                    });
                }
            }
        }];
        //8.执行
        [dataTask resume];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
- (void)shutdownDevice{
    @try {
        //1.创建会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        //2.根据会话对象创建task
        NSURL *url = [NSURL URLWithString:@"http://182.61.134.30:80/count/clear"];

        //3.创建可变的请求对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

        //4.修改请求方法为POST
        request.HTTPMethod = @"POST";

        //5.设置请求体
        NSString *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"number"];
        NSString *no = [@"no=" stringByAppendingString:number];
        request.HTTPBody = [no dataUsingEncoding:NSUTF8StringEncoding];

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
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"解析的数据为：%@",dict);
                NSString *result = [dict objectForKey:@"success"];
                NSLog(@"操作结果为:%@",result);
                if([result isEqual:@"true"]){
                    dispatch_async(dispatch_get_main_queue(), ^{

                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.operationSuccess preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:true completion:nil];

                    });

                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{

                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.operationFailed preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:true completion:nil];

                    });
                }
            }
        }];
        //8.执行
        [dataTask resume];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
- (void)restartDevice {
    @try {
        //1.创建会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        //2.根据会话对象创建task
        NSURL *url = [NSURL URLWithString:@"http://182.61.134.30:80/count/clear"];

        //3.创建可变的请求对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

        //4.修改请求方法为POST
        request.HTTPMethod = @"POST";

        //5.设置请求体
        NSString *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"number"];
        NSString *no = [@"no=" stringByAppendingString:number];
        request.HTTPBody = [no dataUsingEncoding:NSUTF8StringEncoding];

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
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"解析的数据为：%@",dict);
                NSString *result = [dict objectForKey:@"success"];
                NSLog(@"操作结果为:%@",result);
                if([result isEqual:@"true"]){
                    dispatch_async(dispatch_get_main_queue(), ^{

                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.operationSuccess preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:true completion:nil];

                    });

                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{

                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.operationFailed preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:true completion:nil];

                    });
                }
            }
        }];
        //8.执行
        [dataTask resume];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

@end
