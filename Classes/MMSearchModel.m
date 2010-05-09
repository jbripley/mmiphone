//
//  MMSearchModel.m
//  mmiphone
//
//  Created by Joakim Bodin on 2010-05-09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MMSearchModel.h"

#import "MMSearchTrack.h"

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
    _isLoading = NO;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  TT_RELEASE_SAFELY(_delegates);
  TT_RELEASE_SAFELY(_tracks);
  
  [super dealloc];
}

- (void)search:(NSString*)text {
  [self cancel];
  
  if (!text.length) {
    _isLoading = NO;
    TT_RELEASE_SAFELY(_tracks);
    [_delegates perform:@selector(modelDidChange:) withObject:self];
    return;
  }
  
  [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
  _isLoading = YES;
  
  NSString* url = [NSString stringWithFormat:kSpotifyTrackSearchFormat, text];
  TTURLRequest* request = [TTURLRequest requestWithURL: url
                           delegate: self];
  
  TTURLXMLResponse* response = [[TTURLXMLResponse alloc] init];
  response.isRssFeed = YES;
  request.response = response;
  TT_RELEASE_SAFELY(response);
  
  [request send];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLXMLResponse* response = request.response;
  TTDASSERT([response.rootObject isKindOfClass:[NSDictionary class]]);
  
  NSDictionary* tracksDict = response.rootObject;
  
  TT_RELEASE_SAFELY(_tracks);
  NSMutableArray* tracks = [[NSMutableArray alloc] init];
  
  for(NSDictionary* trackDict in [tracksDict objectForKey:@"track"]) {
    if (![trackDict isKindOfClass:[NSDictionary class]]) {
      continue;
    }
    
    NSDictionary* artistDict = [trackDict objectForKey:@"artist"];
    if (![artistDict isKindOfClass:[NSDictionary class]]) {
      continue;
    }
    
    NSDictionary* albumDict = [trackDict objectForKey:@"album"];
    if (![albumDict isKindOfClass:[NSDictionary class]]) {
      continue;
    }
    
    MMSearchTrack* track = [[MMSearchTrack alloc] init];
    track.artist = [[artistDict objectForKey:@"name"] objectForKey:@"___Entity_Value___"];
    track.album = [[albumDict objectForKey:@"name"] objectForKey:@"___Entity_Value___"];
    track.title = [[trackDict objectForKey:@"name"] objectForKey:@"___Entity_Value___"];
    track.uri = [trackDict objectForKey:@"href"];
    track.length = [NSNumber numberWithDouble:
                    [[[trackDict objectForKey:@"length"]
                      objectForKey:@"___Entity_Value___"] doubleValue]];
    
    [tracks addObject:track];
    TT_RELEASE_SAFELY(track);
  }
  _tracks = tracks;
  
  //  [_delegates perform:@selector(model:didFailLoadWithError:) withObject:self withObject:error];
  
  _isLoading = NO;
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

- (BOOL)isLoadingMore {
  return NO;
}

- (BOOL)isOutdated {
  return NO;
}

- (BOOL)isLoaded {
  BOOL isLoaded = !(_tracks == nil);
  return isLoaded;
}

- (BOOL)isLoading {
  return _isLoading;
}

- (BOOL)isEmpty {
  BOOL isEmpty = !_tracks.count;
  return isEmpty;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}

- (void)invalidate:(BOOL)erase {
}

- (void)cancel {
  [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}

@end
