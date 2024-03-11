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
NSString* downloadVideo(NSString* videoIdOfVideo, NSString *quality, NSString *audioQuality, NSString *downloadType);
@end

NS_ASSUME_NONNULL_END
