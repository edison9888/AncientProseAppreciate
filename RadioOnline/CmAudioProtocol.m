/*
 *  CmAudioProtocol.m
 *
 *  Copyright (c) 2008, 2009, 2010 CodeMorphic, Inc. (www.codemorphic.com)
 *
 *  This file is part of CoMoRadio.
 *
 *  CoMoRadio is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  CoMoRadio is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with CoMoRadio.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "CmAudioCommon.h"
#import "CmAudioBuffer.h"
#import "CmAudioStream.h"
#import "CmAudioProtocol.h"

@implementation CmAudioProtocol

@synthesize delegate = delegate_;

- (id) initWithBuffer:(CmAudioBuffer *) buffer {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"init: protocol (%p)", self);
#endif

  if (self = [super init]) {
    buffer_ = [buffer retain];
  }
  
  return self;
}

- (void) dealloc {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"dealloc: protocol (%p)", self);
#endif

  [buffer_ release];
  [super dealloc];
}

#pragma mark CmAudioStreamDelegate

- (void) streamConnected:(CmAudioStream *) stream withParameters:(NSDictionary *) parameters {
  NSLog(@"protocol: stream connected");
  
  [buffer_ reset];
  
  [delegate_ streamConnected: stream withParameters: parameters];
}

- (void) stream:(CmAudioStream *) stream receivedData:(NSData *) data {
  NSLog(@"protocol: stream received data");

  [delegate_ stream: stream receivedData: data];
}

- (void) streamFinished:(CmAudioStream *) stream {
  NSLog(@"protocol: stream finished");

  [delegate_ streamFinished: stream];
}

- (void) streamFailed:(CmAudioStream *) stream withError:(NSString *) errorMessage {
  NSLog(@"protocol: stream failed");

  [delegate_ streamFailed: stream withError: errorMessage];
}

- (void) stream:(CmAudioStream *) stream hasMetadata:(NSString *) metadata forTag:(NSString *) tag {
  NSLog(@"protocol: stream metadata tag(%@) metadata(%@)", tag, metadata);
}

@end