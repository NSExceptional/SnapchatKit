//
//  SKProtocolErrorPacket.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKPacket.h"


@interface SKProtocolErrorPacket : SKPacket

@property (nonatomic, readonly) NSString *message;

@end
