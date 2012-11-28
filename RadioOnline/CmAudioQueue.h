/*
 *  CmAudioQueue.h
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

@class CmAudioBufferFile;
@class CmAudioQueue;

@protocol CmAudioQueueDelegate 

- (void) audioQueue:(CmAudioQueue *) audioQueue fillBuffer:(AudioQueueBufferRef) audioQueueBuffer;
- (void) audioQueueFailed:(CmAudioQueue *) audioQueue withError:(NSString *) errorMessage;

@end

@interface CmAudioQueue : NSObject {
  AudioQueueRef             audioQueue_;
  AudioQueueTimelineRef     timeline_;
  id<CmAudioQueueDelegate>  delegate_; // weak reference
}

@property (nonatomic, assign) id<CmAudioQueueDelegate> delegate;

- (id) initWithAudioDescription:(AudioStreamBasicDescription) audioStreamDescription delegate:(id<CmAudioQueueDelegate>) delegate;

- (void) start;
- (void) stop;

- (void) setMagicCookie:(NSData *) magicCookie;
- (BOOL) hasDiscontinuityOccurred;

- (AudioQueueBufferRef) allocBufferForFile:(CmAudioBufferFile *) bufferFile;
- (void) freeBuffer:(AudioQueueBufferRef) audioQueueBuffer;
- (void) enqueueBuffer:(AudioQueueBufferRef) audioQueueBuffer withByteCount:(UInt32) numBytes andPacketCount:(UInt32) packetsInBuffer;

@end
