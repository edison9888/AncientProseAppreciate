/*
 *  CmAudioBufferFile.h
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

#import "CmAudioBuffer.h"

@class CmAudioBufferFile;

@protocol CmAudioBufferFileInDelegate

- (void) bufferFile:(CmAudioBufferFile *) bufferFile consumedBytes:(UInt32) numBytes;

@end

@protocol CmAudioBufferFileDelegate 

- (void) bufferFileHasData:(CmAudioBufferFile *) bufferFile;
- (void) bufferFileReset:(CmAudioBufferFile *) bufferFile;
- (void) bufferFileFailed:(CmAudioBufferFile *) bufferFile withError:(NSString *) errorMessage;

@end

@interface CmAudioBufferFile : CmAudioBuffer {
 @private
	AudioFileID   audioFileID_;
	AudioStreamBasicDescription audioStreamDescription_;
    SInt64        currentPacket_;
    NSData *      magicCookie_;
    BOOL          isVariableBitRate_;
    UInt32        audioQueueBufferSize_;
    UInt32        maxPacketSize_;
    UInt32        numPacketsInAudioBuffer_;
  
  id<CmAudioBufferFileDelegate> delegate_; // weak reference
  id<CmAudioBufferFileInDelegate> delegateIn_; // weak reference
}
@property (nonatomic, assign)   SInt64        currentPacket;
@property (nonatomic, readonly) NSData *      magicCookie;
@property (nonatomic, readonly) BOOL          isVariableBitRate;
@property (nonatomic, readonly) UInt32        audioQueueBufferSize;
@property (nonatomic, readonly) UInt32        maxPacketSize;
@property (nonatomic, readonly) UInt32        numPacketsInAudioBuffer;

@property (nonatomic, assign)   id<CmAudioBufferFileDelegate> delegate;
@property (nonatomic, assign)   id<CmAudioBufferFileInDelegate> delegateIn;
@property (nonatomic, readonly) AudioStreamBasicDescription audioStreamDescription;

- (id) initWithSize:(NSUInteger) bufferSize;
- (void) readPackets:(AudioQueueBufferRef) audioQueueBuffer returningNumBytes:(UInt32 *) numBytes andNumPackets:(UInt32 *) numPackets;

@end
