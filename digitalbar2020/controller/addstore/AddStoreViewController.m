//
//  AddStoreViewController.m
//  digitalbar2020
//  增加店铺信息
//  Created by diam on 2021/1/7.
//

#import "AddStoreViewController.h"
#import "Reachability.h"
#import "SelectMenuViewController.h"
#pragma mark - 自定义按钮
//@interface MyButton : UIButton
//
//@property (strong ,nonatomic) NSDictionary *paramDic; // 用来传递参数
//
//@end

@interface AddStoreViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property UITextField *storeNameText;//输入的店铺名称
@property UITextField *branchNameText;//输入的分店名
@property UITextField *addressText;//输入的地址
@property UITextField *phoneText;//输入的电话
@property NSString *unreachNetwork;//网络不可用
@property NSString *unserver;//无法连接服务器
@property NSString *tips;//提示
@property NSString *determine;//确定
@property NSString *submitError;//内容重复
@property NSString *submitSuccess;//提交成功

@end

@implementation AddStoreViewController
#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    //1.文本
    NSString *storeInfo = NSLocalizedString(@"storeInfo", nil); //店铺信息
    NSString *storeName = NSLocalizedString(@"storeName", nil);//店铺名称
    NSString *branchName = NSLocalizedString(@"branchName", nil);//分店名称
    NSString *storeAddress = NSLocalizedString(@"storeAddress", nil);//店铺地址
    NSString *phone = NSLocalizedString(@"phone", nil);//电话
    NSString *addStore = NSLocalizedString(@"addStore", nil);//添加店铺
    _unreachNetwork = NSLocalizedString(@"unreachNetwork", nil);
    _unserver = NSLocalizedString(@"unserver", nil);
    _tips = NSLocalizedString(@"Tips", nil);
    _determine = NSLocalizedString(@"determine", nil);
    _submitError = NSLocalizedString(@"submitError", nil);
    _submitSuccess = NSLocalizedString(@"submitSuccess", nil);
    //2.设置导航栏
    UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    //头部title
    UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:storeInfo];
    nav.barTintColor = [UIColor whiteColor];
    [nav pushNavigationItem:navTitle animated:YES];
    [self.view addSubview:nav];
    //创建barbutton 创建系统样式的
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
    //设置barbutton
    navTitle.leftBarButtonItem = item;
    [nav setItems:[NSArray arrayWithObject:navTitle]];
    
    //3.设置控件
    CGFloat marginX = 30;
    CGFloat marginTop = 80;
    CGFloat viewsH = 60;
    CGFloat viewW = self.view.frame.size.width;
    //店铺名称 左
    UILabel *storeNameLabel = [[UILabel alloc]init];
    storeNameLabel.frame = CGRectMake(marginX, marginTop, viewW*0.25, viewsH);
    storeNameLabel.text = storeName;
    storeNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.scrollView addSubview:storeNameLabel];
    
    //分店名称 左
    UILabel *branchNameLabel = [[UILabel alloc]init];
    branchNameLabel.frame = CGRectMake(marginX, marginTop + (viewsH + marginX), viewW*0.25, viewsH);
    branchNameLabel.text = branchName;
    branchNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.scrollView addSubview:branchNameLabel];
    
    //地址左
    UILabel *addressLabel = [[UILabel alloc]init];
    addressLabel.frame = CGRectMake(marginX, marginTop + (viewsH + marginX)*2, viewW*0.25, viewsH);
    addressLabel.text = storeAddress;
    addressLabel.textAlignment = NSTextAlignmentLeft;
    [self.scrollView addSubview:addressLabel];
    
    //电话  左
    UILabel *phoneLabel = [[UILabel alloc]init];
    phoneLabel.frame = CGRectMake(marginX, marginTop + (viewsH + marginX)*3, viewW*0.25, viewsH);
    phoneLabel.text = phone;
    phoneLabel.textAlignment = NSTextAlignmentLeft;
    [self.scrollView addSubview:phoneLabel];
    
    //店铺名称 右
    CGFloat nameTextX = CGRectGetMaxX(phoneLabel.frame);
    CGFloat marginLeft = 30;
    CGFloat nameTextW = self.view.frame.size.width - nameTextX - marginLeft;
    CGFloat nameTextH = viewsH*0.75;
    CGFloat marTop = marginTop + viewsH*0.25;
    self.storeNameText = [[UITextField alloc]init];
    self.storeNameText.frame = CGRectMake(nameTextX,  marTop, nameTextW, nameTextH);
    self.storeNameText.borderStyle=UITextBorderStyleRoundedRect; //设置边框
    self.storeNameText.clearButtonMode=UITextFieldViewModeWhileEditing;//清除按钮
    [self.scrollView addSubview:self.storeNameText];
    
    //分店名称 右
    self.branchNameText = [[UITextField alloc]init];
    self.branchNameText.frame = CGRectMake(nameTextX, marTop + (viewsH + marginX), nameTextW, nameTextH);
    self.branchNameText.borderStyle=UITextBorderStyleRoundedRect; //设置边框
    self.branchNameText.clearButtonMode=UITextFieldViewModeWhileEditing;//清除按钮
    [self.scrollView addSubview:self.branchNameText];
    
    //地址 右
    self.addressText = [[UITextField alloc]init];
    self.addressText.frame = CGRectMake(nameTextX, marTop + (viewsH + marginX)*2, nameTextW, nameTextH);
    self.addressText.borderStyle=UITextBorderStyleRoundedRect; //设置边框
    self.addressText.clearButtonMode=UITextFieldViewModeWhileEditing;//清除按钮
    [self.scrollView addSubview:self.addressText];
    
    //电话  右
    self.phoneText = [[UITextField alloc]init];
    self.phoneText.frame = CGRectMake(nameTextX, marTop + (viewsH + marginX)*3, nameTextW, nameTextH);
    self.phoneText.borderStyle=UITextBorderStyleRoundedRect; //设置边框
    self.phoneText.clearButtonMode=UITextFieldViewModeWhileEditing;//清除按钮
    [self.scrollView addSubview: self.phoneText];
    
    //提交店铺信息控件
    UIButton *btnSubmit = [[UIButton alloc]init];
    CGFloat btnW = self.view.frame.size.width-40;
    CGFloat btnX = 20;
    CGFloat btnY = CGRectGetMaxY(phoneLabel.frame)+30;
    CGFloat btnH = 40 ;
    btnSubmit.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [btnSubmit setTitle:addStore forState:UIControlStateNormal];
    btnSubmit.backgroundColor = [UIColor systemTealColor];
    [btnSubmit addTarget:self action:@selector(BtnClick:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnSubmit];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(btnSubmit.frame));
}

