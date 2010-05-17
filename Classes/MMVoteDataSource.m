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

#import "MMVoteDataSource.h"

#import "MMVoteModel.h"
#import "MMTrack.h"

#import "MMTableTrackDetailItem.h"
#import "MMTableTrackDetailItemCell.h"

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
  
  [voteTrackItems addObject:[MMTableTrackDetailItem itemWithText:_voteModel.track.title
                              imageURL:@"bundle://icon_track.png" URL:nil]];
  [voteTrackItems addObject:[MMTableTrackDetailItem itemWithText:_voteModel.track.artist
                              imageURL:@"bundle://icon_artist.png" URL:nil]];
  [voteTrackItems addObject:[MMTableTrackDetailItem itemWithText:_voteModel.track.album
                              imageURL:@"bundle://icon_disc.png" URL:nil]];
  
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"mm:ss"];
  
  [voteTrackItems addObject:[MMTableTrackDetailItem itemWithText:
                             [dateFormatter stringFromDate:
                              [NSDate dateWithTimeIntervalSince1970:
                               [_voteModel.track.length doubleValue]]]
                            imageURL:@"bundle://icon_time.png" URL:nil]];
  
  TT_RELEASE_SAFELY(dateFormatter);
  
  [sections addObject:NSLocalizedString(@"Chosen Track", @"")];
  [items addObject:voteTrackItems];
  TT_RELEASE_SAFELY(voteTrackItems);
  
  if ([(AppDelegate*)[UIApplication sharedApplication].delegate canOpenSpotifyUri]) {
    TTTableButton* previewItem = [TTTableButton
                                  itemWithText:NSLocalizedString(@"Preview in Spotify", @"")
                                  URL:_voteModel.trackUri];
    
    [sections addObject:@""];
    [items addObject:[NSArray arrayWithObject:previewItem]];
  }
    
  self.items = items;
  self.sections = sections;
  TT_RELEASE_SAFELY(items);
  TT_RELEASE_SAFELY(sections);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLoadable

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if([object isKindOfClass:[TTTableItem class]]) {
    if ([object isKindOfClass:[MMTableTrackDetailItem class]]) {
      return [MMTableTrackDetailItemCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
  }
  
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"No track found, please try again.", @"");
}

@end
