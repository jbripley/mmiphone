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

#import <Three20UICommon/UIViewControllerAdditions.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMSearchViewController

@synthesize savedSearch = _savedSearch;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _savedSearch = nil;
    self.title = NSLocalizedString(@"Find Track", @"");
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_savedSearch);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
  self.dataSource = [[[TTListDataSource alloc] init] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  
  UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                    target:self action:@selector(dismiss)];
  self.navigationItem.rightBarButtonItem = cancelButton;
  TT_RELEASE_SAFELY(cancelButton);
  
  TTTableViewController* searchController = [[[TTTableViewController alloc] init] autorelease];
  searchController.dataSource = [[[MMSearchDataSource alloc] init] autorelease];
  self.searchViewController = searchController;
  self.tableView.tableHeaderView = _searchController.searchBar;
  
  _searchController.pausesBeforeSearching = YES;
  _searchController.searchBar.placeholder = NSLocalizedString(@"Song or Artist", @"");
  _searchController.searchBar.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (_savedSearch != nil) {
    _searchController.searchBar.text = _savedSearch;
  }
}
  
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (_savedSearch == nil) {
    [_searchController.searchBar performSelector:@selector(becomeFirstResponder)
                                      withObject:nil afterDelay:TT_FAST_TRANSITION_DURATION];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)persistView:(NSMutableDictionary*)state {
  NSString* savedSearch = self.savedSearch;
  if (TTIsStringWithAnyText(savedSearch)) {
    [state setObject:savedSearch forKey:@"savedSearch"];  
  }
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreView:(NSDictionary*)state {
  [super restoreView:state];
  
  NSString* savedSearch = [state objectForKey:@"savedSearch"];
  if (TTIsStringWithAnyText(savedSearch)) {
    self.savedSearch = savedSearch;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  self.savedSearch = searchText;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [self dismiss];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

@end
