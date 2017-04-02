//
//  SKChatMessagePacket.m
//  Pods
//
//  Created by Tanner on 1/6/16.
//
//

#import "SKChatMessagePacket.h"
#import "SnapchatKit-Constants.h"


@implementation SKChatMessagePacket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"text": @"body.text",
              @"media": @"body.media",
              @"messageType": @"body.type",
              @"attributes": @"body.attributes",
              @"chatMessageIdentifier": @"chat_message_id",
              @"state": @"saved_state",
              @"sequenceNumber": @"seq_num",
              @"timestamp": @"timestamp"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

MTLTransformPropertyDate(timestamp)

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ text=%@, type=%@, date=%@>",
            NSStringFromClass(self.class), self.text, self.messageType, self.timestamp];
}

@end
