//
//  SKReleaseMessagePacket.m
//  Pods
//
//  Created by Tanner on 3/25/16.
//
//

#import "SKReleaseMessagePacket.h"


@implementation SKReleaseMessagePacket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"knownChatSequenceNumbers": @"known_chat_sequence_numbers",
              @"knownRecievedSnapsTimestamps": @"known_received_snaps_ts",
              @"releaseType": @"release_type",
              @"timestamp": @"timestamp"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

MTLTransformPropertyDate(timestamp)

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ type=%@, date=%@>",
            NSStringFromClass(self.class), self.releaseType, self.timestamp];
}

@end
