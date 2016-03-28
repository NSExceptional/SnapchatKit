//
//  SKErrorPacket.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKErrorPacket.h"


@implementation SKErrorPacket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"errorIdentifier": @"error_id",
              @"message": @"message"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ message=%@>",
            NSStringFromClass(self.class), self.message];
}

@end
