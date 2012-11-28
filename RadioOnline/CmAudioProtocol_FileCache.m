/*
 *  CmAudioProtocol_FileCache.m
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
#import "CmAudioBufferFile.h"
#import "CmAudioProtocol_FileCache.h"

@implementation CmAudioProtocol_FileCache

- (id) initWithBuffer:(CmAudioBuffer *) buffer {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"init: protocol filecache (%p)", self);
#endif
  
  if (self = [super initWithBuffer: buffer]) {
    tmpDirectory_ = [[NSString pathWithComponents: [NSArray arrayWithObjects: NSTemporaryDirectory(), @"fc", nil]] retain];
  }
  
  return self;
}

- (void) dealloc {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"dealloc: protocol filecache (%p)", self);
#endif
  
  [readTimer_ invalidate];
  [readTimer_ release];
  
  [tmpDirectory_ release];
  [super dealloc];
}

- (void) pumpData:(NSTimer *) timer {

 // while (true) {
    
    NSString * fileName = [NSString pathWithComponents: [NSArray arrayWithObjects: tmpDirectory_, [NSString stringWithFormat: @"%u.mp3", packetNumberOut_], nil]];
    
    NSData * data = [NSData dataWithContentsOfFile: fileName];
    
    if (data == nil)
      return;
    
    if (totalBytesAvailable_ < [data length])
      return;
    
    NSLog(@"protocol(FileCache): read data from temp file: %@", fileName);

	NSError * error = nil;
  
	[[NSFileManager defaultManager] removeItemAtPath: fileName error: &error];
    
    totalBytesAvailable_ -= [data length];
    packetNumberOut_++;
    
    [buffer_ addData: data];
 // }
}

#pragma mark CmAudioBufferFileInDelegate

- (void) bufferFile:(CmAudioBufferFile *) bufferFile consumedBytes:(UInt32) numBytes {

  totalBytesAvailable_ += numBytes;  
}

#pragma mark CmAudioStreamDelegate

- (void) streamConnected:(CmAudioStream *) stream withParameters:(NSDictionary *) parameters {
#if (CM_FULL_LOG == 1)  
  NSLog(@"protocol(FileCache): stream connected");
#endif
  
  totalBytesAvailable_ = kCmAudioBufferSize;
  totalBytesIn_ = 0;
  totalBytesOut_ = 0;
  packetNumberIn_ = 0;
  packetNumberOut_ = 0;
  
  if (tmpDirectory_) {
		NSFileManager * fileManager = [NSFileManager defaultManager];
		
		NSError * error = nil;
		
		[fileManager removeItemAtPath: tmpDirectory_ error: &error];
		[fileManager createDirectoryAtPath: tmpDirectory_ withIntermediateDirectories: YES attributes: nil error: &error];
  }
  
  ((CmAudioBufferFile *) buffer_).delegateIn = self;

  readTimer_ = [[NSTimer scheduledTimerWithTimeInterval: 0.25 target: self selector: @selector(pumpData:) userInfo: nil repeats: YES] retain];
}

- (void) stream:(CmAudioStream *) stream receivedData:(NSData *) data {
#if (CM_FULL_LOG == 1)  
  NSLog(@"protocol(FileCache): stream received data");
#endif
  
  totalBytesIn_ += [data length];

  if (totalBytesIn_ < (kCmAudioBufferSize>>1)) {
    [buffer_ addData: data];
    totalBytesAvailable_ -= [data length];
    return;
  }
  
  NSString * fileName = [NSString pathWithComponents: [NSArray arrayWithObjects: tmpDirectory_, [NSString stringWithFormat: @"%u.mp3", packetNumberIn_], nil]];
    
  NSLog(@"protocol(FileCache): writing temp file: %@", fileName);
  
  [data writeToFile: fileName atomically: NO];

  packetNumberIn_++;

//  [buffer_ addData: data];
}

- (void) streamFinished:(CmAudioStream *) stream {

}

@end
