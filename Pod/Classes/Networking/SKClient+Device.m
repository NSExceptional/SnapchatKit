//
//  SKClient+Device.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Device.h"
#import "SKUser.h"
#import "SKRequest.h"

#import "NSString+SnapchatKit.h"
#import "NSArray+SnapchatKit.h"
#import "NSDictionary+SnapchatKit.h"

#define kUnimplemented @"Unimplemented"

@implementation SKClient (Device)

- (void)sendDidOpenAppEvent:(ErrorBlock)completion {
    [self updateSession:^(NSError *error) {
        if (!error) {
            NSString *uuid = SKUniqueIdentifier();
            NSInteger friendCount = -1;
            
            for (SKUser *friend in self.currentSession.friends)
                if (friend.friendStatus == SKFriendStatusMutual)
                    friendCount++;
            
            NSString *timestamp = [NSString timestamp];
            NSString *batchID = [NSString stringWithFormat:@"%@-%@%@", uuid, [SKConsts.userAgent stringByReplacingMatchesForRegex:@"[\\W]+" withString:@""], timestamp];
            NSDictionary *eventDict = @{@"common_params": @{@"user_id":self.username.MD5Hash,
                                                            @"city": kUnimplemented,
                                                            @"sc_user_agent": SKConsts.userAgent,
                                                            @"session_id":@"00000000-0000-0000-0000-000000000000",
                                                            @"region": kUnimplemented,
                                                            @"latlon": kUnimplemented,
                                                            @"friend_count": @(friendCount),
                                                            @"country": kUnimplemented}.JSONString,
                                        @"events": @[@{@"event_name": @"APP_OPEN",
                                                       @"event_timestamp": timestamp,
                                                       @"event_params": @{@"open_state": @"NORMAL", @"intent_action": @"NULL"}.JSONString}.JSONString].JSONString,
                                        @"batch_id": batchID};
            
            [SKRequest sendEvents:eventDict callback:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (completion) {
                    if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                        completion(nil);
                    } else {
                        [self handleError:error data:data response:response completion:^(id object, NSError *error) {
                            completion(error);
                        }];
                    }
                }
            }];
            
        } else {
            completion(error);
        }
    }];
}

- (void)sendDidCloseAppEvent:(ErrorBlock)completion {
    NSArray *events = @[@{@"eventName": @"CLOSE",
                          @"params": @{},
                          @"ts": [NSString timestamp]}];
    [self sendEvents:events data:nil completion:completion];
}

@end
