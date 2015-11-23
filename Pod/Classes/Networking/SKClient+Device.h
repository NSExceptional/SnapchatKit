//
//  SKClient+Device.h
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient.h"

@interface SKClient (Device)

/** Sends the "app did open" event to Snapchat.
 @param completion Takes an error, if any. */
- (void)sendDidOpenAppEvent:(ErrorBlock)completion;
/** Sends the "app did close" event to Snapchat.
 @param completion Takes an error, if any. */
- (void)sendDidCloseAppEvent:(ErrorBlock)completion;

@end
