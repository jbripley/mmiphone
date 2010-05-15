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

#import "MMVoteDataSource.h"

#import "MMVoteModel.h"
#import "MMTrack.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMVoteDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTrackUri:(NSString*)trackUri {
  if (self = [super init]) {
    _voteModel = [[MMVoteModel alloc] initWithTrackUri:trackUri];
  }
  
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_voteModel);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  return _voteModel;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewDidLoadModel:(UITableView*)tableView {
  NSMutableArray* items = [[NSMutableArray alloc] init];
  NSMutableArray* sections = [[NSMutableArray alloc] init];
  
  NSMutableArray* voteTrackItems = [[NSMutableArray alloc] init];
  
  [voteTrackItems addObject:[TTTableImageItem itemWithText:_voteModel.track.title
                              imageURL:@"bundle://icon_track.png" URL:nil]];
  [voteTrackItems addObject:[TTTableImageItem itemWithText:_voteModel.track.artist
                              imageURL:@"bundle://icon_artist.png" URL:nil]];
  [voteTrackItems addObject:[TTTableImageItem itemWithText:_voteModel.track.album
                              imageURL:@"bundle://icon_disc.png" URL:nil]];
  
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"mm:ss"];
  
  [voteTrackItems addObject:[TTTableImageItem itemWithText:
                             [dateFormatter stringFromDate:
                              [NSDate dateWithTimeIntervalSince1970:
                               [_voteModel.track.length doubleValue]]]
                            imageURL:@"bundle://icon_time.png" URL:nil]];
  
  TT_RELEASE_SAFELY(dateFormatter);
  
  [sections addObject:NSLocalizedString(@"Chosen Track", @"")];
  [items addObject:voteTrackItems];
  TT_RELEASE_SAFELY(voteTrackItems);
    
  self.items = items;
  self.sections = sections;
  TT_RELEASE_SAFELY(items);
  TT_RELEASE_SAFELY(sections);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"No track found, please try again.", @"");
}

@end
