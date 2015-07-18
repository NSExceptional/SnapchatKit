//
//  SKSharedStoryDescription.m
//  SnapchatKit-OSX-Demo
//
//  Created by Tanner on 7/17/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSharedStoryDescription.h"

@implementation SKSharedStoryDescription

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    
    self = [super init];
    if (self) {
        _friendNote     = json[@"FRIEND"];
        _localPostBody  = json[@"LOCAL_POST_BODY"];
        _localPostTitle = json[@"LOCAL_POST_TITLE"];
        _localViewBody  = json[@"LOCAL_VIEW_BODY"];
        _localViewTitle = json[@"LOCAL_VIEW_TITLE"];
    }
    
    [[self class] addKnownJSONKeys:@[@"FRIEND", @"LOCAL_POST_BODY", @"LOCAL_POST_TITLE", @"LOCAL_VIEW_BODY", @"LOCAL_VIEW_TITLE"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ friend=\"%@\", local view=\"%@\", local post=\"%@\">",
            NSStringFromClass(self.class), self.friendNote, self.localViewTitle, self.localViewBody];
}

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
