//
//  SKConnectResponsePacket.h
//  Pods
//
//  Created by Tanner on 3/25/16.
//
//

#import "SKPacket.h"

@interface SKConnectResponsePacket : SKPacket

@property (nonatomic, readonly) BOOL successful;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *failureReason;
@property (nonatomic, readonly) NSString *alternateServer;

@end
