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

#import "MMStatusModel.h"

#import "MMStatus.h"
#import "MMPlaylistTrack.h"

#import "MMUser.h"

#import <extThree20JSON/extThree20JSON.h>

static NSString* kMMStatusFormat = @"%@/status?user=%@";
static NSString* kMMPlaylistFormat = @"%@/playlist";

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMStatusModel

@synthesize status = _status;
@synthesize tracks = _tracks;

@synthesize statusRequest = _statusRequest;
@synthesize playlistRequest = _playlistRequest;

@synthesize statusRequestFinished = _statusRequestFinished;
@synthesize playlistRequestFinished = _playlistRequestFinished;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  TT_RELEASE_SAFELY(_status);
  TT_RELEASE_SAFELY(_tracks);
  
  TT_RELEASE_SAFELY(_statusRequest);
  TT_RELEASE_SAFELY(_playlistRequest);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  if (!self.isLoading) {
    NSString* serverURL = [[NSUserDefaults standardUserDefaults]
                              stringForKey:@"serverURL_preference"];
    
    NSString* statusUrl = [NSString stringWithFormat:
                           kMMStatusFormat, serverURL, [MMUser userId]];
    self.statusRequest = [self _sendStatusRequest:statusUrl];
    self.statusRequestFinished = NO;
    
    NSString* playlistUrl = [NSString stringWithFormat:kMMPlaylistFormat, serverURL];
    self.playlistRequest = [self _sendPlaylistRequest:playlistUrl];
    self.playlistRequestFinished = NO;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  if (request == self.statusRequest) {
    [self _handleStatusResponse:request];
  }
  else if (request == self.playlistRequest) {
    [self _handlePlaylistResponse:request];
  }
  
  if (self.statusRequestFinished && self.playlistRequestFinished) {
    [super requestDidFinishLoad:request];
    if (request == self.playlistRequest) {
      [super requestDidFinishLoad:self.statusRequest];
    }
    else {
      [super requestDidFinishLoad:self.playlistRequest];
    }

  }
}

- (TTURLRequest*)_sendStatusRequest:(NSString*)statusUrl {
  TTURLRequest* statusRequest = [TTURLRequest
                                 requestWithURL: statusUrl
                                 delegate: self];
  
  statusRequest.cacheExpirationAge = 0;
  
  TTURLJSONResponse* statusResponse = [[TTURLJSONResponse alloc] init];
  statusRequest.response = statusResponse;
  TT_RELEASE_SAFELY(statusResponse);
  
  [statusRequest send];
  return statusRequest;
}

- (void)_handleStatusResponse:(TTURLRequest*)request {
  // {"playtime":0,"timeUntilVote":5000,"numVotes":0}
  
  TTURLJSONResponse* response = request.response;
  TTDASSERT([response.rootObject isKindOfClass:[NSDictionary class]]);
  
  NSDictionary* statusDict = response.rootObject;
  TTDINFO(@"Returned status: %@", statusDict);
  TTDASSERT([[statusDict objectForKey:@"playtime"] isKindOfClass:[NSNumber class]]);
  TTDASSERT([[statusDict objectForKey:@"timeUntilVote"] isKindOfClass:[NSNumber class]]);
  TTDASSERT([[statusDict objectForKey:@"numVotes"] isKindOfClass:[NSNumber class]]);
  
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
  [dateFormatter setDateFormat:@"s"];
  
  TT_RELEASE_SAFELY(_status);
  
  MMStatus* status = [[MMStatus alloc] init];
  
  status.playtime = [NSDate dateWithTimeIntervalSince1970:
                     ([[statusDict objectForKey:@"playtime"] doubleValue]/1000.0)];
  
  status.timeUntilVote = [NSDate dateWithTimeIntervalSince1970:
                          ([[statusDict objectForKey:@"timeUntilVote"] doubleValue]/1000.0)];
  
  status.numVotes = [NSNumber numberWithInt:
                 [[statusDict objectForKey:@"numVotes"] intValue]];
  
  status.hasVoted = [[statusDict objectForKey:@"numVotes"] boolValue];
  
  _status = status;
  
  TT_RELEASE_SAFELY(dateFormatter);
  self.statusRequestFinished = YES;
}

- (TTURLRequest*)_sendPlaylistRequest:(NSString*)playlistUrl {
  TTURLRequest* playlistRequest = [TTURLRequest
                                   requestWithURL: playlistUrl
                                   delegate: self];

  playlistRequest.cacheExpirationAge = 0;

  TTURLJSONResponse* playlistResponse = [[TTURLJSONResponse alloc] init];
  playlistRequest.response = playlistResponse;
  TT_RELEASE_SAFELY(playlistResponse);

  [playlistRequest send];
  return playlistRequest;
}

- (void)_handlePlaylistResponse:(TTURLRequest*)request {
  /* [ {
         "album" : "Command",
         "artist" : "Client",
         "id" : "a1c26163a5f94594944d539f28f5fa54",
         "length" : 187699,
         "title" : "Lullaby",
         "uri" : "spotify:track:4VeAZTNosu8MD9IwlxjKrW"
       } ] */
  
  TTURLJSONResponse* response = request.response;
  TTDASSERT([response.rootObject isKindOfClass:[NSArray class]]);
  
  NSArray* playlist = response.rootObject;
  TTDINFO("playlist: %@", playlist);
  
  TT_RELEASE_SAFELY(_tracks);
  NSMutableArray* tracks = [[NSMutableArray alloc] initWithCapacity:[playlist count]];
  
  for (NSDictionary* playlistTrack in playlist) {
    MMPlaylistTrack* track = [[MMPlaylistTrack alloc] init];
    
    track.artist = [playlistTrack objectForKey:@"artist"];
    track.album = [playlistTrack objectForKey:@"album"];
    track.title = [playlistTrack objectForKey:@"title"];
    track.uri = [playlistTrack objectForKey:@"uri"];
    track.voterId = [playlistTrack objectForKey:@"id"];
    track.length = [NSNumber numberWithInt:
                    [[playlistTrack objectForKey:@"length"] intValue]];
    
    [tracks addObject:track];
    TT_RELEASE_SAFELY(track);
  }
  _tracks = tracks;
  
  self.playlistRequestFinished = YES;
}

@end
