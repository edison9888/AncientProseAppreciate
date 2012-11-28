/*
 *  CmAudioOutput.m
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
#import "CmAudioInput.h"
#import "CmAudioQueue.h"
#import "CmAudioOutput.h"

static void audioQueueOutput(void * inUserData,
                             AudioQueueRef        aq,
                             AudioQueueBufferRef  abuf);


@interface CmAudioOutput (Internal)

@end

@implementation CmAudioOutput

@synthesize state = state_;
@synthesize delegate = delegate_;

- (id) initWithDelegate:(id<CmAudioOutputDelegate>) delegate {
  
  if (self = [super init]) {
    delegate_ = delegate;
    
    heartbeatTimer_ = [[NSTimer scheduledTimerWithTimeInterval: 5.0
                                                        target: self 
                                                      selector: @selector(onHeartbeat)
                                                      userInfo: nil
                                                       repeats: YES] retain];
    
    [self addObserver: self 
           forKeyPath: @"state" 
              options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context: NULL];    
  }
  
  return self;
}

- (void) dealloc {
  [heartbeatTimer_ invalidate];
  [heartbeatTimer_ release];
  [audioQueue_ release];
  [super dealloc];
}

- (void) onHeartbeat {
  
  //NSLog(@"output: heartbeat");
  
  if (state_ == kCmAudioOutput_Playing || state_ == kCmAudioOutput_Buffering) {
    if (currentPacket_ == lastPacket_) {    

      NSLog(@"output: heartbeat, no packet received... auto-stopping");
      
      [delegate_ outputRequestRestart: self];
      return;
    }
  }
  
  lastPacket_ = currentPacket_;
}

- (void) observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *)context {
	
	if ([keyPath isEqualToString: @"state"]) {
    static NSString * stateStrings[] = { @"stopped", @"buffering", @"playing" };
    
    NSLog(@"output: state is now %@", stateStrings[state_]);
  }
}

- (void) stop {
  [audioQueue_ stop];
  
  self.state = kCmAudioOutput_Stopped;
  
  [delegate_ outputStopped: self];

  [self resetAudio];
}
		
- (void) resetAudio {
  
  NSLog(@"output: reset audio");
  
  for (int i=0; i<kCmMaxAudioQueueBuffers; i++) {
    
    [audioQueue_ freeBuffer: audioQueueBuffer_[i]];
    
    audioQueueBuffer_[i] = NULL;
  }
  
  [audioQueue_ release];
  audioQueue_ = nil;
}

- (void) addBufferToFreeList:(AudioQueueBufferRef) audioQueueBuffer {
  bufferFreeList_[numBuffersInFreeList_++] = audioQueueBuffer;
}

#pragma mark CmAudioBufferFileDelegate

- (void) bufferFileHasData:(CmAudioBufferFile *) bufferFile {
#if (CM_FULL_LOG == 1)
  NSLog(@"output: buffer file has data");
#endif
  
  if (audioQueue_ == nil) {

    audioQueue_ = [[CmAudioQueue alloc] initWithAudioDescription: bufferFile.audioStreamDescription delegate: self];
    
    [audioQueue_ setMagicCookie: bufferFile.magicCookie];
        
    for (int i=0; i<kCmMaxAudioQueueBuffers; i++) {
      audioQueueBuffer_[i] = [audioQueue_ allocBufferForFile: bufferFile];
    }
  }
  
  if (state_ == kCmAudioOutput_Stopped) {
    for (int i=0; i<kCmMaxAudioQueueBuffers; i++) {
      bufferFreeList_[i] = audioQueueBuffer_[i];
    }
    
    numBuffersInFreeList_ = kCmMaxAudioQueueBuffers;    
    
    numBuffersToPreload_ = kCmNumAudioBuffersToPreload;    
    self.state = kCmAudioOutput_Buffering;
    [delegate_ outputBuffering: self];
  }
  
  while (numBuffersInFreeList_ > 0) {
    
    AudioQueueBufferRef audioQueueBuffer = bufferFreeList_[numBuffersInFreeList_ - 1];
    
    UInt32 numBytes = 0;
    UInt32 numPackets = 0;
    
    [bufferFile readPackets: audioQueueBuffer returningNumBytes: &numBytes andNumPackets: &numPackets];
    
    if (numPackets > 0) {
      currentPacket_ = bufferFile.currentPacket;
      
      BOOL discontinuity = [audioQueue_ hasDiscontinuityOccurred];
      
      if (discontinuity) {
        NSLog(@"*** output: audio stream discontinuity");
      }
    }
    else {     
      if ((state_ == kCmAudioOutput_Playing) && (numBuffersInFreeList_ == kCmMaxAudioQueueBuffers)) {
        
        numBuffersToPreload_ *= 2;
        
        if (numBuffersToPreload_ > kCmMaxAudioQueueBuffers) {
          [delegate_ outputFailed: self withError: @"Audio stream bandwidth too great for network. Please try another stream."];
          
          [self stop];
          return;
        }
        
        NSLog(@"output: preload threshold is now %u out of %u", numBuffersToPreload_, kCmMaxAudioQueueBuffers);
        
//        self.state = kCmAudioOutput_Buffering;
//        [delegate_ outputBuffering: self];
      }
  
      return;
    }
    
    bufferFreeList_[numBuffersInFreeList_--] = NULL;
    
    [audioQueue_ enqueueBuffer: audioQueueBuffer withByteCount: numBytes andPacketCount: numPackets];
    
    if (state_ == kCmAudioOutput_Buffering) {
      if (kCmMaxAudioQueueBuffers - numBuffersInFreeList_ > numBuffersToPreload_) {
        [audioQueue_ start];
        self.state = kCmAudioOutput_Playing;
        [delegate_ outputPlaying: self];
      }
    }
  }
}

- (void) bufferFileReset:(CmAudioBufferFile *) bufferFile {
}

- (void) bufferFileFailed:(CmAudioBufferFile *) bufferFile withError:(NSString *) errorMessage {
  [self stop];
  [delegate_ outputFailed: self withError: errorMessage];
}

#pragma mark CmAudioQueueDelegate

- (void) audioQueue:(CmAudioQueue *) audioQueue fillBuffer:(AudioQueueBufferRef) audioQueueBuffer {
#if (CM_FULL_LOG == 1)
  NSLog(@"output: audio queue fill buffer");
#endif
  
  [self addBufferToFreeList: audioQueueBuffer];
  
  [self bufferFileHasData: NULL];
}

- (void) audioQueueFailed:(CmAudioQueue *) audioQueue withError:(NSString *) errorMessage {
}

@end
