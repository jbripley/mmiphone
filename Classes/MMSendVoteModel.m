//
//  MMSendVoteModel.m
//  mmiphone
//
//  Created by Joakim Bodin on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MMSendVoteModel.h"

#import "MMUser.h"

#import "YAJL.h"

static NSString* kMMVoteFormat = @"%@/vote";

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMSendVoteModel

@synthesize trackUri = _trackUri;

- (id)initWithTrackUri:(NSString*)trackUri {
  if (self = [super init]) {
    self.trackUri = trackUri;
  }
  
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  TT_RELEASE_SAFELY(_trackUri);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  if (!self.isLoading) {
    NSString* serverURL = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"serverURL_preference"];
    NSString* url = [NSString stringWithFormat:kMMVoteFormat, serverURL];
    
    TTURLRequest* request = [TTURLRequest requestWithURL:url delegate: self];
    request.httpMethod = @"POST";
    request.cachePolicy = cachePolicy;
    request.response = [[[TTURLDataResponse alloc] init] autorelease];
    
    NSMutableDictionary* voteParams = [[NSMutableDictionary alloc] init];
    [voteParams setObject:self.trackUri forKey:@"track"];
    [voteParams setObject:[MMUser userId] forKey:@"user"];
    NSString* voteJSON = [voteParams yajl_JSONString];
    TT_RELEASE_SAFELY(voteParams);
    
    request.httpBody = [voteJSON dataUsingEncoding:NSUTF8StringEncoding];
    TTDINFO(@"Send vote request URL: %@", [request URL]);
    
    [request send];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  [super requestDidFinishLoad:request];
}

@end
