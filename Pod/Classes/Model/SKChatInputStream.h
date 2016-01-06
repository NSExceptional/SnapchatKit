//
//  SKChatInputStream.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import <Cocoa/Cocoa.h>
#import "SKPacket.h"

@interface NSInputStream (SKChatOutputStream)

- (SKPacket *)recievePacket;

@end
