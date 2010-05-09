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

#import "MMStatusDataSource.h"

#import "MMStatusModel.h"
#import "MMStatus.h"
#import "MMTrack.h"

// Three20 Additions
#import <Three20Core/NSDateAdditions.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMStatusDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _statusModel = [[MMStatusModel alloc] init];
  }
  
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_statusModel);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  return _statusModel;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewDidLoadModel:(UITableView*)tableView {
  NSMutableArray* items = [[NSMutableArray alloc] init];
  NSMutableArray* sections = [[NSMutableArray alloc] init];
  
  TTTableSubtitleItem* playingTrackItem = nil;
  NSMutableArray* playlistTrackItems = [[NSMutableArray alloc] init];
  if ([_statusModel.tracks count] > 0) {
    MMTrack* currentTrack = [_statusModel.tracks objectAtIndex:0];
    
    playingTrackItem = [TTTableSubtitleItem itemWithText:currentTrack.title
                        subtitle:[NSString stringWithFormat:@"%@ - %@",
                                  currentTrack.album, currentTrack.artist]];
    
    for (MMTrack* track in _statusModel.tracks) {
      if (track == currentTrack) {
        continue;
      }
      
      TTTableSubtitleItem* playlistTrackItem = [TTTableSubtitleItem itemWithText:track.title
                                            subtitle:[NSString stringWithFormat:@"%@ - %@",
                                                      track.album, track.artist]];
      [playlistTrackItems addObject:playlistTrackItem];
    }
  }
  else {
    playingTrackItem = [TTTableSubtitleItem itemWithText:@"No song playing" subtitle:@""];
  }
  
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"mm:ss"];
  
  NSTimeInterval diff = [_statusModel.status.timeUntilVote timeIntervalSinceDate:[NSDate date]];
  NSDate* dateDiff = [NSDate dateWithTimeIntervalSince1970:diff];
  
  NSString *nextTrackInText = [NSString stringWithFormat:@"Next track in: %@",
                               [dateFormatter stringFromDate:dateDiff]];
  TT_RELEASE_SAFELY(dateFormatter);
  
  TTTableGrayTextItem* nextTrackInItem = [TTTableGrayTextItem itemWithText:nextTrackInText];
  
  NSMutableArray* currentTrackItems = [[NSMutableArray alloc] init];
  [currentTrackItems addObject:playingTrackItem];
  [currentTrackItems addObject:nextTrackInItem];
  
  [sections addObject:@""];
  [items addObject:currentTrackItems];
  TT_RELEASE_SAFELY(currentTrackItems);
  
  [sections addObject:@"Upcoming Playlist"];
  [items addObject:playlistTrackItems];
  TT_RELEASE_SAFELY(playlistTrackItems);
  
  self.items = items;
  self.sections = sections;
  TT_RELEASE_SAFELY(items);
  TT_RELEASE_SAFELY(sections);
}

@end
