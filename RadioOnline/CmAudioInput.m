/*
 *  CmAudioInput.m
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
#import "CmAudioProtocol_Passthru.h"
#import "CmAudioProtocol_SHOUTcast.h"
#import "CmAudioStream.h"
#import "CmAudioInput.h"

@interface CmAudioInput (Internal) 

- (void) reset;

@end

@implementation CmAudioInput

@synthesize stream = stream_;
@synthesize protocol = protocol_;
@synthesize bufferFile = bufferFile_;
@synthesize delegate = delegate_;

- (id) initWithDelegate:(id<CmAudioInputDelegate>) delegate {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"init: input (%p)", self);
#endif
  
  if (self = [super init]) {
    delegate_ = delegate;
  }
  
  return self;
}

- (void) dealloc {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"dealloc: input (%p)", self);
#endif  
  
  [stream_ release];
  [streamParameters_ release];
  [protocol_ release];
  [bufferFile_ release];
  [super dealloc];
}

- (NSString *) streamingURL {
  return stream_.url;
}

- (BOOL) isVariableBitRate {
  return bufferFile_.isVariableBitRate;
}

- (UInt32) maxPacketSize {
  return bufferFile_.maxPacketSize;
}

- (void) startStreamingURL:(NSString *) urlStream withUserAgent:(NSString *) userAgent {
  
  if (!userAgent) {
    userAgent = @"";
  }
  
  if (stream_ == nil) {
    stream_ = [[CmAudioStream alloc] initWithDelegate: self];
  }
  
  stream_.delegate = self;
  
  [bufferFile_ release];
  bufferFile_ = [[CmAudioBufferFile alloc] initWithSize: kCmAudioBufferSize];
  
  [protocol_ release];
  protocol_ = nil;
  
  NSMutableDictionary * parameters = [NSMutableDictionary dictionary];

	[parameters setObject: [NSString stringWithFormat: @"CodeMorphicAudio/%s %@", kCmAudioVersion, userAgent] forKey: @"User-Agent"];
	[parameters setObject: @"1" forKey: @"icy-metadata"];
	
	[stream_ startStreamingURL: urlStream withParameters: parameters];  
}

- (void) stopStreaming {
  [stream_ stopStreaming];
}

- (void) reset {
  stream_.delegate = self;
  
  [streamParameters_ release]; streamParameters_ = nil;
  [protocol_ release]; protocol_ = nil;
  [bufferFile_ release]; bufferFile_ = nil;
}

#pragma mark CmAudioStreamDelegate

- (void) streamConnected:(CmAudioStream *) stream withParameters:(NSDictionary *) streamParameters {
  NSLog(@"input: streamConnected");
    
  if (streamParameters) {
    [streamParameters_ release];
    streamParameters_ = [[streamParameters copy] retain];
  }
  
  [delegate_ inputConnected: self];
}

- (void) stream:(CmAudioStream *) stream receivedData:(NSData *) data {
#if (CM_FULL_LOG == 1)  
  NSLog(@"input: streamReceivedData");
#endif
  
  if (protocol_ == nil) {
    
    if ([CmAudioProtocol_SHOUTcast isSHOUTcastStreamFromData: data andParameters: streamParameters_]) {
      protocol_ = [[CmAudioProtocol_SHOUTcast alloc] initWithBuffer: bufferFile_];
    }
    else {
//      protocol_ = [[CmAudioProtocol_Passthru alloc] initWithBuffer: bufferFile_];
      protocol_ = [[CmAudioProtocol_FileCache alloc] initWithBuffer: bufferFile_];
    }
    
    protocol_.delegate = self;
    
    [protocol_ streamConnected: stream_ withParameters: streamParameters_];
    [protocol_ stream: stream_ receivedData: data];
    
    stream_.delegate = protocol_;
  }
}

- (void) streamFinished:(CmAudioStream *) stream {
  NSLog(@"input: streamFinished");

#if 0  
  [self reset];
#endif  
  [delegate_ inputFinished: self];
}

- (void) streamFailed:(CmAudioStream *) stream withError:(NSString *) errorMessage {
  NSLog(@"input: streamFailed (%@)", errorMessage);

  [self reset];
  
  [delegate_ inputFailed: self withError: errorMessage];
}

- (void) stream:(CmAudioStream *) stream hasMetadata:(NSString *) metadata forTag:(NSString *) tag {
  NSLog(@"input: stream metadata tag(%@) metadata(%@)", tag, metadata);
  
  [delegate_ input: self hasMetadata: metadata forTag: tag];
}

@end
