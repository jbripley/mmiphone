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

#import <Foundation/Foundation.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface MMTrack : NSObject {
  NSString* _album;
  NSString* _artist;
  NSString* _title;
  NSString* _uri;
  NSNumber* _length;
}

@property (nonatomic, copy) NSString* album;
@property (nonatomic, copy) NSString* artist;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* uri;
@property (nonatomic, retain) NSNumber* length;

@end
