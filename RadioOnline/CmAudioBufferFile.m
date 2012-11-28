/*
 *  CmAudioBufferFile.m
 *
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
#import "CmAudioBufferFile.h"

static BOOL isVBR(AudioStreamBasicDescription * audioFormat);
static SInt64   audioGetSize(void * audioBufferFile_);
static OSStatus audioRead(void *    audioBufferFile_,
                          SInt64    posRead,
                          UInt32    requestCount,
                          void *    buffer,
                          UInt32 *  actualCount);

@interface CmAudioBufferFile (Internal)

- (BOOL) initFileWithError:(NSString **) errorMessage;

@end

@implementation CmAudioBufferFile

@synthesize delegate = delegate_;
@synthesize delegateIn = delegateIn_;
@synthesize currentPacket = currentPacket_;
@synthesize magicCookie = magicCookie_;
@synthesize isVariableBitRate = isVariableBitRate_;
@synthesize audioQueueBufferSize = audioQueueBufferSize_;
@synthesize maxPacketSize = maxPacketSize_;
@synthesize numPacketsInAudioBuffer = numPacketsInAudioBuffer_;
@synthesize audioStreamDescription = audioStreamDescription_;

- (id) initWithSize:(NSUInteger) bufferSize {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"init: buffer file (%p)", self);
#endif
  
  if (self = [super initWithSize: bufferSize]) {
    audioQueueBufferSize_ = kCmAudioQueueBufferSize;
  }
  
  return self;
}

- (void) dealloc {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"dealloc: buffer file (%p)", self);
#endif
  
  if (audioFileID_) {
    OSStatus sts = AudioFileClose(audioFileID_);
#if (CM_LOG_AUDIO == 1)    
    NSLog(@"AudioFileClose(%p) [sts = %i (%c%c%c%c)]", audioFileID_, sts, STS2C(sts));
#endif
    audioFileID_ = 0;
    
    sts; // prevent warning unused variable    
  }
  
  [super dealloc];
}

- (void) reset {
  currentPacket_ = 0;
  
  [delegate_ bufferFileReset: self];
}

- (void) readPackets:(AudioQueueBufferRef) audioQueueBuffer returningNumBytes:(UInt32 *) numBytes andNumPackets:(UInt32 *) numPackets {
  
  *numBytes = 0;
  *numPackets = 0;
  
  if (audioQueueBuffer == nil) {
    return;
  }

  *numPackets = numPacketsInAudioBuffer_;
  
	OSStatus sts = AudioFileReadPackets(audioFileID_, false, numBytes, 
                                      (AudioStreamPacketDescription *) audioQueueBuffer->mUserData, 
                                      currentPacket_, 
                                      numPackets, 
                                      audioQueueBuffer->mAudioData);
#if (CM_LOG_AUDIO == 1)
  NSLog(@"AudioFileReadPackets af=%p, abuf=%p, currentPacket=%llu, numBytes=%u, numPackets=%u [sts = %i (%c%c%c%c)]",
        audioFileID_, audioQueueBuffer, currentPacket_, *numBytes, *numPackets, sts, STS2C(sts));
#endif	
	audioQueueBuffer->mAudioDataByteSize = *numBytes;
  
  currentPacket_ += *numPackets;
  
  [delegateIn_ bufferFile: self consumedBytes: *numBytes];
  
  sts; // kCmAudioQueueBufferSize warning unused variable
}

- (AudioFileTypeID) audioFileType {

  NSLog(@"bufferFile: finding audio type for content-type %@", contentType_);
  
  if ([contentType_ isEqualToString: @"audio/mpeg"])
    return kAudioFileMP3Type;
  
  if ([contentType_ isEqualToString: @"audio/aac"])
    return kAudioFileAAC_ADTSType;
  
  if ((contentType_ != nil) && (contentType_.length > 0))
    return -1;
  
  return kAudioFileMP3Type; // default
}

- (BOOL) initFileWithError:(NSString **) error {	
  
  audioFileID_ = 0;

	OSStatus sts;
  
  AudioFileTypeID audioFileType = [self audioFileType];
  
  if (audioFileType == -1) {
    if (error) {
      *error = [NSString stringWithFormat: @"Unsupported stream type: %@", contentType_];
    }
    
    return NO;
  }
  
  sts = AudioFileOpenWithCallbacks(self, audioRead, NULL, audioGetSize, NULL, audioFileType, &audioFileID_);
#if (CM_LOG_AUDIO == 1)  
  NSLog(@"AudioFileOpenWithCallbacks af=%p [sts = %i (%c%c%c%c)]", audioFileID_, sts, STS2C(sts));
#endif
  
  if (sts) {
    if (error) {
      *error = [NSString stringWithFormat: @"Invalid stream data for stream type: %@", contentType_];
    }
    
    return NO;
  }
  
	UInt32 cbDesc = sizeof(audioStreamDescription_);
	
	sts = AudioFileGetProperty(audioFileID_, kAudioFilePropertyDataFormat, &cbDesc, &audioStreamDescription_);
#if (CM_LOG_AUDIO == 1)  
	NSLog(@"AudioFileGetProperty(%p, DataFormat) [sts = %i (%c%c%c%c)]", audioFileID_, sts, STS2C(sts));
#endif
	
  isVariableBitRate_ = isVBR(&audioStreamDescription_);
  
  NSLog(@"bufferFile: variable bit rate stream: %@", isVariableBitRate_ ? @"yes" : @"no");
  
	UInt32 cbMaxPacketSize = sizeof(maxPacketSize_);
	sts = AudioFileGetProperty(audioFileID_, kAudioFilePropertyPacketSizeUpperBound, &cbMaxPacketSize, &maxPacketSize_);
#if (CM_LOG_AUDIO == 1)  
	NSLog(@"AudioFileGetProperty(%p, PacketSizeUpperBound) val=%u [sts = %i (%c%c%c%c)]", audioFileID_, maxPacketSize_, sts, STS2C(sts));
#endif
  
  if (maxPacketSize_) {
    numPacketsInAudioBuffer_ = audioQueueBufferSize_/maxPacketSize_;
  }
  
	UInt32 numMagicCookieBytes = 0;
	UInt32 isWritable = false;
	sts = AudioFileGetPropertyInfo(audioFileID_, kAudioFilePropertyMagicCookieData, &numMagicCookieBytes, &isWritable);
#if (CM_LOG_AUDIO == 1)  
	NSLog(@"AudioFileGetPropertyInfo(%p, MagicCookie) val=%u [sts = %i (%c%c%c%c)]", audioFileID_, numMagicCookieBytes, sts, STS2C(sts));
#endif
	
	if ((sts == 0) && (numMagicCookieBytes > 0)) {
    
    void *magicCookie = alloca(numMagicCookieBytes);
    
		sts = AudioFileGetProperty(audioFileID_, kAudioFilePropertyMagicCookieData, &numMagicCookieBytes, magicCookie);
#if (CM_LOG_AUDIO == 1)  
		NSLog(@"AudioFileGetProperty(%p, MagicCookie) [sts = %i (%c%c%c%c)]", audioFileID_, sts, STS2C(sts));
#endif

		magicCookie_ = [[NSData alloc] initWithBytes: magicCookie length: numMagicCookieBytes];
	}
  
  return YES;
}

- (void) closeFile {

  if (audioFileID_) {
    OSStatus sts = AudioFileClose(audioFileID_);
#if (CM_LOG_AUDIO == 1)
    NSLog(@"AudioFileClose(%p) [sts = %i (%c%c%c%c)]", audioFileID_, sts, STS2C(sts));
#endif
    
    audioFileID_ = 0;
    
    sts; // prevent warning unused variable
  }
}

- (SInt64) getSize {
  return super.inTotal;
}

- (UInt32) readIntoBuffer:(UInt8 *) buffer atPosition:(UInt64) position forCount:(UInt32) numBytes {
  return [super copyDataIntoBuffer: buffer atPosition: position forCount: numBytes];
}

- (void) hasData {
  
  if (audioFileID_ == 0) {
    if (inTotal_ < 65536)
      return;
    
    time_t currentTime = 0;
    
    time(&currentTime);
    
    if (currentTime - streamStartTime_ < kCmMinBufferSeconds)
      return;
    
    NSString * errorMessage = nil;
  
    if (![self initFileWithError: &errorMessage]) {
      [delegate_ bufferFileFailed: self withError: errorMessage];
    }
  }
  
  [delegate_ bufferFileHasData: self];
}

#pragma mark Audio Callbacks

static SInt64 audioGetSize(void * audioBufferFile_) {
	return [((CmAudioBufferFile *) audioBufferFile_) getSize];
}

static OSStatus audioRead(void *    audioBufferFile_,
                          SInt64    posRead,
                          UInt32    requestCount,
                          void *    buffer,
                          UInt32 *  actualCount) {
	
	*actualCount = [((CmAudioBufferFile *) audioBufferFile_) readIntoBuffer: buffer atPosition: posRead forCount: requestCount];
  
  if (*actualCount == 0) {
    NSLog(@"*** bufferFile: no bytes to read");
  }
	
	return 0;
}

static BOOL isVBR(AudioStreamBasicDescription * audioFormat) {
	return (audioFormat->mBytesPerPacket == 0) || (audioFormat->mFramesPerPacket == 0);
}


@end