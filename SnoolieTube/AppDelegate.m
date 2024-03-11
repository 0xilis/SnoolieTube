//
//  AppDelegate.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/07.
//

#import "AppDelegate.h"
#import "HomeController.h"

UINavigationController *navigationController;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /* inline asm can reduce a good bit of instructions here */
    UIWindow *window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _window = window;
    [window makeKeyAndVisible];
    if (@available(iOS 13.0, *)) {
        window.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        window.backgroundColor = [UIColor whiteColor];
    }
    UINavigationController* navBar = [[UINavigationController alloc]initWithRootViewController:[[HomeController alloc]init]];
    [window setRootViewController:navBar];
    navigationController = navBar;
    return YES;
}


@end
