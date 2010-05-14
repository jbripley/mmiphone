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

#import "MMSendVoteDelegate.h"

#import "MMSendVoteModel.h"

#import <Three20UI/UIViewAdditions.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMSendVoteDelegate

@synthesize sendVoteModel = _sendVoteModel;
@synthesize voteActivityLabel = _voteActivityLabel;

- (id)initWithTrackUri:(NSString*)trackUri controller:(TTTableViewController*)controller {
  if (self = [super initWithController:controller]) {
    _sendVoteModel = [[MMSendVoteModel alloc] initWithTrackUri:trackUri];
    [self.sendVoteModel.delegates addObject:self];
  }
  
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_voteActivityLabel);
  
  [self.sendVoteModel.delegates removeObject:self];
  TT_RELEASE_SAFELY(_sendVoteModel);
  
  [super dealloc];
}

- (void)send {
  TTDINFO(@"Send vote for: %@", self.sendVoteModel.trackUri);
  
  _controller.navigationItem.rightBarButtonItem.enabled = NO;
  _controller.navigationItem.hidesBackButton = YES;
  
  [self.sendVoteModel load:TTURLRequestCachePolicyNone more:NO];
  
  [self showSpinnerWithText:NSLocalizedString(@"Sending Vote...", @"")];
}

//- (void)confirm {
//  TTAlertViewController* alert = [[[TTAlertViewController alloc] initWithTitle:
//                                    NSLocalizedString(@"Send Vote", @"")
//                                   message:
//                                    NSLocalizedString(@"Sure you want to send your vote?", @"")]
//                                  autorelease];
//  [alert addButtonWithTitle:NSLocalizedString(@"Yes", @"") URL:
//   [NSString stringWithFormat:kAppSendVoteFormatURLPath,
//    [(MMVoteModel*)self.dataSource.model trackUri]]];
//  [alert addCancelButtonWithTitle:NSLocalizedString(@"No", @"") URL:nil];
//  [alert showInView:[[_controller view] animated:YES];
//}

- (void)showSpinnerWithText:(NSString*)spinnerText {
  self.voteActivityLabel = [[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleBlackBezel];
  self.voteActivityLabel.font = [UIFont systemFontOfSize:25];
  self.voteActivityLabel.text = spinnerText;
  
  [self.voteActivityLabel sizeToFit];
  self.voteActivityLabel.frame = CGRectMake(0, 0,
                                            _controller.view.width, _controller.view.height);
  [_controller.view addSubview:self.voteActivityLabel];
}

- (void)hideSpinner {
  [self.voteActivityLabel removeFromSuperview];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<TTModel>)model {
  TTDINFO(@"Vote sent successfully");
  
  [self hideSpinner];
  
  [_controller dismissModalViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
  TTDINFO(@"Vote failed with error: %@", error);
  
  // HTTP Status Code Conflict == Already Voted
  if ([error code] == 409) {
    [self hideSpinner];
    [self showSpinnerWithText:NSLocalizedString(@"Already voted.", @"")];
    
    [_controller performSelector:@selector(dismissModalViewControllerAnimated:)
               withObject:[NSNumber numberWithBool:YES] afterDelay:3.0];
  }
  else {
    [self hideSpinner];
    [self showSpinnerWithText:NSLocalizedString(@"Vote failed.", @"")];
    [self performSelector:@selector(hideSpinner)
               withObject:nil afterDelay:3.0];
    
    _controller.navigationItem.rightBarButtonItem.enabled = YES;
    _controller.navigationItem.hidesBackButton = NO;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad:(id<TTModel>)model {
  TTDINFO(@"Sending vote was canceled");
  
  [self hideSpinner];
  [self showSpinnerWithText:NSLocalizedString(@"Vote canceled.", @"")];
  [self performSelector:@selector(hideSpinner) withObject:nil afterDelay:3.0];
  
  _controller.navigationItem.rightBarButtonItem.enabled = YES;
  _controller.navigationItem.hidesBackButton = NO;
}

@end

