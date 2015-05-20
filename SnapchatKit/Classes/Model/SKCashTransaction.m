//
//  SKCashTransaction.m
//  SnapchatKit
//
//  Created by Tanner on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKCashTransaction.h"

@implementation SKCashTransaction

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    
    if (self) {
        _status       = [json[@"status"] integerValue];
        _amount       = [json[@"amount"] integerValue];
        _currencyCode = json[@"currency_code"];
        _invisible    = [json[@"invisible"] boolValue];
        _lastUpdated  = [NSDate dateWithTimeIntervalSince1970:[json[@"last_updated_at"] doubleValue]/1000];
        _message      = json[@"message"];
        _rain         = [json[@"rain"] boolValue];
        
        _identifier             = json[@"transaction_id"];
        _conversationIdentifier = json[@"conversation_id"];
        _created                = [NSDate dateWithTimeIntervalSince1970:[json[@"created_at"] doubleValue]/1000];
        
        _recipient            = json[@"recipient_username"];
        _recipientIdentifier  = json[@"recipient_id"];
        _recipientSaveVersion = [json[@"recipient_save_version"] integerValue];
        _recipientSaved       = [json[@"recipient_saved"] boolValue];
        _recipientViewed      = [json[@"recipient_viewed"] boolValue];

        _sender               = json[@"sender_username"];
        _senderIdentifier     = json[@"sender_id"];
        _senderSaveVersion    = [json[@"sender_save_version"] integerValue];
        _senderSaved          = [json[@"sender_saved"] boolValue];
        _senderViewed         = [json[@"sender_viewed"] boolValue];
    }
    
    [self.knownJSONKeys addObjectsFromArray:@[@"status", @"amount", @"currency_code", @"invisible",
                                              @"last_updated_at", @"message", @"rain", @"transaction_id",
                                              @"conversation_id", @"created_at", @"recipient_username",
                                              @"recipient_id", @"recipient_save_version", @"recipient_saved",
                                              @"recipient_viewed", @"sender_username", @"sender_id",
                                              @"sender_save_version", @"sender_saved", @"sender_viewed"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ sender=%@, recipient=%@, message=%@>",
            NSStringFromClass(self.class), self.sender, self.recipient, self.message];
}

@end