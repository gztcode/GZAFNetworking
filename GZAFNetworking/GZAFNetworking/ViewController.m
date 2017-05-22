//
//  ViewController.m
//  GZAFNetworking
//
//  Created by aten07 on 2016/12/19.
//  Copyright © 2016年 aten07. All rights reserved.
//

#import "ViewController.h"
#import "GZAFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSString * strUlr =@"http://apicloud.mob.com/v1/weather/query?key=194907ba9cc15&city=北京";
    [GZAFNetworking GZGETOnlineRequest:strUlr CacheTime:10 isLoadingView:@"正在加载..." blockPro:^(float progress) {
        NSLog(@"%f",progress);
    } success:^(id responseObject, BOOL succe, NSDictionary *jsonDic) {
        NSLog(@"____%@",jsonDic);
        
    } failure:^(NSError *error) {
        
    }];
    
//    NSData *date =[NSData dataWith];
    
   
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
