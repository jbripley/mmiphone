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

#import "MMStatusViewController.h"

#import "MMStatusDataSource.h"
#import "MMStatusModel.h"
#import "MMStatus.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMStatusViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) init {
  if (self = [super init]) {
    _viewAppearFirstTime = YES;
    self.title = NSLocalizedString(@"Currently Playing", @"");
    self.variableHeightRows = YES;
    self.tableViewStyle = UITableViewStyleGrouped;
  }
  
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
  self.dataSource = [[[MMStatusDataSource alloc] init] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)createDelegate {
  return [[[TTTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  
  self.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Vote", @"")
                              style:UIBarButtonItemStyleBordered
                              target:kAppSearchURLPath
                              action:@selector(openURLFromButton:)] autorelease];
  self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_viewAppearFirstTime) {
    [self.model load:TTURLRequestCachePolicyNetwork more:NO];
  }
  else {
    _viewAppearFirstTime = NO;
  }

}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadModel:(BOOL)firstTime {
  [super didLoadModel:firstTime];
  
  MMStatus* status = [(MMStatusModel*)self.dataSource.model status];
  if (status.hasVoted) {
    self.navigationItem.rightBarButtonItem.enabled = NO;
  }
  else {
    self.navigationItem.rightBarButtonItem.enabled = YES;
  }

}

@end

