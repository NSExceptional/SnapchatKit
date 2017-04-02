//
//  SKPingResponsePacket.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKPacket.h"


@interface SKPingResponsePacket : SKPacket

@property (nonatomic, readonly) NSString *pingIdentifier;

@end
