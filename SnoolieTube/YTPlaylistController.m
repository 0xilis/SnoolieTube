//
//  YTPlaylistController.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/12.
//

#import "YTPlaylistController.h"

@interface YTPlaylistController ()

@end

@implementation YTPlaylistController

-(instancetype)initWithAPIResponse:(NSDictionary *)response {
    self = [super init];
    if (self) {
        self->_response = response;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    VideoBoxScrollView *videoScrollView = [[VideoBoxScrollView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:videoScrollView];
    
    /* Load playlist */
    unsigned int limitVideoBox = 10;
    NSArray *videos = _response[@"videos"];
    for (NSDictionary *content in videos) {
        NSURL *videoURL = nil;
        NSArray *videoThumbnails = content[@"videoThumbnails"];
        if (videoThumbnails) {
            NSDictionary *hqThumbnail = videoThumbnails[0];
            if (hqThumbnail) {
                NSString *urlString = hqThumbnail[@"url"];
                if (urlString) {
                    videoURL = [NSURL URLWithString:urlString];
                }
            }
        }
        [videoScrollView newVideoBoxWithTitle:content[@"title"] videoId:content[@"videoId"] author:content[@"author"] thumbnailURL:videoURL];
        limitVideoBox--;
        if (!limitVideoBox) {
            return;
        }
    }
}

@end
