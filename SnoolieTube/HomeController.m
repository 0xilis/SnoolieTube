//
//  HomeController.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/07.
//

#import "HomeController.h"
#import "VideoBoxView.h"
#import "InvidiousAPIManager.h"

NSMutableArray <VideoBoxView *>*videos;

@interface HomeController ()

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"video: %@",downloadVideo(@"WO2b03Zdu4Q",@"1080p60",@"AUDIO_QUALITY_MEDIUM",@"video"));
    
    
    // Do any additional setup after loading the view.
    UIView *view = [self view];
    CGRect frame = [view frame];
    CGRect ourFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:ourFrame];
    [scrollView setBackgroundColor:[UIColor orangeColor]];
    
    int videoBoxViewCount = 5;
    
    int searchBarHeight = 100;
    
    [scrollView setContentSize:CGSizeMake(ourFrame.size.width, ([VideoBoxView defaultHeight] * videoBoxViewCount) + searchBarHeight)];
    [view addSubview:scrollView];
    
    /* Test views */
    UISearchBar *search = [[UISearchBar alloc]init];
    [search setPlaceholder:@"Search for \"Lemon Demon\"..."];
    /* Probably a bad idea to have the search bar in the scoll view since then a user will need to scroll up to search but ah well */
    [search setFrame:CGRectMake(0, 0, frame.size.width, searchBarHeight)];
    [scrollView addSubview:search];
    [search setDelegate:self];
    [self setSearchBar:search];
    
    videos = [[NSMutableArray alloc]initWithCapacity:videoBoxViewCount];
    /* give starting y the offset of the search bar height */
    CGFloat y = searchBarHeight;
    for (int i = 0; i < videoBoxViewCount; i++) {
        VideoBoxView *videoBox = [[VideoBoxView alloc]initDebugWithFrame:CGRectMake(0, y, frame.size.width, [VideoBoxView defaultHeight])];
        [videoBox setTitle:@"Test Video"];
        [scrollView addSubview:videoBox];
        [videos addObject:videoBox];
        y += [VideoBoxView defaultHeight];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
    //NSDictionary *response = [InvidiousAPIManager search:[searchBar text]];
    //NSLog(@"response: %@",response);
    
    /* TEMP: Run this on background thread properly in the future */
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    NSString *searchString = [NSString stringWithFormat:@"https://vid.puffyan.us/api/v1/search?q=%@",[searchBar text]];
    [request setURL:[NSURL URLWithString:searchString]];
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*" forHTTPHeaderField:@"Access-Control-Allow-Origin"];
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    NSArray *response = [NSJSONSerialization JSONObjectWithData:oResponseData options:kNilOptions error:nil];
    
    //NSLog(@"response: %@",response);
    
    if (videos) {
        unsigned int i = 0;
        for (NSDictionary *content in response) {
            NSString *type = content[@"type"];
            if ([@"video" isEqualToString:type]) {
                if ([videos count] <= i) {

                } else {
                    VideoBoxView *new = videos[i];
                    [new setTitle:content[@"title"]];
                    [new setVideoId:content[@"videoId"]];
                    /* in the future, get thumbnail url */
                    /* cotent[@"videoThumbnails"] returns a array */
                    /* that array will have urls in the "url" key */
                    
                    videos[i] = new;
                }
                i++;
            }
        }
    }
}

@end
