//
//  SKClient+Chat.m
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Chat.h"
#import "SKRequest.h"
#import "SKConversation.h"

#import "NSString+SnapchatKit.h"

@implementation SKClient (Chat)

- (void)sendTyping:(NSString *)recipientString {
    NSParameterAssert(recipientString);
    NSDictionary *query = @{@"recipient_usernames": recipientString,
                            @"username": self.currentSession.username};
    
    [SKRequest postTo:kepTyping query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleError:error data:data response:response completion:^(id object, NSError *error) {
            if (kVerboseLog && error)
                NSLog(@"Failed to send typing notification(s): %@", recipientString);
        }];
    }];
}

- (void)sendTypingToUsers:(NSArray *)recipients {
    NSParameterAssert(recipients);
    if (recipients.count == 0) return;
    
    NSMutableString *recipientsString = [NSMutableString string];
    [recipientsString appendString:@"["];
    
    for (NSString *username in recipients)
        [recipientsString appendFormat:@"\"%@\",", username];
    
    [recipientsString deleteCharactersInRange:NSMakeRange(recipientsString.length-1, 1)];
    [recipientsString appendString:@"]"];
    
    [self sendTyping:recipientsString];
}

- (void)sendTypingToUser:(NSString *)user {
    user = [NSString stringWithFormat:@"[%@]", user];
    [self sendTyping:user];
}

- (void)markRead:(SKConversation *)conversation completion:(BooleanBlock)completion {
    NSParameterAssert(conversation);
    NSDictionary *viewed = @{@"eventName": @"CHAT_TEXT_VIEWED",
                             @"params": @{@"id":conversation.identifier},
                             @"ts": @([[NSString timestamp] integerValue]/1000)};
    NSArray *events = @[viewed];
    [self sendEvents:events data:nil completion:completion];
}

- (void)conversationAuth:(NSString *)user completion:(StringBlock)completion {
    NSString *cid = [NSString stringWithFormat:@"%@~%@", self.username, user];
    [self postTo:kepConvoAuth query:@{@"username": self.username, @"conversation_id": cid} callback:^(NSDictionary *json, NSError *error) {
        NSLog(@"%@", json);
    }];
}

@end