// 返回按钮按下
- (void)navBackBt:(UIButton *)sender{
    //跳转到下一页面
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SelectMenuViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"selectmenu"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - 添加店铺按钮的事件
//添加店铺按钮的事件
- (void)BtnClick:(UIButton *)btn
{
    //获取控件数据
    NSString *storeName = [self.storeNameText text];//输入的店铺名称
    NSString *branchName = [self.branchNameText text];//输入的分店名
    NSString *address = [self.addressText text];//输入的地址
    NSString *phone = [self.phoneText text];//输入的电话
    if([storeName isEqual:@""] || [branchName isEqual:@""] || [address isEqual:@""] || [phone isEqual:@""]){
        NSLog(@"1111");
    }else{
        //请求服务器，添加店铺信息到数据库
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"storeName"] = storeName;
        dict[@"branchName"] = branchName;
        dict[@"address"] = address;
        dict[@"phone"] = phone;
        [self insertInfo:dict];
        //检测网络状态
        Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        reach.reachableBlock = ^(Reachability*reach)
        {
            //请求服务器，添加店铺信息到数据库
            NSDictionary *dict = [[NSDictionary alloc]init];
            [dict setValue:storeName forKey:@"storeName"];
            [dict setValue:branchName forKey:@"branchName"];
            [dict setValue:address forKey:@"address"];
            [dict setValue:phone forKey:@"phone"];
            [self insertInfo:dict];

        };

        reach.unreachableBlock = ^(Reachability*reach)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.unreachNetwork preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:true completion:nil];
            });
        };
    }
}

#pragma mark - 添加店铺信息到数据库
/**
 添加店铺信息到数据库
 */
-(void) insertInfo:(NSDictionary *)dict{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"http://182.61.134.30:80/insert/store"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    
    //5.设置请求体
    NSString *shopname = [dict objectForKey:@"storeName"];
    NSString *branchName = [dict objectForKey:@"branchName"];
    NSString *address = [dict objectForKey:@"address"];
    NSString *phone = [dict objectForKey:@"phone"];
    
    NSString *str1 = [@"shopname=" stringByAppendingString:shopname]; //shopname=11
    NSString *str2 = [str1 stringByAppendingString:@"&"];//shopname=11&
    NSString *str3 = [@"branchname=" stringByAppendingString:branchName];//branchName=11
    NSString *str4 = [str2 stringByAppendingString:str3];//shopname=11&branchName=11
    NSString *str5 = [str4 stringByAppendingString:@"&"];//shopname=11&branchName=11&
    NSString *str6 = [@"address=" stringByAppendingString:address];//address=450
    NSString *str7 = [str5 stringByAppendingString:str6];//shopname=11&branchName=11&address=450
    NSString *str8 = [str7 stringByAppendingString:@"&"];//shopname=11&branchName=11&address=450&
    NSString *str9 = [@"phone=" stringByAppendingString:phone];//phone=11
    NSString *str10 = [str8 stringByAppendingString:str9];//shopname=11&branchname=11&address=450&phone=11
    request.HTTPBody = [str10 dataUsingEncoding:NSUTF8StringEncoding];
    
    //6 根据会话对象创建一个Task(发送请求）
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
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSString *result = [dict objectForKey:@"success"];
            NSLog(@"请求结果为:%@",result);
            if([result isEqual:@"true"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.submitSuccess preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:true completion:nil];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.submitError preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:true completion:nil];
                });
            }
        }
    }];
    
    //7.执行任务
    [dataTask resume];
}

@end
