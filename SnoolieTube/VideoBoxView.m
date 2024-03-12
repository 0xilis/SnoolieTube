//
//  VideoBoxView.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/07.
//

#import "VideoBoxView.h"
#import "HomeController.h"
#import "WatchViewController.h"
#import <AVKit/AVKit.h>
#import "InvidiousAPIManager.h"
#import "YTPlaylistController.h"

@implementation VideoBoxView
-(instancetype)init {
    self = [super init];
    if (self) {
        UILabel *titleView = [[UILabel alloc]init];
        self->_titleView = titleView;
        UIImageView *thumbnail = [[UIImageView alloc]init];
        self->_thumbnail = thumbnail;
        UILabel *subtitleView = [[UILabel alloc]init];
        self->_subtitleView = subtitleView;
        /*
         * TODO:
         * While thumbnail is not loaded, show just a blue square.
         * However, it may be better to show a random color,
         * or an image laying "Loading..." to give better
         * context that the thumbnail is not yet loaded.
         */
        [thumbnail setBackgroundColor:[UIColor blueColor]];
        [self addSubview:thumbnail];
        [self addSubview:subtitleView];
        [self addSubview:titleView];
        self->_boxType = VideoBoxVideoType;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:tap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}
-(instancetype)initDebug {
    self = [super init];
    if (self) {
        self->_titleView = [[UILabel alloc]init];
        [self addSubview:self->_titleView];
        UIImageView *thumbnail = [[UIImageView alloc]init];
        self->_thumbnail = thumbnail;
        [thumbnail setBackgroundColor:[UIColor blueColor]];
        [self addSubview:thumbnail];
        [self setBackgroundColor:[UIColor redColor]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
+(CGFloat)defaultHeight {
    return 250.0;
}
-(void)setTitle:(NSString *)title {
    _title = title;
    if (_titleView) {
        [_titleView setText:title];
    }
}
-(instancetype) initDebugWithFrame:(CGRect)frame {
    self = [self initDebug];
    if (self) {
        [self setFrame:frame];
        /* set up thumbnail */
        CGFloat titleY = frame.size.height * [VideoBoxView thumbnailToLabelHeightRatio];
        [self->_thumbnail setFrame:CGRectMake(0, 0, frame.size.width, titleY)];
        /* set up title */
        CGFloat thumbnailToLabelHeightRatioInverse = 1.0 - [VideoBoxView thumbnailToLabelHeightRatio];
        [self->_titleView setFrame:CGRectMake(0, titleY, frame.size.width, frame.size.height * thumbnailToLabelHeightRatioInverse)];
        [self->_titleView setBackgroundColor:[UIColor yellowColor]];
        [self->_titleView setTextColor:[UIColor blackColor]];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        /* [self init] */
        UILabel *titleView = [[UILabel alloc]init];
        self->_titleView = titleView;
        UIImageView *thumbnail = [[UIImageView alloc]init];
        self->_thumbnail = thumbnail;
        UILabel *subtitleView = [[UILabel alloc]init];
        self->_subtitleView = subtitleView;
        /*
         * TODO:
         * While thumbnail is not loaded, show just a blue square.
         * However, it may be better to show a random color,
         * or an image laying "Loading..." to give better
         * context that the thumbnail is not yet loaded.
         */
        [thumbnail setBackgroundColor:[UIColor blueColor]];
        /* set up thumbnail */
        CGFloat titleY = frame.size.height * [VideoBoxView thumbnailToLabelHeightRatio];
        [thumbnail setFrame:CGRectMake(0, 0, frame.size.width, titleY)];
        /* set up title */
        CGFloat thumbnailToLabelHeightRatioInverse = 1.0 - [VideoBoxView thumbnailToLabelHeightRatio];
        [titleView setFrame:CGRectMake(0, titleY, frame.size.width, frame.size.height * thumbnailToLabelHeightRatioInverse)];
        
        [self addSubview:thumbnail];
        [self addSubview:subtitleView];
        [self addSubview:titleView];
        self->_boxType = VideoBoxVideoType;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:tap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}
+(CGFloat)thumbnailToLabelHeightRatio {
    return 5.0/6.0;
}
-(void)tapped {
    VideoBoxType boxType = _boxType;
    if (boxType == VideoBoxPlaylistType || boxType == VideoBoxBookmarkPlaylistType) {
        NSString *playlistId = _playlistId;
        if (playlistId) {
            NSLog(@"Getting videos in playlist...");
            [InvidiousAPIManager playlistWithId:playlistId completion:^(NSDictionary * _Nullable response, NSError * _Nullable _err) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    YTPlaylistController *playlistController = [[YTPlaylistController alloc]initWithAPIResponse:response];
                    [navigationController pushViewController:playlistController animated:YES];
                });
            }];
        }
        return;
    }
    NSString *videoId = _videoId;
    if (videoId) {
        NSLog(@"Getting video URL...");
        [InvidiousAPIManager hlsURLWithVideoId:videoId completion:^(NSString *hlsURL){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                NSURL *videoURL = [NSURL URLWithString:hlsURL];
                //NSLog(@"videoURLString: %@",hlsURL);
                NSLog(@"videoURL: %@",videoURL);
                AVPlayer *player = [AVPlayer playerWithURL:videoURL];
                AVPlayerViewController *playerController = [[AVPlayerViewController alloc]init];
                [playerController setPlayer:player];
                [navigationController pushViewController:playerController animated:YES];
            });
        }];
    }
}
-(void)longPress {
    VideoBoxType boxType = _boxType;
    if (boxType == VideoBoxVideoType || boxType == VideoBoxPlaylistType) {
        if (@available(iOS 8.0, *)) {
            /* I'm not actually sure if this works */
            uint64_t freeSpace = getFreeDiskspaceManual_do_not_call();
            if (freeSpace < 1000) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SnoolieTube" message:@"You have less than 1GB left of free space. SnoolieTube cannot save bookmarks until you free up space." preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    //action when pressed button
                }];
                [alertController addAction:okAction];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SnoolieTube" message:@"Bookmark this video/playlist?" preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    NSString *bookmarksPath = [documentDir stringByAppendingPathComponent:@"local_playlists.plist"];
                    NSMutableDictionary *localPlaylists = [NSMutableDictionary dictionaryWithContentsOfFile:bookmarksPath];
                    if (!localPlaylists) {
                        NSDictionary *localPlaylistsDict = @{
                            @"bookmarks" : @[],
                        };
                        localPlaylists = [NSMutableDictionary dictionaryWithDictionary:localPlaylistsDict];
                        [localPlaylists writeToFile:bookmarksPath atomically:YES];
                    }
                    NSMutableArray *bookmarks = [NSMutableArray arrayWithArray:localPlaylists[@"bookmarks"]];
                    if (!bookmarks) {
                        bookmarks = [[NSMutableArray alloc]initWithCapacity:1];
                    }
                    NSDictionary *bookmark;
                    if (boxType == VideoBoxVideoType) {
                        bookmark = @{
                            @"type" : @"video",
                            @"videoId" : self->_videoId,
                            @"title" : self->_title,
                            @"thumbnailURL" : [self->_thumbnailURL absoluteString],
                        };
                    } else {
                        bookmark = @{
                            @"type" : @"playlist",
                            @"playlistId" : self->_playlistId,
                            @"title" : self->_title,
                            @"thumbnailURL" : [self->_thumbnailURL absoluteString],
                        };
                    }
                    [bookmarks addObject:bookmark];
                    localPlaylists[@"bookmarks"] = bookmarks;
                    NSLog(@"localPlaylists: %@",localPlaylists);
                    NSLog(@"bookmarksPath: %@",bookmarksPath);
                    [localPlaylists writeToFile:bookmarksPath atomically:YES];
                }];
                UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                    //action when pressed button
                }];
                [alertController addAction:okAction];
                [alertController addAction:noAction];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
            }
        }
    } else if (boxType == VideoBoxBookmarkVideoType || boxType == VideoBoxBookmarkPlaylistType) {
        /* TODO: Remove the VideoBoxView from the VideoBoxScrollView upon bookmark removal. */
        if (@available(iOS 8.0, *)) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SnoolieTube" message:@"Remove this video/playlist?" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                NSString *bookmarksPath = [documentDir stringByAppendingPathComponent:@"local_playlists.plist"];
                NSMutableDictionary *localPlaylists = [NSMutableDictionary dictionaryWithContentsOfFile:bookmarksPath];
                NSArray *bookmarksStatic = localPlaylists[@"bookmarks"];
                NSMutableArray *bookmarks = [NSMutableArray arrayWithArray:bookmarksStatic];
                if (boxType == VideoBoxBookmarkVideoType) {
                    /* Find bookmark with video ID */
                    NSString *videoId = self->_videoId;
                    for (NSDictionary *bookmark in bookmarksStatic) {
                        NSString *content_id = bookmark[@"videoId"];
                        if ([videoId isEqualToString:content_id]) {
                            [bookmarks removeObject:bookmark];
                        }
                    }
                } else {
                    NSString *playlistId = self->_playlistId;
                    /* Find bookmark with playlist ID */
                    for (NSDictionary *bookmark in bookmarks) {
                        NSString *content_id = bookmark[@"playlistId"];
                        if ([playlistId isEqualToString:content_id]) {
                            [bookmarks removeObject:bookmark];
                        }
                    }
                }
                localPlaylists[@"bookmarks"] = bookmarks;
                [localPlaylists writeToFile:bookmarksPath atomically:YES];
            }];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                //action when pressed button
            }];
            [alertController addAction:okAction];
            [alertController addAction:noAction];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    }
}
-(void)changeThumbnail:(UIImage *)img {
    if (_thumbnail) {
        [_thumbnail setImage:img];
    }
}
@end

/* returns MiB*/
uint64_t getFreeDiskspaceManual_do_not_call(void) {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }

    return ((totalFreeSpace/1024ll)/1024ll);
}
