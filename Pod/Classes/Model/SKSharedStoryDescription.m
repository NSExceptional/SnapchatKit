//
//  SKSharedStoryDescription.m
//  SnapchatKit-OSX-Demo
//
//  Created by Tanner Bennett on 7/17/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSharedStoryDescription.h"

@implementation SKSharedStoryDescription

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ friend=\"%@\", local view=\"%@\", local post=\"%@\">",
            NSStringFromClass(self.class), self.friendNote, self.localViewTitle, self.localViewBody];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"friendNote": @"FRIEND",
             @"localPostBody": @"LOCAL_POST_BODY",
             @"localPostTitle": @"LOCAL_POST_TITLE",
             @"localViewBody": @"LOCAL_VIEW_BODY",
             @"localViewTitle": @"LOCAL_VIEW_TITLE"};
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKSharedStoryDescription class]])
        return [self isEqualToSharedStoryDescription:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToSharedStoryDescription:(SKSharedStoryDescription *)ssd {
    return [self.friendNote isEqualToString:ssd.friendNote] &&
           [self.localPostBody isEqualToString:ssd.localPostBody] &&
           [self.localPostTitle isEqualToString:ssd.localPostTitle] &&
           [self.localViewBody isEqualToString:ssd.localViewBody] &&
           [self.localViewTitle isEqualToString:ssd.localViewTitle];
}

@end
