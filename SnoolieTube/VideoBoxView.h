//
//  VideoBoxView.h
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/07.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoBoxView : UIView

@property (nonatomic, readwrite) NSString *title;
@property (readwrite) UILabel *titleView;
@property (readwrite) UIImageView *thumbnail;
-(instancetype)initDebug;
-(instancetype)initDebugWithSize:(CGSize)size;
+(CGFloat)defaultHeight;
-(instancetype) initDebugWithFrame:(CGRect)frame;
+(CGFloat)thumbnailToLabelHeightRatio;
@property (nonatomic, readwrite) NSString *videoId;
-(instancetype)initWithFrame:(CGRect)frame;
-(void)changeThumbnail:(UIImage *)img;
@end

NS_ASSUME_NONNULL_END
