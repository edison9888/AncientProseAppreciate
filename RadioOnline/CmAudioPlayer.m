/*
 *  CmAudioPlayer.m
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
#import "CmAudioInput.h"
#import "CmAudioOutput.h"
#import "CmAudioPlaylist.h"
#import "CmAudioPlaylistEntry.h"
#import "CmAudioPlayer.h"

@implementation CmAudioPlayer

@synthesize state = state_;
@synthesize restartError = restartError_;

- (id) initWithDelegate:(id<CmAudioPlayerDelegate>) delegate andUserAgent:(NSString *) userAgent {
  
  if (self = [super init]) {    
    input_  = [((CmAudioInput *) [CmAudioInput alloc]) initWithDelegate: self];
    output_ = [((CmAudioOutput *) [CmAudioOutput alloc]) initWithDelegate: self];
    userAgent_ = [userAgent retain];
    
    delegate_ = delegate;
    
    [self addObserver: self 
           forKeyPath: @"state" 
              options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context: NULL]; 
  }
  
  return self;
}

- (void) dealloc {
  [userAgent_ release];
  [restartError_ release];
  [playURL_ release];
  [playlist_ release];
  [output_ release];
  [input_ release];
  [super dealloc];
}

- (void) observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *)context {
	
	if ([keyPath isEqualToString: @"state"]) {
    
    static NSString * stateNames[] = { @"STOPPED", @"CONNECTING", @"BUFFERING", @"PLAYING", @"STOPPING", @"RESTARTING" };
    
    NSLog(@"player: %@", stateNames[state_]);
	} 
}  


- (void) synchronizeStopAndRestart {
  
  NSLog(@"player: synchronize stop (and restart)");

  BOOL inputStopped = (input_.stream.state == kCmAudioStreamState_Stopped);
  BOOL outputStopped = (output_.state == kCmAudioOutput_Stopped);

  if (!inputStopped) {
    NSLog(@"player: input not stopped... stopping");
	 
    [input_ stopStreaming];	  
  }
  
  if (!outputStopped) {
    NSLog(@"player: output not stopped... stopping");
    [output_ stop];
  }	
	
int i=0;
do {		  
    inputStopped = (input_.stream.state == kCmAudioStreamState_Stopped);
    outputStopped = (output_.state == kCmAudioOutput_Stopped);
	
    if (inputStopped && outputStopped) {
		
      if (state_ != kCmAudioPlayerState_Stopped) {
        self.state = kCmAudioPlayerState_Stopped;
      }
      
      break;
    }
	NSLog(@"i=%d",i++);
	if(i<20) break;
    
  } while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.25, YES));
  
	
  NSLog(@"player: both input and output stopped (restart count = %u)", restartCount_);
  
  BOOL playAgain = NO;
  
  if (restartCount_ == 0) {
    // do we have another playlist item?
    if (playlistIndex_ < playlist_.entries.count - 1) {
      NSLog(@"player: switching to next playlist entry");
      playlistIndex_++;
      playAgain = YES;
    }
  }
  else {
    NSLog(@"player: restarting %d", restartCount_);
    restartCount_--;
   
    self.state = kCmAudioPlayerState_Restarting;
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, YES); // wait a sec
    
    playAgain = YES;
  }
	

  if (playAgain) {
    NSLog(@"player: replay");

    [input_ startStreamingURL: [self playingURL] withUserAgent: userAgent_];
  }
  else if (restartError_) {
    NSLog(@"player: restart error [%@]", restartError_);
    [delegate_ player: self failedWithError: restartError_];
    self.restartError = nil;
  }
}


- (void) playURL:(NSString *) playURL {

  if (playURL == nil)
    return;
  
  NSLog(@"player: playURL (%@)", playURL);
  
  if (state_ != kCmAudioPlayerState_Stopped)
    return;
  
  [playURL_ release];
  playURL_ = [playURL retain];
  
  playlistIndex_ = 0;
  
  [playlist_ release];
  playlist_ = [[CmAudioPlaylist audioPlaylistFromURL: [NSURL URLWithString: playURL]] retain];
  
  if ((playlist_ == nil) || (playlist_.entries.count == 0)) {
    [delegate_ player: self failedWithError: @"No streams found in the play list."];
    return;
  }
	
  [output_ resetAudio];
  
  self.state = kCmAudioPlayerState_Connecting;
	
  [input_ startStreamingURL: [self playingURL] withUserAgent: userAgent_];
		
}

- (void) stop {
  NSLog(@"player: stop");
  
  if (state_ == kCmAudioPlayerState_Stopped)
    return;
  
  self.state = kCmAudioPlayerState_Stopping;
  
  restartCount_ = 0;
  self.restartError = nil;
  [self synchronizeStopAndRestart];
}

- (NSString *) playingURL {
  
  CmAudioPlaylistEntry * entry = [playlist_.entries objectAtIndex: playlistIndex_];
	
  return entry.streamURL;
}

#pragma mark CmAudioInputDelegate

- (void) inputConnected:(CmAudioInput *) input {
  NSLog(@"player: input connected");
  
  input.bufferFile.delegate = output_;
  
  self.state = kCmAudioPlayerState_Buffering;
}

- (void) inputFinished:(CmAudioInput *) input {
  NSLog(@"player: input finished");
  
  [self synchronizeStopAndRestart];
}

- (void) inputFailed:(CmAudioInput *) input withError:(NSString *) message {
  NSLog(@"player: input failed");
  
  self.restartError = message;
  
  [self synchronizeStopAndRestart];
}

- (void) input:(CmAudioInput *) input hasMetadata:(NSString *) metadata forTag:(NSString *) tag {
  NSLog(@"player: stream metadata tag(%@) metadata(%@)", tag, metadata);

  [delegate_ player: self hasMetadata: metadata forTag: tag];
}

#pragma mark CmAudioOutputDelegate

- (void) outputBuffering:(CmAudioOutput *) output {
  NSLog(@"player: output buffering");
  
  self.state = kCmAudioPlayerState_Buffering;
}

- (void) outputPlaying:(CmAudioOutput *) output {
  NSLog(@"player: output playing");
  
  self.state = kCmAudioPlayerState_Playing;
  
  self.restartError = nil;
  restartCount_ = kCmPlayerMaxRetries;  
}

- (void) outputStopped:(CmAudioOutput *) output {
  NSLog(@"player: output stopped");
  
  [self synchronizeStopAndRestart];
  
  [input_ stopStreaming];
}

- (void) outputRequestRestart:(CmAudioOutput *) output {
  NSLog(@"player: output request restart");
  
  restartCount_ = kCmPlayerMaxRetries;
  
  [self synchronizeStopAndRestart];
}

- (void) outputFailed:(CmAudioOutput *) output withError:(NSString *) message {
  [delegate_ player: self failedWithError: message];
}

@end