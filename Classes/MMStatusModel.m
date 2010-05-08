//
//  MMStatusModel.m
//  mmiphone
//
//  Created by Joakim Bodin on 2010-05-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MMStatusModel.h"

#import "MMStatus.h"

#import <extThree20JSON/extThree20JSON.h>

static NSString* kMMStatusFormat = @"http://%@/status";

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMStatusModel

@synthesize status = _status;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  TT_RELEASE_SAFELY(_status);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  if (!self.isLoading) {
    NSString* url = [NSString stringWithFormat:kMMStatusFormat, @"192.168.30.26:8080"];
    
    TTURLRequest* request = [TTURLRequest
                             requestWithURL: url
                             delegate: self];
    
    //request.cachePolicy = cachePolicy | TTURLRequestCachePolicyEtag;
    request.cacheExpirationAge = TT_CACHE_EXPIRATION_AGE_NEVER;
    
    TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);
    
    [request send];
  }
}

// Example response {"playtime":0,"timeUntilVote":5000,"numVotes":0}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLJSONResponse* response = request.response;
  TTDASSERT([response.rootObject isKindOfClass:[NSDictionary class]]);
  
  NSDictionary* statusDict = response.rootObject;
  TTDASSERT([[statusDict objectForKey:@"playtime"] isKindOfClass:[NSNumber class]]);
  TTDASSERT([[statusDict objectForKey:@"timeUntilVote"] isKindOfClass:[NSNumber class]]);
  TTDASSERT([[statusDict objectForKey:@"numVotes"] isKindOfClass:[NSNumber class]]);
  
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
  [dateFormatter setDateFormat:@"s"];
  
  TT_RELEASE_SAFELY(_status);
  
  MMStatus* status = [[MMStatus alloc] init];
  
  NSDate* playtime = [dateFormatter dateFromString:
                  [[statusDict objectForKey:@"playtime"] stringValue]];
  status.playtime = playtime;
  
  NSDate* timeUntilVote = [dateFormatter dateFromString:
                        [[statusDict objectForKey:@"timeUntilVote"] stringValue]];
  status.timeUntilVote = timeUntilVote;
  
  status.numVotes = [NSNumber numberWithInt:
                 [[statusDict objectForKey:@"numVotes"] intValue]];
  
  _status = status;
  
  TT_RELEASE_SAFELY(dateFormatter);
  
  [super requestDidFinishLoad:request];
}

@end
