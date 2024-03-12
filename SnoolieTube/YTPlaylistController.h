//
//  YTPlaylistController.h
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/12.
//

#import <UIKit/UIKit.h>
#import "VideoBoxView.h"
#import "VideoBoxScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YTPlaylistController : UIViewController

@property (readwrite) NSDictionary *response;
@property (readwrite) VideoBoxScrollView *videoScrollView;
-(instancetype)initWithAPIResponse:(NSDictionary *)response;
@end

NS_ASSUME_NONNULL_END
