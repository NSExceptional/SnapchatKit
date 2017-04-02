//
//  SKStoryNote.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKStoryNote.h"

@implementation SKStoryNote

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ viewer=%@, screenshot=%d>",
            NSStringFromClass(self.class), self.viewer, self.screenshot];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"viewer": @"viewer",
             @"viewDate": @"timestamp",
             @"screenshot": @"screenshotted",
             @"storyPointer": @"storypointer"};
}

+ (NSArray *)ignoredJSONKeyPathPrefixes {
    static NSArray *ignored = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ignored = @[@"storypointer.mField", @"storypointer.mKey"];
    });
    
    return ignored;
}

MTLTransformPropertyDate(viewDate)

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKStoryNote class]])
        return [self isEqualToStoryNote:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToStoryNote:(SKStoryNote *)storyNote {
    return [self.viewer isEqualToString:storyNote.viewer] && [self.viewDate isEqualToDate:storyNote.viewDate];;
}

@end
