//
//  HomeController.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/07.
//

#import "HomeController.h"
#import "VideoBoxView.h"
#import "InvidiousAPIManager.h"
#import "VideoBoxScrollView.h"

NSMutableArray <VideoBoxView *>*videos;

@interface HomeController ()

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSLog(@"video: %@",downloadVideo(@"WO2b03Zdu4Q",@"1080p60",@"AUDIO_QUALITY_MEDIUM",@"video"));
    
    
    // Do any additional setup after loading the view.
    UIView *view = [self view];
    CGRect frame = [view frame];
    CGRect ourFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    VideoBoxScrollView *scrollView = [[VideoBoxScrollView alloc]initWithFrame:ourFrame];

    [view addSubview:scrollView];
}

@end
