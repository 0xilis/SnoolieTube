//
//  InvidiousAPIManager.m
//  SnoolieTube
//
//  Created by Snoolie Keffaber on 2024/03/10.
//

#import "InvidiousAPIManager.h"

@implementation InvidiousAPIManager
+(NSDictionary *)search:(NSString *)text {
    __block NSDictionary *responseDict;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        NSString *searchString = [NSString stringWithFormat:@"https://vid.puffyan.us/api/v1/search?q=%@",text];
        [request setURL:[NSURL URLWithString:searchString]];
        NSError *error = nil;
        NSHTTPURLResponse *responseCode = nil;
        
        [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"*" forHTTPHeaderField:@"Access-Control-Allow-Origin"];
        
        NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
            
        if([responseCode statusCode] != 200){
            NSLog(@"Error GET, HTTP status code %li", (long)[responseCode statusCode]);
            exit(7829);
        }
            
        dispatch_async(dispatch_get_main_queue(), ^(void){
            responseDict = [NSJSONSerialization JSONObjectWithData:oResponseData options:kNilOptions error:nil];
        });
    });
    return responseDict;
}
+(void)hlsURLWithVideoId:(NSString *)videoIdOfVideo completion:(void(^)(NSString *hlsURL))comp {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        comp(downloadVideo(videoIdOfVideo));
    });
}
+(void)search:(NSString *)text completion:(void (^)(NSArray * _Nullable response, NSError * _Nullable err))comp {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        NSString *urlEnccodedSearchText = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSString *searchString = [NSString stringWithFormat:@"https://vid.puffyan.us/api/v1/search?q=%@",urlEnccodedSearchText];
        [request setURL:[NSURL URLWithString:searchString]];
        NSError *error = nil;
        NSHTTPURLResponse *responseCode = nil;
        
        [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"*" forHTTPHeaderField:@"Access-Control-Allow-Origin"];
        
        NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
            
        if([responseCode statusCode] != 200){
            NSLog(@"Error GET, HTTP status code %li", (long)[responseCode statusCode]);
            comp(nil,error);
        }
        
        comp([NSJSONSerialization JSONObjectWithData:oResponseData options:kNilOptions error:nil],error);
    });
}
@end


NSString* OLD_downloadVideo(NSString* videoIdOfVideo, NSString *quality, NSString *audioQuality, NSString *downloadType) {
    //NSString *videoIdOfVideo = @"WO2b03Zdu4Q";
    NSString *videoUrlWithId = [NSString stringWithFormat:@"/watch?v=%@", videoIdOfVideo];
    //NSString *quality = @"1080p60";
    //NSString *audioQuality = @"AUDIO_QUALITY_MEDIUM";
    //NSString *downloadType = @"video"; //for audio do @"audio"
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSDictionary *user = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"lockedSafetyMode", nil];
    NSDictionary *darequest = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"useSsl",[NSArray array],@"internalExperimentFlags",[NSArray array],@"consistencyTokenJars",nil];
    NSDictionary *contentPlaybackContext = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"vis",[NSNumber numberWithBool:NO],@"splay",[NSNumber numberWithBool:NO],@"autoCaptionsDefaultOn",@"STATE_NONE",@"autonavState",@"HTML5_PREF_WANTS",@"html5Preference",@"-1",@"lactMilliseconds",nil];
    NSDictionary *client = [[NSDictionary alloc]initWithObjectsAndKeys:@"en",@"hl",@"WEB",@"clientName",@"2.20220427.01.00",@"clientVersion",@"UNKNOWN_FORM_FACTOR",@"clientFormFactor",@"WATCH",@"clientScreen",[[NSDictionary alloc]initWithObjectsAndKeys:videoUrlWithId,@"graftUrl",@"WEB_DISPLAY_MODE_BROWSER",@"webDisplayMode",nil],@"mainAppWebInfo",user,@"user",darequest,@"request",nil];
    NSDictionary *context = [[NSDictionary alloc] initWithObjectsAndKeys:client,@"client",videoIdOfVideo,@"videoId",[[NSDictionary alloc]initWithObjectsAndKeys:contentPlaybackContext,@"contentPlaybackContext",nil],@"playbackContext",[NSNumber numberWithBool:NO],@"racyCheckOk",[NSNumber numberWithBool:NO],@"contentCheckOk",nil];
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         context, @"context",
                         videoIdOfVideo, @"videoId",
                         nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setURL:[NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8"]];
    
    NSHTTPURLResponse *responseCode = nil;
    
    
    NSLog(@"Our data we're sending: %@",tmp);
    
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*" forHTTPHeaderField:@"Access-Control-Allow-Origin"];
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    //NSLog(@"Hello, World!");
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:oResponseData options:kNilOptions error:&error];
    NSLog(@"YouTube Response: %@",responseDict);
    NSArray *formatsResponse = [[responseDict objectForKey:@"streamingData"] objectForKey:@"adaptiveFormats"];
    
    if (quality) {
    for (NSDictionary* videoRes in formatsResponse) {
        //NSLog(@"videoRes: %@",videoRes);
        if ([downloadType isEqualToString:@"video"]) {
        if ([[videoRes objectForKey:@"qualityLabel"] isEqualToString:quality]) {
            return [videoRes objectForKey:@"url"]; // the url
        } else {
            NSLog(@"%@",videoRes);
        }
        } else if ([downloadType isEqualToString:@"audio"]) {
            if ([[videoRes objectForKey:@"audioQuality"]isEqualToString:audioQuality]) {
                return [videoRes objectForKey:@"url"];
            }
        }
    }
    } else {
        if ([downloadType isEqualToString:@"video"]) {
            for (NSDictionary* videoRes in formatsResponse) {
                NSLog(@"itag: %@",videoRes[@"itag"]);
                NSLog(@"url: %@",videoRes[@"url"]);
                if ([videoRes[@"itag"]isEqual:@"22"]) {
                    return videoRes[@"url"];
                }
            }
        }
    }
    return @"Error with getting video download URL";
}

NSString* downloadVideo(NSString* videoIdOfVideo) {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSDictionary *cpbContext = @{
      @"signatureTimestamp": @"sts",
      @"html5Preference": @"HTML5_PREF_WANTS",
    };
    NSDictionary *pbContext = @{
      @"contentPlaybackContext": cpbContext
    };
    NSDictionary *client = @{
        @"hl" : @"en",
        @"gl" : @"KP",
        @"clientName" : @"IOS",
        @"clientVersion" : @"17.33.2",
        @"deviceModel" : @"iPhone14,3",
        @"playbackContext": pbContext
    };
    NSDictionary *context = @{
        @"client" : client,
    };
    NSDictionary *tmp = @{
        @"context" : context,
        @"videoId" : videoIdOfVideo,
        @"racyCheckOk" : @YES,
        @"contentCheckOk" : @YES,
    };
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setURL:[NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/player?key=AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc"]];
    
    NSHTTPURLResponse *responseCode = nil;
    
    
    //NSLog(@"Our data we're sending: %@",tmp);
    
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*" forHTTPHeaderField:@"Access-Control-Allow-Origin"];
    [request setValue:@"com.google.ios.youtube/17.33.2 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)" forHTTPHeaderField:@"User-Agent"];
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    //NSLog(@"Hello, World!");
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:oResponseData options:kNilOptions error:&error];
    //NSLog(@"YouTube Response: %@",responseDict);
    return responseDict[@"streamingData"][@"hlsManifestUrl"];
}
