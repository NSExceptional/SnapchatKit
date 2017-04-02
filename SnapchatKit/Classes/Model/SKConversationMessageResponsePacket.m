//
//  SKConversationMessageResponsePacket.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKConversationMessageResponsePacket.h"

@implementation SKConversationMessageResponsePacket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"ACKIdentifier": @"ack_id",
              @"conversationIdentifier": @"conv_id",
              @"failureReason": @"failure_reason",
              @"successful": @"success",
              @"timestamp": @"timestamp"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

MTLTransformPropertyDate(timestamp)

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ successful=%@, failure=%@, conv_id=%@, date=%@>",
            NSStringFromClass(self.class), @(self.successful), self.failureReason, self.conversationIdentifier, self.timestamp];
}

@end
