//
//  MMTrack.m
//  mmiphone
//
//  Created by Joakim Bodin on 2010-05-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MMTrack.h"


@implementation MMTrack

@synthesize album   = _album;
@synthesize artist  = _artist;
@synthesize title   = _title;
@synthesize voterId = _voterId;
@synthesize uri     = _uri;
@synthesize length  = _length;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  TT_RELEASE_SAFELY(_album);
  TT_RELEASE_SAFELY(_artist);
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_voterId);
  TT_RELEASE_SAFELY(_uri);
  TT_RELEASE_SAFELY(_length);
  
  [super dealloc];
}

@end
