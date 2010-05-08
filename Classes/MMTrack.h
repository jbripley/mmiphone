//
//  MMTrack.h
//  mmiphone
//
//  Created by Joakim Bodin on 2010-05-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMTrack : NSObject {
  NSString* _album;
  NSString* _artist;
  NSString* _title;
  NSString* _voterId;
  NSString* _uri;
  NSNumber* _length;
}

@property (nonatomic, copy) NSString* album;
@property (nonatomic, copy) NSString* artist;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* voterId;
@property (nonatomic, copy) NSString* uri;
@property (nonatomic, retain) NSNumber* length;

@end
