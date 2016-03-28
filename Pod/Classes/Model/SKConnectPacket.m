//
//  SKConnectPacket.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKConnectPacket.h"
#import "NSDictionary+SnapchatKit.h"
#import "NSString+SnapchatKit.h"


@implementation SKConnectPacket

+ (instancetype)withUsername:(NSString *)username auth:(NSDictionary *)auth {
    SKConnectPacket *packet = [self packet:@{@"username": username, @"auth": auth,
                                             @"type": @"connect",
                                             @"id": SKUniqueIdentifier(),
                                             @"platform": @"iOS",
                                             @"version": @"8.4",
                                             @"app_version": @"9.26.0.1"}];
    return packet;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, platform=%@, version=%@, app_version=%@>",
            NSStringFromClass(self.class), self.json[@"username"], self.json[@"platform"],
            self.json[@"version"], self.json[@"app_version"]];
}

@end
