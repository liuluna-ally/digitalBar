//
//  SelectMenuViewController.m
//  digitalbar2020
//  选择菜单
//  Created by user on 2020/11/8.
//

#import "SelectMenuViewController.h"
#import "SearchViewController.h"
#import "DeviceListViewController.h"
#import "MapViewController.h"
#import "ScanViewController.h"
#import "ViewController.h"
#import "AddStoreViewController.h"

@interface SelectMenuViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property NSString *textModel;
@property NSString *mapModel;
@property NSString *scanModel;
@property NSString *select;
@property NSMutableArray *arrays;
@property UIView *views;

@end

@implementation SelectMenuViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.textModel = NSLocalizedString(@"textModel", nil);
    self.mapModel = NSLocalizedString(@"mapModel", nil);
    self.scanModel = NSLocalizedString(@"scanModel", nil);
    self.select = NSLocalizedString(@"select", nil);
    
    //1.创建navbar
    UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    nav.barTintColor = [UIColor whiteColor];    
    //创建navbaritem
    UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:self.select];
    [nav pushNavigationItem:navTitle animated:YES];
    [self.view addSubview:nav];
    //创建barbutton 创建系统样式的
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(navBackBt:)];
    //设置barbutton
    navTitle.leftBarButtonItem = item;
    [nav setItems:[NSArray arrayWithObject:navTitle]];
    //创建添加按钮
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addStore:)];
    NSArray *buttonItem = @[btnAdd];
    navTitle.rightBarButtonItems = buttonItem;
    //2.设置数据
    _arrays = [[NSMutableArray alloc]init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict[@"image"] = @"text_model";
    dict[@"name"] = self.textModel;
    [_arrays addObject:dict];

    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]init];
    dict1[@"image"] = @"map_model";
    dict1[@"name"] = self.mapModel;
    [_arrays addObject:dict1];

    NSMutableDictionary *dict2 = [[NSMutableDictionary alloc]init];
    dict2[@"image"] = @"scan_model";
    dict2[@"name"] = self.scanModel;
    [_arrays addObject:dict2];
    //3.设置uiview
    for(int i = 0;i<[self.arrays count];i++){
        self.views = [[UIView  alloc]init];
        CGFloat marginTop = 90;
        CGFloat viewsW = self.view.frame.size.width;
        CGFloat viewsH = 140;
        CGFloat viewsX = 0;
        self.views.frame = CGRectMake(viewsX, marginTop + (viewsH+20)*i, viewsW, viewsH);
        [self.scrollView addSubview:self.views];
        //设置控件 上侧
        UIButton *btn = [[UIButton alloc]init];
        CGFloat btnH = 40;
        CGFloat btnW = 160;
        CGFloat btnX = (viewsW-btnW)/2;
        CGFloat btnY = 0;
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        NSDictionary *dict =  _arrays[i];
        NSString *imageName = [dict valueForKey:@"image"];
        [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        //设置tag
        btn.tag = i;
        //添加点击事件
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self.views addSubview:btn];
        
        //设置控件 下侧
        UILabel *lableName = [[UILabel alloc]init];
        CGFloat nameH = 20;
        CGFloat nameW = 120;
        CGFloat nameX = (viewsW-nameW)/2;
        CGFloat nameY = CGRectGetMaxY(btn.frame)+10;
        
        lableName.frame = CGRectMake(nameX, nameY, nameW, nameH);
        NSString *name = [dict valueForKey:@"name"];
        lableName.text = name;
        lableName.textAlignment = NSTextAlignmentCenter;
        [self.views addSubview:lableName];
    }
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,  (self.views.frame.size.height)* ([self.arrays count]));
}

// 返回按钮按下
- (void)navBackBt:(UIButton *)sender{
    //跳转到下一页面
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"main"];
    viewController.modalPresentationStyle = 0;
    [self presentViewController:viewController animated:YES completion:nil];
}

//添加按钮按下
- (void)addStore:(UIButton *)sender{
    //跳转到下一页面
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddStoreViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"addstore"];
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
            SearchViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"search"];
            viewController.modalPresentationStyle = 0;
            [self presentViewController:viewController animated:YES completion:nil];
        }else if(btn.tag == 1){
            UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MapViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"map"];
            viewController.modalPresentationStyle = 0;
            [self presentViewController:viewController animated:YES completion:nil];
        }else if(btn.tag == 2){
            UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ScanViewController *viewController = [storyBorad instantiateViewControllerWithIdentifier:@"scan"];
            viewController.modalPresentationStyle = 0;
            [self presentViewController:viewController animated:YES completion:nil];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

@end
