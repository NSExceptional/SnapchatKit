//
//  SnapchatKit-Constants.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SnapchatKit-Constants.h"

#import "SKClient.h"
#import "SKClient+Account.h"
#import "SKClient+Chat.h"
#import "SKClient+Device.h"
#import "SKClient+Friends.h"
#import "SKClient+Snaps.h"
#import "SKClient+Stories.h"

#import "SKAddedFriend.h"
#import "SKBlob.h"
#import "SKCashTransaction.h"
#import "SKConversation.h"
#import "SKFoundFriend.h"
#import "SKMessage.h"
#import "SKSession.h"
#import "SKSharedStoryDescription.h"
#import "SKSimpleUser.h"
#import "SKSnap.h"
#import "SKSnapOptions.h"
#import "SKSnapResponse.h"
#import "SKStory.h"
#import "SKStoryOptions.h"
#import "SKStoryCollection.h"
#import "SKStoryNote.h"
#import "SKUser.h"
#import "SKUserStory.h"
//#import "SKTestSession.h"



// Mantle macros //

// string to URL transform
#define MTLTransformPropertyURL(property) + (NSValueTransformer *) property##JSONTransformer { \
return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName]; }

// class transform
#define MTLTransformPropertyClass(property, cls) + (NSValueTransformer *) property##JSONTransformer { \
return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ cls class]]; }

// dictionary transform
#define MTLTransformPropertyMap(property, dictionary) + (NSValueTransformer *) property##JSONTransformer { \
return [NSValueTransformer mtl_valueMappingTransformerWithDictionary: dictionary ]; }