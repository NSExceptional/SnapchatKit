//
//  SKPresencePacket.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKPresencePacket.h"


@implementation SKPresencePacket

+ (instancetype)presences:(NSDictionary *)presences video:(BOOL)video to:(NSArray *)to from:(NSString *)from auth:(NSString *)auth {
    return [self packet:@{@"type": SKStringFromPacketType(SKPacketTypePresence),
                          @"supports_here": @1,
                          @"receiving_video": @((int)video),
                          @"presences": presences,
                          @"header": @{@"from": from, @"to": to, @"auth": auth}}];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"hereAuth": @"here_auth",
              @"presences": @"presences",
              @"receivingVideo": @"receiving_video",
              @"supportsHere": @"supports_here"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ video=%@, supports_here=%@, to=%@, from=%@> presences:\n%@",
            NSStringFromClass(self.class), @(self.receivingVideo), @(self.supportsHere), self.to.firstObject, self.from, self.presences];
}

@end
