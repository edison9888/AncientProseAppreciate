/*
 *  CmAudioQueue.m
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
#import "CmAudioSession.h"
#import "CmAudioQueue.h"

static void audioQueueOutput(void *inUserData, AudioQueueRef audioQueue, AudioQueueBufferRef audioQueueBuffer);

@implementation CmAudioQueue

@synthesize delegate = delegate_;

- (id) initWithAudioDescription:(AudioStreamBasicDescription) audioStreamDescription delegate:(id<CmAudioQueueDelegate>) delegate {

  if (self = [super init]) {
    [CmAudioSession initialize];
    
    delegate_ = delegate;
    
    OSStatus sts = AudioQueueNewOutput(&audioStreamDescription, audioQueueOutput, self, CFRunLoopGetCurrent(), NULL, 0, &audioQueue_);

#if (CM_LOG_AUDIO == 1)    
    NSLog(@"AudioQueueNewOutput aq=%p [sts = %i (%c%c%c%c)]", audioQueue_, sts, STS2C(sts));
#endif
    
    if (sts == 1718449215) { // fmt?
      [delegate_ audioQueueFailed: self withError: @"Invalid format for playback."];
      return self;
    }
    
    sts = AudioQueueCreateTimeline(audioQueue_, &timeline_);
    
#if (CM_LOG_AUDIO == 1)    
    NSLog(@"AudioQueueCreateTimeline aq=%p, tl=%p [sts = %i (%c%c%c%c)]", audioQueue_, timeline_, sts, STS2C(sts));
#endif
    
    sts; // prevent warning unused variable
  }
  
  return self;
}

- (void) dealloc {
  
  if (audioQueue_) {
    
    OSStatus sts = 0;
    
    if (timeline_) {
      sts = AudioQueueDisposeTimeline(audioQueue_, timeline_);
      
#if (CM_LOG_AUDIO == 1)    
      NSLog(@"AudioQueueDisposeTimeline aq=%p, tl=%p  [sts = %i (%c%c%c%c)]", audioQueue_, timeline_, sts, STS2C(sts));
#endif
      
      timeline_ = NULL;
    }    
    
    sts = AudioQueueDispose(audioQueue_, true);
    
#if (CM_LOG_AUDIO == 1)    
    NSLog(@"AudioQueueDispose(%p) [sts = %i (%c%c%c%c)]", audioQueue_, sts, STS2C(sts));
#endif
    
    audioQueue_ = NULL;
    
    sts; // prevent warning unused variable
  }
  
  [super dealloc];
}

- (void) start {
  OSStatus sts = AudioQueueStart(audioQueue_, NULL);
  
#if (CM_LOG_AUDIO == 1)  
  NSLog(@"AudioQueueStart aq=%p [sts = %i (%c%c%c%c)]", audioQueue_, sts, STS2C(sts));
#endif
  
  sts; // prevent warning unused variable
}

- (void) stop {
  OSStatus sts = AudioQueueStop(audioQueue_, true); // true can cause AudioQueueStop to hang sometimes

#if (CM_LOG_AUDIO == 1)
  NSLog(@"AudioQueueStop(%p) [sts = %i (%c%c%c%c)]", audioQueue_, sts, STS2C(sts));
#endif
  
  sts; // prevent warning unused variable
}

- (BOOL) hasDiscontinuityOccurred {
  Boolean discontinuity = FALSE;
  AudioTimeStamp timestamp;
  
  OSStatus sts = AudioQueueGetCurrentTime(audioQueue_, timeline_, &timestamp, &discontinuity);

#if (CM_LOG_AUDIO == 1)
  NSLog(@"AudioQueueGetCurrentTime aq=%p, tl=%p time=%f discontinuity=%u [sts = %i (%c%c%c%c)]", audioQueue_, timeline_, timestamp.mSampleTime, discontinuity, sts, STS2C(sts));		
#endif
  
  sts; // prevent warning unused variable
  
  return discontinuity;
}

- (void) setMagicCookie:(NSData *) magicCookie {
  
  if (magicCookie == nil)
    return;
  
  OSStatus sts = AudioQueueSetProperty(audioQueue_, kAudioQueueProperty_MagicCookie, [magicCookie bytes], [magicCookie length]);

#if (CM_LOG_AUDIO == 1)  
  NSLog(@"AudioQueueSetProperty(%p, MagicCookie) [sts = %i (%c%c%c%c)]", audioQueue_, sts, STS2C(sts));
#endif
  
  sts; // prevent warning unused variable
}

- (AudioQueueBufferRef) allocBufferForFile:(CmAudioBufferFile *) bufferFile {
  
  AudioQueueBufferRef audioQueueBuffer = NULL;
  
  OSStatus sts = AudioQueueAllocateBuffer(audioQueue_, bufferFile.audioQueueBufferSize, &audioQueueBuffer);
  
#if (CM_LOG_AUDIO == 1)  
  NSLog(@"AudioQueueAllocateBuffer(%p) abuf=%p [sts = %i (%c%c%c%c)]", audioQueue_, audioQueueBuffer, sts, STS2C(sts));
#endif
  
  if (bufferFile.isVariableBitRate) {
    audioQueueBuffer->mUserData = calloc(sizeof(AudioStreamPacketDescription), bufferFile.numPacketsInAudioBuffer);
  }
  
  sts; // prevent warning unused variable
  
  return audioQueueBuffer;
}

- (void) freeBuffer:(AudioQueueBufferRef) audioQueueBuffer {
  
  if (audioQueueBuffer == NULL) {
    return;
  }
  
  if (audioQueueBuffer->mUserData) {
    free(audioQueueBuffer->mUserData);
    audioQueueBuffer->mUserData = NULL;
  }
  
  OSStatus sts = AudioQueueFreeBuffer(audioQueue_, audioQueueBuffer);
#if (CM_LOG_AUDIO == 1)  
  NSLog(@"AudioQueueFreeBuffer(%p) [sts = %i (%c%c%c%c)]", audioQueueBuffer, sts, STS2C(sts));
#endif
  
  sts; // prevent warning unused variable
}

- (void) enqueueBuffer:(AudioQueueBufferRef) audioQueueBuffer withByteCount:(UInt32) numBytes andPacketCount:(UInt32) packetsInBuffer {
  
  audioQueueBuffer->mAudioDataByteSize = numBytes;
	
  OSStatus sts = AudioQueueEnqueueBuffer(audioQueue_, audioQueueBuffer, 
                                         packetsInBuffer, 
                                         (AudioStreamPacketDescription *) audioQueueBuffer->mUserData);
#if (CM_LOG_AUDIO == 1)
  NSLog(@"AudioQueueEnqueueBuffer aq=%p, abuf=%p [sts = %i (%c%c%c%c)]", audioQueue_, audioQueueBuffer, sts, STS2C(sts));		
#endif
  
  sts; // prevent warning unused variable
}

#pragma mark AudioQueue callback

void audioQueueOutput(void *cmAudioQueue_, AudioQueueRef audioQueue, AudioQueueBufferRef audioQueueBuffer)
{
#if (CM_LOG_AUDIO == 1)  
  NSLog(@"audioQueueOutput: cmaq = %p; aq = %p; abuf= %p", cmAudioQueue_, audioQueue, audioQueueBuffer);
#endif
  
  CmAudioQueue * cmAudioQueue = (CmAudioQueue *) cmAudioQueue_;
  
  [cmAudioQueue.delegate audioQueue: cmAudioQueue fillBuffer: audioQueueBuffer];
}

@end