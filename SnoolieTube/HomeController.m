//
//  HomeController.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/07.
//

#import "HomeController.h"
#import "VideoBoxView.h"
#import "InvidiousAPIManager.h"

@interface HomeController ()

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    [searchBar setPlaceholder:@"Search for \"Lemon Demon\"..."];
    /* Probably a bad idea to have the search bar in the scoll view since then a user will need to scroll up to search but ah well */
    int searchBarHeight = 100;
    UIView *view = [self view];
    CGRect frame = [view frame];
    [searchBar setFrame:CGRectMake(0, 0, frame.size.width, searchBarHeight)];
    [searchBar setDelegate:self];
    self->_searchBar = searchBar;
    
    CGRect scrollViewFrame = CGRectMake(0, searchBarHeight, frame.size.width, frame.size.height - searchBarHeight);
    
    VideoBoxScrollView *scrollView = [[VideoBoxScrollView alloc]initWithFrame:scrollViewFrame];

    [view addSubview:scrollView];
    _videos = scrollView;
    [view addSubview:searchBar];
}
-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
    VideoBoxScrollView *videos = [self videos];
    /* Empty previous search */
    [videos emptyVideoBoxes];
    [[videos pendingLabel]setText:@"Searching..."];
    
    /* Search! */
    [InvidiousAPIManager search:[searchBar text] completion:^(NSArray *response, NSError *err){
        if (err) {
            /* There was an error with the request; ABORT! */
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            unsigned int limitVideoBox = 10;
            for (NSDictionary *content in response) {
                NSString *type = content[@"type"];
                if ([@"video" isEqualToString:type]) {
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
                    [videos newVideoBoxWithTitle:content[@"title"] videoId:content[@"videoId"] author:content[@"author"] thumbnailURL:videoURL];
                    limitVideoBox--;
                    if (!limitVideoBox) {
                        return;
                    }
                } else if ([@"playlist" isEqualToString:type]) {
                    NSURL *playlistThumbnailURL = nil;
                    NSString *playlistThumbnailString = content[@"playlistThumbnail"];
                    if (playlistThumbnailString) {
                        playlistThumbnailURL = [NSURL URLWithString:playlistThumbnailString];
                    }
                    [videos newVideoBoxPlaylistWithTitle:content[@"title"] playlistId:content[@"playlistId"] thumbnailURL:playlistThumbnailURL];
                    limitVideoBox--;
                    if (!limitVideoBox) {
                        return;
                    }
                }
            }
        });
    }];
}
@end
