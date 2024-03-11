//
//  VideoBoxScrollView.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/10.
//

#import "VideoBoxScrollView.h"

#if 0

@implementation VideoBoxScrollView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        UISearchBar *searchBar = [[UISearchBar alloc]init];
        [searchBar setPlaceholder:@"Search for \"Lemon Demon\"..."];
        /* Probably a bad idea to have the search bar in the scoll view since then a user will need to scroll up to search but ah well */
        [searchBar setFrame:CGRectMake(0, 0, frame.size.width, searchBarHeight)];
        [searchBar setDelegate:self];
        [self addSubview:searchBar];
        self->_searchBar = searchBar;
    }
    return self;
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
    
    NSLog(@"response: %@",response);
    
    if (videoBoxes) {
        unsigned int i = 0;
        for (NSDictionary *content in response) {
            NSString *type = content[@"type"];
            if ([@"video" isEqualToString:type]) {
                if ([videoBoxes count] <= i) {

                } else {
                    VideoBoxView *new = videoBoxes[i];
                    [new setTitle:content[@"title"]];
                    [new setVideoId:content[@"videoId"]];
                    videoBoxes[i] = new;
                }
                i++;
            }
        }
    }
}

@end

#endif
