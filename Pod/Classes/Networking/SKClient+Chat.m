//
//  SKClient+Chat.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Chat.h"
#import "SKRequest.h"
#import "SKConversation.h"
#import "SKConversationState.h"
#import "SKNewConversation.h"
#import "SKMessage.h"
#import "SKBlob.h"

#import "SnapchatKit-Constants.h"


@implementation SKClient (Chat)

- (void)sendTyping:(NSString *)recipientString {
    NSParameterAssert(recipientString);
    NSDictionary *params = @{@"recipient_usernames": recipientString,
                             @"username": self.currentSession.username};
    
    [self postWith:params to:SKEPChat.typing callback:^(TBResponseParser *parser) {
        if (kVerboseLog && parser.error)
            SKLog(@"Failed to send typing notification(s): %@, %@", recipientString, parser.error);
    }];
}

- (void)sendTypingToUsers:(NSArray *)recipients {
    NSParameterAssert(recipients);
    if (recipients.count == 0) return;
    
    [self sendTyping:recipients.recipientsString];
}

- (void)sendTypingToUser:(NSString *)user {
    user = [NSString stringWithFormat:@"[\"%@\"]", user];
    [self sendTyping:user];
}

- (void)markRead:(SKConversation *)conversation completion:(ErrorBlock)completion {
    NSParameterAssert(conversation);
    NSDictionary *viewed = @{@"eventName": @"CHAT_TEXT_VIEWED",
                             @"params": @{@"id":conversation.identifier},
                             @"ts": @([[NSString timestamp] integerValue]/1000)};
    [self sendEvents:@[viewed] data:nil completion:completion];
}

- (void)conversationAuth:(NSString *)user completion:(DictionaryBlock)completion {
    NSParameterAssert(user); NSParameterAssert(completion);
    NSString *cid = [NSString SCIdentifierWith:self.username and:user];
    NSDictionary *params = @{@"username": self.username, @"conversation_id": cid};
    
    [self postWith:params to:SKEPChat.authToken callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            NSDictionary *json = parser.JSON[@"messaging_auth"];
            if (json[@"mac"] && json[@"payload"])
                completion(json, nil);
            else {
                NSString *message = @"Could not get conversation auth. Are you friends?";
                completion(nil, [TBResponseParser error:message domain:@"SnapchatKit" code:parser.response.statusCode]);
            }
        } else {
            completion(nil, parser.error);
        }
    }];
}

- (void)conversationWithUser:(NSString *)user completion:(ResponseBlock)completion {
    NSParameterAssert(user); NSParameterAssert(completion);
    [self conversationsWithUsers:@[user] completion:^(NSArray *conversations, NSArray *failed, NSError *error) {
        if (!error && failed.count == 0) {
            completion(conversations[0], nil);
        } else if (error) {
            completion(nil, error);
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
                NSDictionary *params = @{@"auth_token": self.authToken,
                                         @"messages": messages.JSONString,
                                         @"username": self.username};
                [self postWith:params to:SKEPChat.sendMessage callback:^(TBResponseParser *parser) {
                    if (!parser.error) {
                        NSArray *jsonConvos = parser.JSON[@"conversations"];
                        NSMutableArray *conversations = [NSMutableArray array];
                        
                        if (jsonConvos.count) {
                            for (NSDictionary *convo in jsonConvos)
                                [conversations addObject:[[SKConversation alloc] initWithDictionary:convo]];
                        } else {
                            // Tricky because if no conversations were returned
                            // and we're trying to send to multiple users, I
                            // fear this last POST might only return the auth
                            // data for one user... idk what else to do here
                            [conversations addObject:[SKNewConversation newConvoWithAuth:auth withSender:self.username otherUser:failed.firstObject ?: users[0]]];
                        }
                        
                        
                        completion(conversations, failed, nil);
                    } else {
                        completion(nil, users, parser.error);
                    }
                }];
            }
        }];
    }
}

- (void)clearConversationWithIdentifier:(NSString *)identifier completion:(ErrorBlock)completion {
    NSParameterAssert(identifier);
    NSDictionary *params = @{@"conversation_id": identifier, @"username": self.username};
    [self postWith:params to:SKEPChat.clear callback:^(TBResponseParser *parser) {
        TBRunBlockP(completion, parser.error);
    }];
}

- (void)clearFeed:(ErrorBlock)completion {
    [self postWith:@{@"username": self.username} to:SKEPChat.clearFeed callback:^(TBResponseParser *parser) {
        TBRunBlockP(completion, parser.error);
    }];
}

