//
//  MMUser.m
//  mmiphone
//
//  Created by Joakim Bodin on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MMUser.h"

#import "Three20Core/NSStringAdditions.h"

@implementation MMUser

+ (NSString*)userId {
  return [[[UIDevice currentDevice] uniqueIdentifier] md5Hash];
}

@end
