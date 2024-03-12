//
//  InvidiousAPIManager.h
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InvidiousAPIManager : NSObject
+(NSDictionary *)search:(NSString *)text;
+(void)search:(NSString *)text completion:(void(^)(NSArray * _Nullable response, NSError * _Nullable err))comp;
+(void)hlsURLWithVideoId:(NSString *)videoIdOfVideo completion:(void(^)(NSString *hlsURL))comp;
+(void)playlistWithId:(NSString *)playlistId completion:(void(^)(NSDictionary * _Nullable response, NSError * _Nullable err))comp;
NSString* downloadVideo(NSString* videoIdOfVideo);
@end

NS_ASSUME_NONNULL_END
