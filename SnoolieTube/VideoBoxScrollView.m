//
//  VideoBoxScrollView.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/10.
//

#import "VideoBoxScrollView.h"

@implementation VideoBoxScrollView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setContentSize:CGSizeMake(frame.size.width, 0)];
        self->_videoBoxes = [NSMutableArray new];
        CGFloat middle = (frame.size.height / 2) - frame.origin.y;
        UILabel *pendingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, middle, frame.size.width, 100)];
        [pendingLabel setText:@"No results."];
        [pendingLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:pendingLabel];
        self->_pendingLabel = pendingLabel;
    }
    return self;
}
-(void)addVideoBox:(VideoBoxView *)videoBox {
    [_videoBoxes addObject:videoBox];
    [self addSubview:videoBox];
    [self resizeForVideos];
}
-(CGFloat)please_dont_call_yourself_getYOffset {
    CGFloat combinedVideoSize = 0;
    NSArray <VideoBoxView *>* videoBoxes = [self videoBoxes];
    if (videoBoxes) {
        combinedVideoSize = [VideoBoxView defaultHeight] * [videoBoxes count];
    }
    return combinedVideoSize;
}
-(void)newVideoBoxWithTitle:(NSString *)title videoId:(NSString *)videoId thumbnailURL:(NSURL *)thumbnailURL {
    [_pendingLabel setHidden:YES];
    /* thumbnailURL currently ignored */
    VideoBoxView *box = [[VideoBoxView alloc]initWithFrame:CGRectMake(0, [self please_dont_call_yourself_getYOffset], [self frame].size.width, [VideoBoxView defaultHeight])];
    [box setTitle:title];
    [box setVideoId:videoId];
    NSMutableArray *videoBoxes = _videoBoxes;
    if (!videoBoxes) {
        videoBoxes = [NSMutableArray new];
        _videoBoxes = videoBoxes;
    }
    [videoBoxes addObject:box];
    [self addSubview:box];
    [self resizeForVideos];
    if (thumbnailURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:thumbnailURL];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                UIImage *thumbnailImage = [UIImage imageWithData:imageData];
                [box changeThumbnail:thumbnailImage];
            });
        });
    }
}
-(void)emptyVideoBoxes {
    for (VideoBoxView *videoBox in _videoBoxes) {
        [videoBox removeFromSuperview];
    }
    /* Hopefully ARC knows to free _videoBoxes... */
    _videoBoxes = [NSMutableArray new];
    UILabel *pendingLabel = _pendingLabel;
    [pendingLabel setHidden:NO];
    [pendingLabel setText:@"No results."];
}
-(void)resizeForVideos {
    /*
     * Notice for future:
     * We do plan on adding playlists later, which honestly will
     * probably be the size of videos anyways, but we are also
     * adding channels which may not be?
     * Assuming they aren't (we would have to use multiple
     * arrays instead of one big one) then we would also add
     * the count of them times the defaultHeight too.
     *
     * This is also bad since it assumes that all VideoBoxViews
     * will have the same height, but right now we don't need to
     * worry about that since they will all be the same height,
     * plus I can't really think of a way to handle that...
     */
    CGFloat combinedVideoSize = 0;
    NSArray <VideoBoxView *>* videoBoxes = [self videoBoxes];
    if (videoBoxes) {
        combinedVideoSize = [VideoBoxView defaultHeight] * [videoBoxes count];
    }
    [self setContentSize:CGSizeMake([self frame].size.width, combinedVideoSize)];
}

@end
