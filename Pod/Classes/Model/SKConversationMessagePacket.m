//
//  SKConversationMessagePacket.m
//  Pods
//
//  Created by Tanner on 3/25/16.
//
//

#import "SKConversationMessagePacket.h"

@implementation SKConversationMessagePacket
@dynamic canSendOverHTTP;
@dynamic needsACK;

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"auth": @"header.auth",
              @"connSequenceNumber": @"header.conn_seq_num",
              @"header_conversationIdentifier": @"header.conv_id",
              @"from": @"header.from",
              @"to": @"header.to",
              @"retried": @"retried"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ from=%@, to=%@>",
            NSStringFromClass(self.class), self.from, self.to.firstObject];
}

@end
