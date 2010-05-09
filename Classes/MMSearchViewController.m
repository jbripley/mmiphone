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

#import "MMSearchViewController.h"

#import "MMSearchDataSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMSearchViewController

@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    
    self.title = @"Find a Song";
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
  self.dataSource = [[[TTListDataSource alloc] init] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  
  TTTableViewController* searchController = [[[TTTableViewController alloc] init] autorelease];
  searchController.dataSource = [[[MMSearchDataSource alloc] init] autorelease];
  self.searchViewController = searchController;
  self.tableView.tableHeaderView = _searchController.searchBar;
  
  _searchController.searchBar.placeholder = @"Song or Artist";
  _searchController.searchBar.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [_searchController.searchBar performSelector:@selector(becomeFirstResponder)
    withObject:nil afterDelay:0.1];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [[self navigationController] popViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  [_delegate searchController:self didSelectObject:object];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTSearchTextFieldDelegate

- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object {
  [_delegate searchController:self didSelectObject:object];
}

@end
