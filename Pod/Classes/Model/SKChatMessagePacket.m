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

+ (NSValueTransformer *)propertytimestampJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *ts, BOOL *success, NSError *__autoreleasing *error) {
        return ts.doubleValue > 0 ? [NSDate dateWithTimeIntervalSince1970:ts.doubleValue/1000.f] : nil;
    } reverseBlock:^id(NSDate *ts, BOOL *success, NSError *__autoreleasing *error) {
        return ts ? @([ts timeIntervalSince1970] * 1000.f).stringValue : nil;
    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ text=%@, type=%@, date=%@>",
            NSStringFromClass(self.class), self.text, self.messageType, self.timestamp];
}

@end
