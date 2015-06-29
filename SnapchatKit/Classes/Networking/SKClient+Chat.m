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
#import "NSArray+SnapchatKit.h"
#import "NSDictionary+SnapchatKit.h"

@implementation SKClient (Chat)

- (void)sendTyping:(NSString *)recipientString {
    NSParameterAssert(recipientString);
    NSDictionary *query = @{@"recipient_usernames": recipientString,
                            @"username": self.currentSession.username};
    
    [SKRequest postTo:kepTyping query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleError:error data:data response:response completion:^(id object, NSError *error) {
            if (kVerboseLog && error)
                SKLog(@"Failed to send typing notification(s): %@", recipientString);
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

- (void)markRead:(SKConversation *)conversation completion:(ErrorBlock)completion {
    NSParameterAssert(conversation);
    NSDictionary *viewed = @{@"eventName": @"CHAT_TEXT_VIEWED",
                             @"params": @{@"id":conversation.identifier},
                             @"ts": @([[NSString timestamp] integerValue]/1000)};
    NSArray *events = @[viewed];
    [self sendEvents:events data:nil completion:completion];
}

- (void)conversationAuth:(NSString *)user completion:(DictionaryBlock)completion {
    NSParameterAssert(user); NSParameterAssert(completion);
    NSString *cid = [NSString SCIdentifierWith:self.username and:user];
    [self postTo:kepConvoAuth query:@{@"username": self.username, @"conversation_id": cid} callback:^(NSDictionary *json, NSError *error) {
        json = json[@"messaging_auth"];
        if ((json[@"mac"] && json[@"payload"]) || error)
            completion(json, error);
        else if (!error)
            completion(nil, [SKRequest errorWithMessage:@"Unknown error" code:1]);
    }];
}

- (void)conversationWithUser:(NSString *)user completion:(ResponseBlock)completion {
    NSParameterAssert(user); NSParameterAssert(completion);
    [self conversationsWithUsers:@[user] completion:^(NSArray *conversations, NSArray *failed, NSError *error) {
        if (!error && failed.count == 0)
            completion(conversations[0], nil);
        else if (error) {
            completion(nil, error);
        } else {
            completion(nil, [SKRequest errorWithMessage:[NSString stringWithFormat:@"Failed to get conversation for: %@", user] code:1]);
        }
    }];
}

- (void)conversationsWithUsers:(NSArray *)users completion:(void (^)(NSArray *conversations, NSArray *failed, NSError *error))completion {
    NSParameterAssert(users.count > 0); NSParameterAssert(completion);
    
    NSMutableArray *failed = [NSMutableArray array];
    NSMutableArray *messages = [NSMutableArray array];
    
    // Get all up to date necessary info
    for (NSString *user in users) {
        [self conversationAuth:user completion:^(NSDictionary *auth, NSError *error) {
            if (!error) {
                NSString *identifier = SKUniqueIdentifier();
                
                NSMutableDictionary *header = [NSMutableDictionary dictionaryWithDictionary:@{@"auth": auth,
                                                                                              @"to": @[user],
                                                                                              @"conv_id": [NSString SCIdentifierWith:self.username and:user],
                                                                                              @"from": self.username,
                                                                                              @"conn_sequence_number": @0}];
                NSDictionary *first  = @{@"presences": @{self.username: @YES, user: @NO},
                                         @"receiving_video": @NO,
                                         @"supports_here": @YES,
                                         @"header": header,
                                         @"retried": @NO,
                                         @"id": identifier,
                                         @"type": @"presence"};
                header[@"conv_id"]   = [NSString SCIdentifierWith:user and:self.username];
                NSDictionary *second = @{@"presences": @{self.username: @YES, user: @NO},
                                         @"receiving_video": @NO,
                                         @"supports_here": @YES,
                                         @"header": header,
                                         @"retried": @NO,
                                         @"id": identifier,
                                         @"type": @"presence"};
                
                [messages addObject:first];
                [messages addObject:second];
            } else {
                [failed addObject:user];
            }
            
            // Finally make call when all converstaion info has been retrieved
            if (messages.count/2 + failed.count == users.count) {
                NSDictionary *query = @{@"auth_token": self.authToken,
                                        @"messages": [messages JSONString],
                                        @"username": self.username};
                [self postTo:kepConvoPostMessages query:query callback:^(NSDictionary *json, NSError *error2) {
                    if (!error2) {
                        NSArray *jsonConvos = json[@"conversations"];
                        NSMutableArray *conversations = [NSMutableArray array];
                        for (NSDictionary *convo in jsonConvos)
                            [conversations addObject:[[SKConversation alloc] initWithDictionary:convo]];
                        
                        completion(conversations, failed, nil);
                    } else {
                        completion(nil, users, error2);
                    }
                }];
            }
        }];
    }
}

- (void)clearConversationWithIdentifier:(NSString *)identifier completion:(BooleanBlock)completion {
    NSParameterAssert(identifier);
    [self postTo:kepConvoClear query:@{@"conversation_id": identifier, @"username": self.username} callback:^(NSDictionary *json, NSError *error) {
        if (completion)
            completion(!json && !error, error);
    }];
}

- (void)clearFeed:(BooleanBlock)completion {
    [self postTo:kepClearFeed query:@{@"username": self.username} callback:^(NSDictionary *json, NSError *error) {
        if (completion)
            completion(!json && !error, error);
    }];
}

- (void)sendMessage:(NSString *)message to:(NSString *)username completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    [self sendMessage:message toEach:@[username] completion:^(NSArray *conversations, NSArray *failed, NSError *error) {
        if (!error && failed.count == 0) {
            completion(conversations[0], nil);
        } else if (error) {
            completion(nil, error);
        } else {
            completion(nil, [SKRequest errorWithMessage:@"Failed to get conversation for user" code:1]);
        }
    }];
}

- (void)sendMessage:(NSString *)message toEach:(NSArray *)recipients completion:(void (^)(NSArray *conversations, NSArray *failed, NSError *error))completion {
    NSParameterAssert(message); NSParameterAssert(recipients.count > 0);
    
    NSMutableArray *failed = [NSMutableArray array];
    NSMutableArray *messages = [NSMutableArray array];
    
    [self conversationsWithUsers:recipients completion:^(NSArray *convos, NSArray *failedConvos, NSError *error) {
        if (!error) {
            [failed addObjectsFromArray:failedConvos];
            
            // Existing conversations
            for (SKConversation *convo in convos) {
                NSUInteger sequenceNum = [convo.state[@"conversation_state"][@"user_sequences"][self.username] integerValue];
                NSString *recipient = [convo.participants[0] isEqualToString:self.username] ? convo.participants[1] : convo.participants[0];
                NSDictionary *newMessage = @{@"body": @{@"type": @"text", @"text": message},
                                             @"chat_message_id": SKUniqueIdentifier(),
                                             @"seq_num": @(sequenceNum+1),
                                             @"timestamp": [NSString timestamp],
                                             @"retried": @NO,
                                             @"id": SKUniqueIdentifier(),
                                             @"type": @"chat_message",
                                             @"header": @{@"auth": convo.messagingAuth,
                                                          @"to": @[recipient],
                                                          @"from": self.username,
                                                          @"conn_sequ_num": @1,
                                                          @"conv_id": convo.identifier}};
                [messages addObject:newMessage];
            }
            
            NSDictionary *query = @{@"auth_token": self.authToken,
                                    @"messages": [messages JSONString],
                                    @"username": self.username};
            [self postTo:kepConvoPostMessages query:query callback:^(NSDictionary *json, NSError *error2) {
                if (!error2) {
                    NSArray *convoJsons = json[@"conversations"];
                    NSMutableArray *conversations = [NSMutableArray array];
                    for (NSDictionary *dict in convoJsons)
                        [conversations addObject:[[SKConversation alloc] initWithDictionary:dict]];
                    completion(conversations, failed, nil);
                } else {
                    completion(nil, recipients, error2);
                }
            }];
        }
    }];
}

#pragma mark Loading old data

- (void)loadConversationsAfter:(SKConversation *)conversation completion:(ArrayBlock)completion {
    NSParameterAssert(conversation); NSParameterAssert(completion);
    if (!conversation.pagination.length) {
        completion(@[], nil);
        return;
    }
    
    NSDictionary *query = @{@"username": self.username,
                            @"checksum": [self.username MD5Hash],
                            @"offset": conversation.pagination};
    [self postTo:kepConversations query:query callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            // Parse all returned conversations
            NSArray *convoJson = json[@"conversations_response"];
            NSMutableArray *conversations = [NSMutableArray array];
            for (NSDictionary *dict in convoJson)
                [conversations addObject:[[SKConversation alloc] initWithDictionary:dict]];
            
            [self.currentSession.conversations addObjectsFromArray:conversations];
            completion(conversations, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)allConversations:(ArrayBlock)completion {
    NSParameterAssert(completion);
    
    [self updateSession:^(NSError *error) {
        if (!error) {
            __block SKConversation *last  = self.currentSession.conversations.lastObject;
            NSMutableArray *conversations = [NSMutableArray array];
            
            // Recursive block to load all pages of conversations
            __block void (^nextPage)(SKConversation *loadAfter) = ^(SKConversation *loadAfter) {
                [self loadConversationsAfter:loadAfter completion:^(NSArray *collection, NSError *error) {
                    if (!error) {
                        if (collection.count > 0) {
                            [conversations addObjectsFromArray:collection];
                            last = conversations.lastObject;
                            nextPage(last);
                        } else {
                            nextPage = nil;
                            [self.currentSession.conversations addObjectsFromArray:conversations];
                            completion(conversations, nil);
                        }
                    } else {
                        completion(conversations, error);
                    }
                }];
            };
            nextPage(last);
            
        } else {
            completion(nil, error);
        }
    }];
}

- (void)loadMessagesAfterPagination:(SKThing<SKPagination> *)messageOrTransaction completion:(ResponseBlock)completion {
    NSParameterAssert(messageOrTransaction && ![messageOrTransaction isKindOfClass:[SKConversation class]]); NSParameterAssert(completion);
    // Must have conversation id
    if (!messageOrTransaction.conversationIdentifier)
        [NSException raise:NSInternalInconsistencyException format:@"SKPagination of type %@ with nil conversationIdentifier:\n%@", NSStringFromClass(messageOrTransaction.class), messageOrTransaction];
    if (!messageOrTransaction.pagination.length) {
        completion(nil, nil);
        return;
    }
    
    NSDictionary *query = @{@"username": self.username,
                            @"conversation_id": messageOrTransaction.conversationIdentifier,
                            @"offset": messageOrTransaction.pagination};
    [self postTo:kepConversation query:query callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            // Parse returned conversation
            SKConversation *conversation = [[SKConversation alloc] initWithDictionary:json[@"conversation"]];
            completion(conversation, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)fullConversation:(SKConversation *)conversation completion:(ErrorBlock)completion {
    NSParameterAssert(conversation); NSParameterAssert(completion);
    
    __block SKThing<SKPagination> *last = conversation.messages.lastObject;
    
    // Recursive block to load all pages of conversations
    __block void (^nextPage)(SKThing<SKPagination> *loadAfter) = ^(SKThing<SKPagination> *loadAfter) {
        [self loadMessagesAfterPagination:loadAfter completion:^(SKConversation *convo, NSError *error) {
            if (!error && convo) {
                // Append messages
                last = convo.messages.lastObject;
                [conversation addMessagesFromConversation:convo];
                // Continue
                nextPage(last);
            } else if (!convo) {
                // No more messages could be loaded, done
                nextPage = nil;
                completion(nil);
            } else if (error) {
                // Error loading messages
                completion(error);
            }
        }];
    };
    nextPage(last);
}

@end
