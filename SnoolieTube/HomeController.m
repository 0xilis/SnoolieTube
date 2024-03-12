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
    
    VideoBoxScrollView *bookmarkScrollView = [[VideoBoxScrollView alloc]initWithFrame:frame];
    _bookmarkScrollList = bookmarkScrollView;
    [bookmarkScrollView setHidden:YES];
    [view addSubview:bookmarkScrollView];
    
    
    CGFloat tabBarFrameY = frame.size.height * 0.9;
    CGFloat tabBarFrameH = frame.size.height - tabBarFrameY;
    CGRect tabBarFrame = CGRectMake(0, tabBarFrameY, frame.size.width, tabBarFrameH);
    UITabBar *tabBar = [[UITabBar alloc]initWithFrame:tabBarFrame];
    [tabBar setDelegate:self];
    UITabBarItem *tabBarItemSearch = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
    /* tabBarItemChannels is local channel favorites. This tab will give a list of channels to go to, and by tapping on one, it will lead you to the channel. */
    /*
     Not yet implemented:
    UITabBarItem *tabBarItemChannels = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
     */
    /* tabBarItemBookmarks is local playlists the user has saved. */
    UITabBarItem *tabBarItemBookmarks = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:1];
    /* tabBarItemDownloads are local downloads of audio/video */
    /*
     Not yet implemented:
    UITabBarItem *tabBarItemDownloads = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:4];
     */
    tabBar.items = @[
        tabBarItemSearch,
        tabBarItemBookmarks
    ];
    
    tabBar.selectedItem = tabBarItemSearch;
    [view addSubview:tabBar];
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
    UILabel *pendingLabel = [videos pendingLabel];
    [pendingLabel setText:@"Searching..."];
    
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
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSInteger selectedTag = tabBar.selectedItem.tag;
    if (selectedTag == 0) {
        /* Search */
        [self.searchBar setHidden:NO];
        VideoBoxScrollView *bookmarksView = [self bookmarkScrollList];
        if (bookmarksView) {
            [bookmarksView setHidden:YES];
        }
        [self.videos setHidden:NO];
    } else {
        /* Local Playlists / Bookmarks */
        [self.searchBar setHidden:YES];
        [self.videos setHidden:YES];
        
        VideoBoxScrollView *bookmarksView = _bookmarkScrollList;
        if (!bookmarksView) {
            bookmarksView = [[VideoBoxScrollView alloc]initWithFrame:[self.view frame]];
            [self.view addSubview:bookmarksView];
            _bookmarkScrollList = bookmarksView;
        }
        [bookmarksView emptyVideoBoxes];
        [bookmarksView setHidden:NO];
        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *bookmarksPath = [documentDir stringByAppendingPathComponent:@"local_playlists.plist"];
        NSDictionary *localPlaylists = [NSDictionary dictionaryWithContentsOfFile:bookmarksPath];
        if (localPlaylists) {
            NSArray *bookmarks = localPlaylists[@"bookmarks"];
            NSLog(@"here: %@",bookmarks);
            for (NSDictionary *content in bookmarks) {
                NSString *type = content[@"type"];
                if ([@"video" isEqualToString:type]) {
                    NSURL *videoURL = nil;
                    NSString *urlString = content[@"thumbnailURL"];
                    if (urlString) {
                        videoURL = [NSURL URLWithString:urlString];
                    }
                    [bookmarksView newVideoBoxWithTitle:content[@"title"] videoId:content[@"videoId"] author:nil thumbnailURL:videoURL];
                    [[bookmarksView videoBoxes]lastObject].boxType = VideoBoxBookmarkVideoType;
                } else if ([@"playlist" isEqualToString:type]) {
                    NSURL *playlistThumbnailURL = nil;
                    NSString *playlistThumbnailString = content[@"thumbnailURL"];
                    if (playlistThumbnailString) {
                        playlistThumbnailURL = [NSURL URLWithString:playlistThumbnailString];
                    }
                    [bookmarksView newVideoBoxPlaylistWithTitle:content[@"title"] playlistId:content[@"playlistId"] thumbnailURL:playlistThumbnailURL];
                    [[bookmarksView videoBoxes]lastObject].boxType = VideoBoxBookmarkPlaylistType;
                }
            }
        }
    }
}
@end
