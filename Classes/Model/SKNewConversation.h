//
//  SKNewConversation.h
//  SnapchatKit-iOS-Demo
//
//  Created by Tanner on 7/11/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

/** Used internally. */
@interface SKNewConversation : SKThing

+ (instancetype)newConvoWithAuth:(NSDictionary *)macAndPayload withOtherUser:(NSString *)recipient;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *recipient;

@property (nonatomic, readonly) NSString *mac;
@property (nonatomic, readonly) NSString *payload;
@property (nonatomic, readonly) NSDictionary *messagingAuth;
@property (nonatomic, readonly) NSDictionary *state;

@end
