//
//  SKSharedStoryDescription.h
//  SnapchatKit-OSX-Demo
//
//  Created by Tanner on 7/17/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

@interface SKSharedStoryDescription : SKThing

/** ie "Campaign 2016 is a collection of Snaps from Snapchatters in Iowa." */
@property (nonatomic, readonly) NSString *friendNote;
/** ie "While you're here, you may submit Snaps to Our Campaign Story. To opt out of this location-based feature, turn off Filters in Settings." */
@property (nonatomic, readonly) NSString *localPostBody;
/** ie "Post Snap to Campaign?" */
@property (nonatomic, readonly) NSString *localPostTitle;
/** ie "Campaign 2016 is a collection of Snaps from Snapchatters in Iowa." */
@property (nonatomic, readonly) NSString *localViewBody;
/** ie "Our Story" */
@property (nonatomic, readonly) NSString *localViewTitle;

@end
