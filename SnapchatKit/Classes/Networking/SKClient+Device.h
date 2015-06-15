//
//  SKClient+Device.h
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient.h"

@interface SKClient (Device)

- (void)sendDidOpenAppEvent:(ErrorBlock)completion;
- (void)sendDidCloseAppEvent:(ErrorBlock)completion;

@end
