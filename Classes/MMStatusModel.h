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

@class MMStatus;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface MMStatusModel : TTURLRequestModel {
  MMStatus* _status;
  NSArray*  _tracks;
  
  TTURLRequest* _statusRequest;
  TTURLRequest* _playlistRequest;
  
  BOOL _statusRequestFinished;
  BOOL _playlistRequestFinished;
}

@property (nonatomic, readonly) MMStatus* status;
@property (nonatomic, readonly) NSArray* tracks;

@property (nonatomic, retain) TTURLRequest* statusRequest;
@property (nonatomic, retain) TTURLRequest* playlistRequest;

@property (nonatomic, assign) BOOL statusRequestFinished;
@property (nonatomic, assign) BOOL playlistRequestFinished;

- (TTURLRequest*)_sendStatusRequest:(NSString*)statusUrl;
- (void)_handleStatusResponse:(TTURLRequest*)request;

- (TTURLRequest*)_sendPlaylistRequest:(NSString*)playlistUrl;
- (void)_handlePlaylistResponse:(TTURLRequest*)request;

@end
