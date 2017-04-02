//
//  SKProtocolErrorPacket.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKProtocolErrorPacket.h"


@implementation SKProtocolErrorPacket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"message": @"message"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ message=%@>",
            NSStringFromClass(self.class), self.message];
}

@end
