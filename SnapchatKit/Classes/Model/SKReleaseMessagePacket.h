//
//  SKReleaseMessagePacket.h
//  Pods
//
//  Created by Tanner on 3/25/16.
//
//

#import "SKConversationMessagePacket.h"


@interface SKReleaseMessagePacket : SKConversationMessagePacket

@property (nonatomic, readonly) NSDictionary<NSString*, NSNumber*> *knownChatSequenceNumbers;
@property (nonatomic, readonly) NSDictionary<NSString*, NSNumber*> *knownRecievedSnapsTimestamps;
@property (nonatomic, readonly) NSString *releaseType;
@property (nonatomic, readonly) NSDate *timestamp;

@end