- (void)checkCashEligibility:(NSString *)username completion:(void (^)(BOOL, NSError *))completion {
    NSParameterAssert(username); NSParameterAssert(completion);
    NSDictionary *params = @{@"recipient": username, @"username": self.username};
    [self postWith:params to:SKEPCash.checkRecipientEligibility callback:^(TBResponseParser *parser) {
        // Other possible values: SERVICE_NOT_AVAILABLE_TO_RECIPIENT
        completion([parser.JSON[@"status"] isEqualToString:@"OK"], parser.error);
    }];
}

- (void)sendMessage:(NSString *)message to:(NSString *)username completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    [self sendMessage:message toEach:@[username] completion:^(NSArray *conversations, NSArray *failed, NSError *error) {
        if (!error && failed.count == 0) {
            NSParameterAssert(conversations.count > 0);
            completion(conversations[0], nil);
        } else {
            NSString *message = @"Failed to get conversation for user";
            completion(nil, error ?: [TBResponseParser error:message domain:@"SnapchatKit" code:0]);
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
            NSParameterAssert(convos.count > 0);
            
            // Existing conversations
            for (SKConversation *convo in convos) {
                NSUInteger sequenceNum = convo.state.recipientSentCount;
                NSString *recipient = convo.recipient;
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
            
            NSDictionary *params = @{@"auth_token": self.authToken,
                                     @"messages": [messages JSONString],
                                     @"username": self.username};
            [self postWith:params to:SKEPChat.sendMessage callback:^(TBResponseParser *parser) {
                if (!parser.error) {
                    NSArray *convoJsons = parser.JSON[@"conversations"];
                    NSMutableArray *conversations = [NSMutableArray array];
                    for (NSDictionary *dict in convoJsons)
                        [conversations addObject:[[SKConversation alloc] initWithDictionary:dict]];
                    completion(conversations, failed, nil);
                } else {
                    completion(nil, recipients, parser.error);
                }
            }];
        } else {
            completion(@[], failedConvos, error);
        }
    }];
}

- (void)downloadMedia:(SKMessage *)mediaMessage completion:(ResponseBlock)completion {
    NSParameterAssert(mediaMessage); NSParameterAssert(completion);
    NSDictionary *params = @{@"conversation_id": mediaMessage.conversationIdentifier,
                             @"id": mediaMessage.mediaIdentifier,
                             @"username": self.username};
    [self postWith:params to:SKEPChat.media callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            if (parser.data.length) {
                NSData *data = [parser.data decryptStoryWithKey:mediaMessage.mediaKey iv:mediaMessage.mediaIV];
                completion([SKBlob blobWithData:data], nil);
            } else {
                completion(nil, [SKRequest errorWithMessage:@"Chat media response was 0 bytes with code 200" code:200]);
                SKLog(@"Chat media response was 0 bytes with code 200");
            }
        } else {
            completion(nil, parser.error);
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
    
    NSDictionary *params = @{@"username": self.username,
                             @"checksum": self.username.MD5Hash,
                             @"offset": conversation.pagination};
    [self postWith:params to:SKEPChat.conversations callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            // Parse all returned conversations
            NSArray *convoJson = parser.JSON[@"conversations_response"];
            NSMutableArray *conversations = [NSMutableArray array];
            for (NSDictionary *dict in convoJson)
                [conversations addObject:[[SKConversation alloc] initWithDictionary:dict]];
            
            [self.currentSession.conversations addObjectsFromArray:conversations];
            completion(conversations, nil);
        } else {
            completion(nil, parser.error);
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
    if (!messageOrTransaction.conversationIdentifier) {
        NSString *format = @"SKPagination of type %@ with nil conversationIdentifier:\n%@";
        [NSException raise:NSInternalInconsistencyException format:format, NSStringFromClass(messageOrTransaction.class), messageOrTransaction];
    }
    if (!messageOrTransaction.pagination.length) {
        completion(nil, nil);
        return;
    }
    
    NSDictionary *params = @{@"username": self.username,
                             @"conversation_id": messageOrTransaction.conversationIdentifier,
                             @"offset": messageOrTransaction.pagination};
    [self postWith:params to:SKEPChat.conversation callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            // Parse returned conversation
            SKConversation *conversation = [[SKConversation alloc] initWithDictionary:parser.JSON[@"conversation"]];
            completion(conversation, nil);
        } else {
            completion(nil, parser.error);
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
