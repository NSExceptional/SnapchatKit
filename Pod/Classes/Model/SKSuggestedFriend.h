//
//  SKSuggestedFriend.h
//  Pods
//
//  Created by Tanner on 12/23/15.
//
//

#import "SKThing.h"

@interface SKSuggestedFriend : SKThing

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) BOOL isHidden;
@property (nonatomic, readonly) BOOL isNewSnapchatter;
/// ie, "new_contact"
@property (nonatomic, readonly) NSString *suggestReason;
/// ie, "New Contact"
@property (nonatomic, readonly) NSString *suggestReasonDisplay;

@end
