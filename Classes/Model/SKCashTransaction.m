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
        _pagination = json[@"iter_token"];
        
        // "last_transaction" begins with this, but normal transactions
        // contain "iter_token" and "cash_transaction", so this is the
        // case for normal transactions.
        if (json[@"cash_transaction"])
            json = json[@"cash_transaction"];
        
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
    
    [[self class] addKnownJSONKeys:@[@"status", @"amount", @"currency_code", @"invisible",
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

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKCashTransaction class]])
        return [self isEqualToTransaction:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToTransaction:(SKCashTransaction *)transaction {
    return [self.identifier isEqualToString:transaction.identifier] && self.amount == transaction.amount;
}

- (NSComparisonResult)compare:(SKThing<SKPagination> *)thing {
    if ([thing respondsToSelector:@selector(created)])
        return [self.created compare:thing.created];
    return NSOrderedSame;
}

@end