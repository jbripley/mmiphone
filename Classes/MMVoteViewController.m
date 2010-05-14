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

#import "MMVoteViewController.h"

#import "MMVoteDataSource.h"
#import "MMVoteModel.h"

#import "MMSendVoteDelegate.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMVoteViewController

@synthesize sendVoteDelegate = _sendVoteDelegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) initWithTrackUri:(NSString*)trackUri {
  if (self = [super init]) {
    self.variableHeightRows = YES;
    self.tableViewStyle = UITableViewStyleGrouped;
    
    _sendVoteDelegate = [[MMSendVoteDelegate alloc] initWithTrackUri:trackUri controller:self];
    self.dataSource = [[[MMVoteDataSource alloc] initWithTrackUri:trackUri] autorelease];
  }

  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_sendVoteDelegate);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  
  self.navigationItem.rightBarButtonItem =
  [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send Vote", @"")
                            style:UIBarButtonItemStyleBordered
                            target:_sendVoteDelegate action:@selector(send)] autorelease];
  self.navigationItem.rightBarButtonItem.enabled = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadModel:(BOOL)firstTime {
  [super didLoadModel:firstTime];
  
  // Only enable a Send Vote button if a track could be loaded
  self.navigationItem.rightBarButtonItem.enabled = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)createDelegate {
  return _sendVoteDelegate;
}

@end
