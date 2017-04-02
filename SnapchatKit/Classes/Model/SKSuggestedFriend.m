//
//  SKSuggestedFriend.m
//  Pods
//
//  Created by Tanner on 12/23/15.
//
//

#import "SKSuggestedFriend.h"

@implementation SKSuggestedFriend

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"username": @"name",
             @"displayName": @"display",
             @"identifier": @"id",
             @"isHidden": @"is_hidden",
             @"isNewSnapchatter": @"is_new_snapchatter",
             @"suggestReason": @"suggest_reason",
             @"suggestReasonDisplay": @"suggest_reason_display"};
}

@end
