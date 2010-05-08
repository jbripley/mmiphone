//
//  MMStatusModel.m
//  mmiphone
//
//  Created by Joakim Bodin on 2010-05-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MMStatusModel.h"

#import "MMStatus.h"
#import "MMTrack.h"

#import <extThree20JSON/extThree20JSON.h>

static NSString* kMMStatusFormat = @"http://%@/status";
static NSString* kMMPlaylistFormat = @"http://%@/playlist";

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
    NSString* server = @"localhost:8080";
    
    NSString* statusUrl = [NSString stringWithFormat:kMMStatusFormat, server];
    self.statusRequest = [self _sendStatusRequest:statusUrl];
    self.statusRequestFinished = NO;
    
    NSString* playlistUrl = [NSString stringWithFormat:kMMPlaylistFormat, server];
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
  
  status.playtime = [[NSDate date] addTimeInterval:
                   ([[statusDict objectForKey:@"playtime"] doubleValue]/1000)];
  
  status.timeUntilVote = [[NSDate date] addTimeInterval:
                       ([[statusDict objectForKey:@"timeUntilVote"] intValue]/1000)];
  
  status.numVotes = [NSNumber numberWithInt:
                 [[statusDict objectForKey:@"numVotes"] intValue]];
  
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
    MMTrack* track = [[MMTrack alloc] init];
    
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
