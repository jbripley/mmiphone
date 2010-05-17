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

#import "AppDelegate.h"

#import "MMSearchDataSource.h"

#import "MMSearchModel.h"
#import "MMTrack.h"

#import "MMTableTrackItem.h"
#import "MMTableTrackItemCell.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMSearchDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _searchModel = [[MMSearchModel alloc] init];
  }
  
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_searchModel);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  return _searchModel;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource
- (void)tableViewDidLoadModel:(UITableView*)tableView {
  self.items = [NSMutableArray array];
  
  BOOL canOpenSpotifyUri = [(AppDelegate*)[UIApplication sharedApplication].delegate
                            canOpenSpotifyUri];
  
  for (MMTrack* track in _searchModel.tracks) {
    MMTableTrackItem* searchTrackItem = [MMTableTrackItem itemWithText:track.title
                                          subtitle:[NSString stringWithFormat:@"%@ - %@",
                                                    track.album, track.artist]
                                          URL:[NSString stringWithFormat:
                                               kAppVoteFormatURLPath, track.uri]];
    
    if (canOpenSpotifyUri) {
      searchTrackItem.accessoryURL = [NSString stringWithFormat:
                                      kAppSpotifyConfirmFormatURLPath, track.uri];
    }

    [self.items addObject:searchTrackItem];
  }
}

- (void)search:(NSString*)text {
  [_searchModel search:text];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLoadable

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if([object isKindOfClass:[TTTableItem class]]) {
    if ([object isKindOfClass:[MMTableTrackItem class]]) {
      return [MMTableTrackItemCell class];
    }
      return [super tableView:tableView cellClassForObject:object];
    }

  return nil;
}

- (NSString*)titleForNoData {
  return NSLocalizedString(@"No tracks found", @"");
}

@end
