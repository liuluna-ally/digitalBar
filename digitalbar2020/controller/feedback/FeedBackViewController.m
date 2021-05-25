//
//  FeedBackViewController.m
//  digitalbar2020
//  反馈内容提交界面
//  Created by user on 2020/11/16.
//

#import "FeedBackViewController.h"
#import "RecordViewController.h"
#import "FunctionListViewController.h"

@interface FeedBackViewController ()

@property (strong, nonatomic) IBOutlet UITextField *lb_content;


@property (strong, nonatomic) IBOutlet UITextField *lb_contact;
@property (strong, nonatomic) IBOutlet UIButton *btn_submit;

@property NSString *unreachNetwork;
@property NSString *unserver;
@property NSString *tips;
@property NSString *determine;
@property NSString *empty;
@property NSMutableArray *result;
@property NSString *submitError;
@property NSString *submitSuccess;
@property NSString *username;
@property NSString *type;
@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        //使文字在最上方显示
        self.unreachNetwork = NSLocalizedString(@"unreachNetwork", nil);
        self.unserver = NSLocalizedString(@"unserver", nil);
        self.tips = NSLocalizedString(@"Tips", nil);
        self.determine = NSLocalizedString(@"determine", nil);
        self.empty = NSLocalizedString(@"empty", nil);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.username = [defaults objectForKey:@"username"];
        self.type = [defaults objectForKey:@"type"];
        self.lb_content.placeholder = NSLocalizedString(@"content", nil);
        self.lb_contact.placeholder = NSLocalizedString(@"contact", nil);
        self.submitError = NSLocalizedString(@"submitError", nil);
        self.submitSuccess = NSLocalizedString(@"submitSuccess", nil);
        [self.btn_submit setTitle:NSLocalizedString(@"submit", nil) forState:UIControlStateNormal];
        
        //创建navbar
        UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
        nav.barTintColor = [UIColor whiteColor];    
        //创建navbaritem
        UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:[defaults objectForKey:@"type"]];
        [nav pushNavigationItem:navTitle animated:YES];
        [self.view addSubview:nav];
        //创建barbutton 创建系统样式的
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
        //设置barbutton
        navTitle.leftBarButtonItem = item;
        [nav setItems:[NSArray arrayWithObject:navTitle]];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

// 返回按钮按下
- (void)navBackBt:(UIButton *)sender{
    //跳转到下一页面
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FunctionListViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"functionlist"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)submit:(id)sender {
    @try {
        if([self.lb_contact.text isEqual:@""] || [self.lb_content.text isEqual:@""]){
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.tips message:self.empty preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:self.determine style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:true completion:nil];
            
        }else{
            //1.创建会话对象
            NSURLSession *session = [NSURLSession sharedSession];
            //2.根据会话对象创建task
            NSURL *url = [NSURL URLWithString:@"http://182.61.134.30:80/feedback/insert"];
            
            //3.创建可变的请求对象
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            //4.修改请求方法为POST
            request.HTTPMethod = @"POST";
            
            //5.设置请求体
            NSString *content = [@"content=" stringByAppendingString:self.lb_content.text];
            NSString *contact = [@"contact=" stringByAppendingString:self.lb_contact.text];
            
            NSString *str1 = [content stringByAppendingString:@"&"]; //content=11&
            NSString *str2 = [str1 stringByAppendingString:contact];//content=11&contact=11
            NSString *str3 = [str2 stringByAppendingString:@"&"];//content=11&contact=11&
            NSString *str4 = [@"username=" stringByAppendingString:self.username];//username=diamchina
            NSString *str5 = [str4 stringByAppendingString:@"&"];//username=diamchina&
            NSString *str6 = [@"type=" stringByAppendingString:self.type];//type=450
            NSString *str7 = [str3 stringByAppendingString:str5];//content=11&contact=11&username=diamchina&
            NSString *str8 = [str7 stringByAppendingString:str6];//content=11&contact=11&username=diamchina&type=450
            request.HTTPBody = [str8 dataUsingEncoding:NSUTF8StringEncoding];
            
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
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
- (IBAction)record:(id)sender {
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RecordViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"record"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
