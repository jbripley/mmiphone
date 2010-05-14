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

#import "MMVoteModel.h"

#import "MMTrack.h"

#import "MMXmlTrackParser.h"

#import <extThree20XML/extThree20XML.h>

static NSString* kSpotifyTrackLookupFormat = @"http://ws.spotify.com/lookup/1/?uri=%@";

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMVoteModel

@synthesize track = _track;
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
  TT_RELEASE_SAFELY(_track);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  if (!self.isLoading) {
    NSString* url = [NSString stringWithFormat:kSpotifyTrackLookupFormat, _trackUri];
    
    TTURLRequest* request = [TTURLRequest requestWithURL: url delegate: self];
    
    request.cachePolicy = cachePolicy;
    
    TTURLXMLResponse* response = [[TTURLXMLResponse alloc] init];
    response.isRssFeed = YES;
    request.response = response;
    TT_RELEASE_SAFELY(response);
    
    [request send];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLXMLResponse* response = request.response;
  TTDASSERT([response.rootObject isKindOfClass:[NSDictionary class]]);
  
  NSDictionary* trackDict = response.rootObject;
  
  TT_RELEASE_SAFELY(_track);
  MMTrack* track = [MMXmlTrackParser parseTrack:trackDict forCountry:@"SE"];
  if (track != nil) {
    _track = [track retain];
  }
    
  [super requestDidFinishLoad:request];
}

@end
