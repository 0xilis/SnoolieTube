//
//  VideoBoxView.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/07.
//

#import "VideoBoxView.h"
#import "HomeController.h"
#import "WatchViewController.h"
#import <AVKit/AVKit.h>
#import "InvidiousAPIManager.h"

@implementation VideoBoxView
-(instancetype)init {
    self = [super init];
    if (self) {
        self->_titleView = [[UILabel alloc]init];
        self->_thumbnail = [[UIImageView alloc]init];
    }
    return self;
}
-(instancetype)initDebug {
    self = [super init];
    if (self) {
        self->_titleView = [[UILabel alloc]init];
        [self addSubview:self->_titleView];
        UIImageView *thumbnail = [[UIImageView alloc]init];
        self->_thumbnail = thumbnail;
        [thumbnail setBackgroundColor:[UIColor blueColor]];
        [self addSubview:thumbnail];
        [self setBackgroundColor:[UIColor redColor]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(instancetype)initDebugWithSize:(CGSize)size {
    self = [self initDebug];
    if (self) {
        [self setFrame:CGRectMake(0, 0, size.width, size.height)];
        [self->_thumbnail setFrame:CGRectMake(0, 0, size.width, 20)];
        [self->_titleView setFrame:CGRectMake(0, 20, size.width, 10)];
    }
    return self;
}
+(CGFloat)defaultHeight {
    return 250.0;
}
-(void)setTitle:(NSString *)title {
    _title = title;
    if (_titleView) {
        [_titleView setText:title];
    }
}
-(instancetype) initDebugWithFrame:(CGRect)frame {
    self = [self initDebug];
    if (self) {
        [self setFrame:frame];
        /* set up thumbnail */
        CGFloat titleY = frame.size.height * [VideoBoxView thumbnailToLabelHeightRatio];
        [self->_thumbnail setFrame:CGRectMake(0, 0, frame.size.width, titleY)];
        /* set up title */
        CGFloat thumbnailToLabelHeightRatioInverse = 1.0 - [VideoBoxView thumbnailToLabelHeightRatio];
        [self->_titleView setFrame:CGRectMake(0, titleY, frame.size.width, frame.size.height * thumbnailToLabelHeightRatioInverse)];
        [self->_titleView setBackgroundColor:[UIColor yellowColor]];
        [self->_titleView setTextColor:[UIColor blackColor]];
    }
    return self;
}
+(CGFloat)thumbnailToLabelHeightRatio {
    return 5.0/6.0;
}
-(void)tapped {
    NSString *videoId = _videoId;
    if (videoId) {
        NSLog(@"Getting video URL...\n");
        NSString *videoURLString = downloadVideo(videoId);
        NSURL *videoURL = [NSURL URLWithString:videoURLString];
        NSLog(@"videoURLString: %@",videoURLString);
        NSLog(@"videoURL: %@",videoURL);
        AVPlayer *player = [AVPlayer playerWithURL:videoURL];
        AVPlayerViewController *playerController = [[AVPlayerViewController alloc]init];
        [playerController setPlayer:player];
        [navigationController pushViewController:playerController animated:YES];
    }
}
@end
