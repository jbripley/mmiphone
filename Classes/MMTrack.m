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

#import "MMTrack.h"


@implementation MMTrack

@synthesize album   = _album;
@synthesize artist  = _artist;
@synthesize title   = _title;
@synthesize uri     = _uri;
@synthesize length  = _length;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  TT_RELEASE_SAFELY(_album);
  TT_RELEASE_SAFELY(_artist);
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_uri);
  TT_RELEASE_SAFELY(_length);
  
  [super dealloc];
}

@end
