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

@class MMSendVoteModel;

@interface MMSendVoteDelegate : TTTableViewDelegate {
  MMSendVoteModel* _sendVoteModel;
  TTActivityLabel *_voteActivityLabel;
}

@property (nonatomic, retain) MMSendVoteModel* sendVoteModel;
@property (nonatomic,retain) TTActivityLabel *voteActivityLabel;

- (id)initWithTrackUri:(NSString*)trackUri controller:(TTTableViewController*)controller;

- (void)showSpinnerWithText:(NSString*)spinnerText;
- (void)hideSpinner;

@end
