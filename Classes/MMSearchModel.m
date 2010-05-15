//
//  MMSearchModel.m
//  mmiphone
//
//  Created by Joakim Bodin on 2010-05-09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MMSearchModel.h"

#import "MMTrack.h"

#import "MMXmlTrackParser.h"

#import <extThree20XML/extThree20XML.h>

static NSString* kSpotifyTrackSearchFormat = @"http://ws.spotify.com/search/1/track?q=%@";

@implementation MMSearchModel

@synthesize tracks = _tracks;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegates = nil;
    _tracks = nil;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  [_request cancel];
  
  TT_RELEASE_SAFELY(_delegates);
  TT_RELEASE_SAFELY(_tracks);
  TT_RELEASE_SAFELY(_request);
  
  [super dealloc];
}

- (void)search:(NSString*)text {
  [self cancel];
  
  if (!TTIsStringWithAnyText(text)) {
    TT_RELEASE_SAFELY(_tracks);
    [_delegates perform:@selector(modelDidChange:) withObject:self];
    return;
  }
  
  [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
  
  NSString* url = [NSString stringWithFormat:kSpotifyTrackSearchFormat, text];
  TTURLRequest* request = [TTURLRequest requestWithURL:url delegate:self];
  request.cachePolicy = TTURLRequestCachePolicyNetwork;
  
  TTURLXMLResponse* response = [[TTURLXMLResponse alloc] init];
  response.isRssFeed = YES;
  request.response = response;
  TT_RELEASE_SAFELY(response);
  
  [request send];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidStartLoad:(TTURLRequest*)request {
  [_request release];
  _request = [request retain];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  [super requestDidFinishLoad:request];
  
  TTURLXMLResponse* response = request.response;
  TTDASSERT([response.rootObject isKindOfClass:[NSDictionary class]]);
  
  NSDictionary* tracksDict = response.rootObject;
  TTDINFO(@"Number of search results found: %d", [[tracksDict objectForKey:@"track"] count]);
  
  TT_RELEASE_SAFELY(_tracks);
  NSMutableArray* tracks = [[NSMutableArray alloc] init];
  
  NSString* countryCode = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"countryCode_preference"];
  for(NSDictionary* trackDict in [tracksDict objectForKey:@"track"]) {
    MMTrack* track = [MMXmlTrackParser parseTrack:trackDict forCountry:countryCode];
    
    if (track != nil) {
      [tracks addObject:track];
    }
  }
  _tracks = tracks;
  
  TT_RELEASE_SAFELY(_request);
  [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (NSMutableArray*)delegates {
  if (!_delegates) {
    _delegates = TTCreateNonRetainingArray();
  }
  return _delegates;
}

- (BOOL)isLoaded {
  BOOL isLoaded = !(_tracks == nil);
  return isLoaded;
}

- (BOOL)isLoading {
  return !!_request;
}

- (BOOL)isEmpty {
  return !_tracks.count;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}

- (void)cancel {
  [_request cancel];
  [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}

@end
