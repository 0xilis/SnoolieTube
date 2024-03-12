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
-(void)addVideoBox:(VideoBoxView *)videoBox;
-(instancetype)initWithFrame:(CGRect)frame;
-(void)emptyVideoBoxes;
-(void)resizeForVideos;
-(void)newVideoBoxWithTitle:(NSString *)title videoId:(NSString *)videoId thumbnailURL:(NSURL *)thumbnailURL;
@property (readwrite) BOOL loading;
@property (readwrite) UILabel *pendingLabel;
@end

NS_ASSUME_NONNULL_END
