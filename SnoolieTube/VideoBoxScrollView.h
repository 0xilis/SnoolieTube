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
@property (readwrite) UILabel *pendingLabel;
-(void)addVideoBox:(VideoBoxView *)videoBox;
-(instancetype)initWithFrame:(CGRect)frame;
-(void)emptyVideoBoxes;
-(void)resizeForVideos;
-(void)newVideoBoxWithTitle:(NSString *)title videoId:(NSString *)videoId author:(NSString * _Nullable)author thumbnailURL:(NSURL *)thumbnailURL;
-(void)newVideoBoxPlaylistWithTitle:(NSString *)title playlistId:(NSString *)playlistId thumbnailURL:(NSURL *)thumbnailURL;
@end

NS_ASSUME_NONNULL_END
