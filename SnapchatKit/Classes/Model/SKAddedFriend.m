//
//  SKAddedFriend.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKAddedFriend.h"

@implementation SKAddedFriend

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ add source=%@, username=%@, displayn=%@ pending count=%@>",
            NSStringFromClass(self.class), _addSource, self.username, self.displayName, @(_pendingSnaps)];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"addSource": @"add_source",
              @"addSourceType": @"add_source_type",
              @"timestamp": @"ts",
              @"pendingSnaps": @"pending_snaps_count"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

+ (NSValueTransformer *)addSourceTypeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *type, BOOL *success, NSError *__autoreleasing *error) {
        return @(SKAddSourceFromString(type));
    } reverseBlock:^id(NSNumber *type, BOOL *success, NSError *__autoreleasing *error) {
        return SKStringFromAddSource(type.integerValue);
    }];
}

MTLTransformPropertyDate(timestamp)

@end
