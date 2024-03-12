//
//  HomeController.h
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/07.
//

#import <UIKit/UIKit.h>
#import "VideoBoxScrollView.h"

@class VideoBoxScrollView; /* FOR SOME REASON XCODE IS NOT RECOGNIZING THE HEADER ??? */

@interface HomeController : UIViewController

@property (readwrite) UISearchBar *searchBar;
@property (readwrite) VideoBoxScrollView *videos;
@end

extern UINavigationController *navigationController;
