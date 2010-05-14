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

#import "MMXmlTrackParser.h"

#import "MMTrack.h"

@implementation MMXmlTrackParser

+ (MMTrack*)parseTrack:(NSDictionary*)trackDict forCountry:(NSString*)countryCode {
  if (![trackDict isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  
  NSDictionary* artistDict = [trackDict objectForKey:@"artist"];
  if (![artistDict isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  
  NSDictionary* albumDict = [trackDict objectForKey:@"album"];
  if (![albumDict isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  
  NSDictionary* territoriesDict = [[albumDict objectForKey:@"availability"]
                                    objectForKey:@"territories"];
  if ([territoriesDict isKindOfClass:[NSDictionary class]]) {
    NSString* territories = [territoriesDict objectForKey:@"___Entity_Value___"];
    if (([territories rangeOfString:countryCode].location == NSNotFound) &&
        ([territories rangeOfString:@"worldwide"].location == NSNotFound) ) {
      return nil;
    }
  }
  
  MMTrack* track = [[[MMTrack alloc] init] autorelease];
  track.artist = [[artistDict objectForKey:@"name"] objectForKey:@"___Entity_Value___"];
  track.album = [[albumDict objectForKey:@"name"] objectForKey:@"___Entity_Value___"];
  track.title = [[trackDict objectForKey:@"name"] objectForKey:@"___Entity_Value___"];
  track.uri = [trackDict objectForKey:@"href"];
  track.length = [NSNumber numberWithDouble:
                  [[[trackDict objectForKey:@"length"]
                    objectForKey:@"___Entity_Value___"] doubleValue]];
  
  return track;
}

@end
