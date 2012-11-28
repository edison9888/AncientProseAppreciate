/*
 *  CmAudioProtocol_Passthru.m
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
#import "CmAudioProtocol_Passthru.h"

@implementation CmAudioProtocol_Passthru

- (id) initWithBuffer:(CmAudioBuffer *) buffer {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"init: protocol passthru (%p)", self);
#endif
  
  if (self = [super initWithBuffer: buffer]) {
    ; 
  }
  
  return self;
}

- (void) dealloc {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"dealloc: protocol passthru (%p)", self);
#endif
  
  [super dealloc];
}

#pragma mark CmAudioStreamDelegate

- (void) streamConnected:(CmAudioStream *) stream {
#if (CM_FULL_LOG == 1)  
  NSLog(@"protocol(Passthru): stream connected");
#endif
  
  totalBytes_ = 0;
}

- (void) stream:(CmAudioStream *) stream receivedData:(NSData *) data {
#if (CM_FULL_LOG == 1)  
  NSLog(@"protocol(Passthru): stream received data");
#endif
  
  totalBytes_ += [data length];
  
  [buffer_ addData: data];
}

@end
