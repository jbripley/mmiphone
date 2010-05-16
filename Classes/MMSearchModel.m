//
// Copyright 2010 Joakim Bodin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MMSearchModel.h"

#import "MMTrack.h"

#import "MMXmlTrackParser.h"

#import <extThree20XML/extThree20XML.h>

static NSString* kSpotifyTrackSearchScheme = @"http";
static NSString* kSpotifyTrackSearchHost = @"ws.spotify.com";
static NSString* kSpotifyTrackSearchPathFormat = @"/search/1/track.xml?q=%@";

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
  
  NSURL* url = [[NSURL alloc] initWithScheme:kSpotifyTrackSearchScheme
                host:kSpotifyTrackSearchHost
                path:[NSString stringWithFormat:kSpotifyTrackSearchPathFormat, text]];
  NSString* urlString = [url absoluteString];
  TT_RELEASE_SAFELY(url);
  
  TTDINFO(@"Sending search to URL: %@", urlString);
  TTURLRequest* request = [TTURLRequest requestWithURL:urlString delegate:self];
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
  [super requestDidFinishLoad:request];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_request);
  
  [_delegates perform:@selector(model:didFailLoadWithError:) withObject:self withObject:error];
  [super request:request didFailLoadWithError:error];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_SAFELY(_request);
  
  [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
  [super requestDidCancelLoad:request];
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
