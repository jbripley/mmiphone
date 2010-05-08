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
  
  TTStyledText* styledText = [TTStyledText textFromXHTML:
                              [NSString stringWithFormat:@"%@ - %@ (%@)\n<b>%@</b>",
                               @"Title",
                               @"Artist",
                               @"Album",
                               [_statusModel.status.playtime formatShortTime]]
                                              lineBreaks:YES URLs:NO];
  // If this asserts, it's likely that the post.text contains an HTML character that caused
  // the XML parser to fail.
  TTDASSERT(nil != styledText);
  [items addObject:[TTTableStyledTextItem itemWithText:styledText]];
  
  self.items = items;
  TT_RELEASE_SAFELY(items);
}

@end
