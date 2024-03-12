//
//  VideoBoxScrollView.h
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/10.
//

#import <UIKit/UIKit.h>
#import "VideoBoxView.h"
#import "HomeController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoBoxScrollView : UIScrollView

@property (readwrite) NSMutableArray <VideoBoxView *>*videoBoxes;
@property (readwrite) UISearchBar *searchBar;
-(void)addVideoBox:(VideoBoxView *)videoBox;
-(instancetype)initWithFrame:(CGRect)frame;
@end

NS_ASSUME_NONNULL_END
