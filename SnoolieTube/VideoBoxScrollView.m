//
//  VideoBoxScrollView.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/10.
//

#import "VideoBoxScrollView.h"

@implementation VideoBoxScrollView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UISearchBar *searchBar = [[UISearchBar alloc]init];
        [searchBar setPlaceholder:@"Search for \"Lemon Demon\"..."];
        /* Probably a bad idea to have the search bar in the scoll view since then a user will need to scroll up to search but ah well */
        int searchBarHeight = 100;
        [searchBar setFrame:CGRectMake(0, 0, frame.size.width, searchBarHeight)];
        [searchBar setDelegate:self];
        [self addSubview:searchBar];
        self->_searchBar = searchBar;
        [self setContentSize:CGSizeMake(frame.size.width, searchBarHeight)];
        self->_videoBoxes = [NSMutableArray new];
    }
    return self;
}
-(void)addVideoBox:(VideoBoxView *)videoBox {
    [_videoBoxes addObject:videoBox];
    [self addSubview:videoBox];
    [self resizeForVideos];
}
-(CGFloat)please_dont_call_yourself_getYOffset {
    CGFloat combinedVideoSize = 0;
    NSArray <VideoBoxView *>* videoBoxes = [self videoBoxes];
    if (videoBoxes) {
        combinedVideoSize = [VideoBoxView defaultHeight] * [videoBoxes count];
    }
    return combinedVideoSize + [[self searchBar]frame].size.height;
}
-(void)newVideoBoxWithTitle:(NSString *)title videoId:(NSString *)videoId thumbnailURL:(NSURL *)thumbnailURL {
    /* thumbnailURL currently ignored */
    VideoBoxView *box = [[VideoBoxView alloc]initWithFrame:CGRectMake(0, [self please_dont_call_yourself_getYOffset], [self frame].size.width, [VideoBoxView defaultHeight])];
    [box setTitle:title];
    [box setVideoId:videoId];
    NSMutableArray *videoBoxes = _videoBoxes;
    if (!videoBoxes) {
        videoBoxes = [NSMutableArray new];
        _videoBoxes = videoBoxes;
    }
    [videoBoxes addObject:box];
    [self addSubview:box];
    [self resizeForVideos];
    if (thumbnailURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:thumbnailURL];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                UIImage *thumbnailImage = [UIImage imageWithData:imageData];
                [box changeThumbnail:thumbnailImage];
            });
        });
    }
}
-(void)emptyVideoBoxes {
    for (VideoBoxView *videoBox in _videoBoxes) {
        [videoBox removeFromSuperview];
    }
    /* Hopefully ARC knows to free _videoBoxes... */
    _videoBoxes = [NSMutableArray new];
}
-(void)resizeForVideos {
    /*
     * Notice for future:
     * We do plan on adding playlists later, which honestly will
     * probably be the size of videos anyways, but we are also
     * adding channels which may not be?
     * Assuming they aren't (we would have to use multiple
     * arrays instead of one big one) then we would also add
     * the count of them times the defaultHeight too.
     *
     * This is also bad since it assumes that all VideoBoxViews
     * will have the same height, but right now we don't need to
     * worry about that since they will all be the same height,
     * plus I can't really think of a way to handle that...
     */
    CGFloat combinedVideoSize = 0;
    NSArray <VideoBoxView *>* videoBoxes = [self videoBoxes];
    if (videoBoxes) {
        combinedVideoSize = [VideoBoxView defaultHeight] * [videoBoxes count];
    }
    [self setContentSize:CGSizeMake([self frame].size.width, combinedVideoSize + [[self searchBar]frame].size.height)];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
    /* Empty previous search */
    [self emptyVideoBoxes];
    
    /* TODO: Run this on background thread properly in the future */
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    NSString *urlEnccodedSearchText = [[searchBar text]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *searchString = [NSString stringWithFormat:@"https://vid.puffyan.us/api/v1/search?q=%@",urlEnccodedSearchText];
    [request setURL:[NSURL URLWithString:searchString]];
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*" forHTTPHeaderField:@"Access-Control-Allow-Origin"];
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    NSArray *response = [NSJSONSerialization JSONObjectWithData:oResponseData options:kNilOptions error:nil];
    
    //NSLog(@"response: %@",response);
    
    unsigned int limitVideoBox = 10;
    
    unsigned int i = 0;
    
    for (NSDictionary *content in response) {
        NSString *type = content[@"type"];
        if ([@"video" isEqualToString:type]) {
            if (i < limitVideoBox) {
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
                [self newVideoBoxWithTitle:content[@"title"] videoId:content[@"videoId"] thumbnailURL:videoURL];
                i++;
            }
        }
    }
}

@end
