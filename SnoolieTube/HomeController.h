//
//  HomeController.h
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/07.
//

#import <UIKit/UIKit.h>

@interface HomeController : UIViewController <UISearchBarDelegate>

@property (readwrite) UISearchBar *searchBar;
@end

extern UINavigationController *navigationController;
