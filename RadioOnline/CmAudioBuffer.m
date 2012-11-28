/*
 *  CmAudioBuffer.m
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
#import "CmAudioProtocol_SHOUTcast.h"
#import "CmAudioBuffer.h"

@interface CmAudioBuffer (Internal)

- (void) hasData;

@end

@implementation CmAudioBuffer

@synthesize contentType = contentType_;
@synthesize inTotal = inTotal_;

- (id) initWithSize:(UInt32) numBytes {
  
#if (CM_LOG_ALLOC == 1)
  NSLog(@"init: buffer (%p)", self);
#endif

	if (self = [super init]) {
    self.contentType = @"audio/mpeg";
    
		numBufferBytes_ = numBytes;
		inTotal_ = 0;
		minDataAmount_ = 1<<17;
		lastReportBytes_ = 0;
    buffer_ = (UInt8 *) malloc(numBufferBytes_);
	}
	
	return self;
}

- (void) dealloc {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"dealloc: buffer (%p)", self);
#endif
  
	if (buffer_) {
		free(buffer_);
	}
  
  [contentType_ release];
	[super dealloc];
}

- (void) reset {
  inTotal_ = 0;
  outTotal_ = 0;
  streamStartTime_ = 0;
  lastReportBytes_ = 0;
}

- (UInt32) dataCount {
  return MIN(inTotal_ % numBufferBytes_, numBufferBytes_);
}

- (void) addData:(NSData *) dataToAdd {
  
  if (streamStartTime_ == 0) {
    time(&streamStartTime_);
  }
  
  UInt32	bufferAddIndex      = inTotal_ % numBufferBytes_;
  UInt8 * bufferAddPtr        = buffer_ + bufferAddIndex;
  UInt32  numBytesAvailAtEnd  = numBufferBytes_ - bufferAddIndex;
  UInt8 * dataToAddPtr        = (UInt8 *) [dataToAdd bytes];
  UInt32  numBytesToAdd       = [dataToAdd length];
  UInt32  numBytesToAddAtEnd  = MIN(numBytesAvailAtEnd, numBytesToAdd);

#if (CM_FULL_LOG == 1)
  NSLog(@"buffer: adding data of length %u (inTotal = %u)", numBytesToAdd, inTotal_);
#endif
  
  memcpy(bufferAddPtr, dataToAddPtr, numBytesToAddAtEnd);
  
  // wrap around?
  if (numBytesToAdd > numBytesToAddAtEnd) {    
    dataToAddPtr += numBytesToAddAtEnd;

    UInt32 numBytesToAddAtStart = numBytesToAdd - numBytesAvailAtEnd;
    
    memcpy(buffer_, dataToAddPtr, numBytesToAddAtStart);
  }
         
  inTotal_ += numBytesToAdd;
  
  if ((inTotal_ >> 15) > lastReportBytes_) {
    lastReportBytes_ = (inTotal_ >> 15);
    
    time_t currentTime;
    
    time(&currentTime);
    
    int kB = inTotal_>>10;
    int bitRate = (currentTime != streamStartTime_) ? (kB/(currentTime - streamStartTime_))<<3 : 0;
  
    NSLog(@"buffer: received %u kB (%u kbps)", kB, bitRate);
  }

  [self hasData];
}

- (void) hasData {
//  UInt32 bufferCopyIndex = outTotal_ % numBufferBytes_;
//  [outDelegate_ buffer: self hasData: (buffer_ + bufferCopyIndex) forCount: (inTotal_ - outTotal_)];
}

- (UInt32) copyDataIntoBuffer:(UInt8 *) outBuffer atPosition:(UInt64) posTotal forCount:(UInt32) numBytes {
#if (CM_FULL_LOG == 1)
  NSLog(@"buffer: copy position: %u count: %u (inTotal: %u)", (UInt32) posTotal, numBytes, (UInt32) inTotal_);
#endif
  
	if (posTotal >= inTotal_)
		return 0; // TODO: error

	UInt32 inBuf = inTotal_ % numBufferBytes_;
	UInt32 outBuf = posTotal % numBufferBytes_;

	UInt32 outBytes = 0;

	if (outBuf > inBuf) {
		outBytes = MIN(numBufferBytes_ - outBuf, numBytes);
		memcpy(outBuffer, buffer_ + outBuf, outBytes);
		
		outBuf += outBytes;
		outBuffer += outBytes;
		numBytes -= outBytes;
		
		if (numBytes > 0) {
			outBuf = 0;
		}
	}
	
	if (numBytes > 0) {
		outBytes += numBytes;
		memcpy(outBuffer, buffer_ + outBuf, numBytes);
	}	

	return outBytes;
}

@end

