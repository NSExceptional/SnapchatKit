//
//  SKChatInputStream.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import <Foundation/Foundation.h>
#import "SKPacket.h"

@interface NSInputStream (SKChatInputStream)

- (SKPacket *)recievePacket;
- (NSData *)readData;

@end
