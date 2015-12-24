//
//  SKTrophy.h
//  Pods
//
//  Created by Tanner on 12/23/15.
//
//

#import "SKThing.h"
@class SKTrophyStage;


@interface SKTrophy : SKThing

@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) NSString *unicode;
@property (nonatomic, readonly) NSArray<SKTrophyStage *> *stages;

@end



@interface SKTrophyStage : SKThing

/// ie "CURRENT" or "UNACHIEVED"
@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readonly) NSDate   *achievedOn;

@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) NSString *unicode;

@end