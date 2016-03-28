//
//  SKConnectPacket.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKPacket.h"


@interface SKConnectPacket : SKPacket

+ (instancetype)withUsername:(NSString *)username auth:(NSDictionary *)auth;

@end
