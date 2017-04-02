//
//  SKMessageStatePacket.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKMessageStatePacket.h"


@implementation SKMessageStatePacket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"chatMessageIdentifier": @"chat_message_id",
              @"state": @"state",
              @"version": @"version"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ id=%@, version=%@>",
            NSStringFromClass(self.class), self.chatMessageIdentifier, @(self.version)];
}

@end
