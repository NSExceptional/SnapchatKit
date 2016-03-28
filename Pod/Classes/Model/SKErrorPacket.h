//
//  SKErrorPacket.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKPacket.h"


@interface SKErrorPacket : SKPacket

@property (nonatomic, readonly) NSString *errorIdentifier;
@property (nonatomic, readonly) NSString *message;

@end
