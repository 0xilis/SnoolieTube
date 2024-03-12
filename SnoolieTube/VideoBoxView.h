//
//  VideoBoxView.h
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/07.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum VideoBoxType_t {
    VideoBoxVideoType,
    VideoBoxPlaylistType,
} VideoBoxType;

@interface VideoBoxView : UIView

@property (nonatomic, readwrite) NSString *title;
@property (readwrite) UILabel *titleView;
@property (nonatomic, readwrite) NSString *subtitle; /* Either author, or if playlist, say playlist */
@property (readwrite) UILabel *subtitleView;
@property (readwrite) UIImageView *thumbnail;
@property (readwrite) VideoBoxType boxType;
@property (nonatomic, readwrite) NSString *videoId;
@property (nonatomic, readwrite) NSString *playlistId;
-(instancetype)initDebug;
+(CGFloat)defaultHeight;
-(instancetype) initDebugWithFrame:(CGRect)frame;
+(CGFloat)thumbnailToLabelHeightRatio;
-(instancetype)initWithFrame:(CGRect)frame;
-(void)changeThumbnail:(UIImage *)img;
@end

NS_ASSUME_NONNULL_END
