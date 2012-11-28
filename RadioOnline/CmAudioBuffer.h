/*
 *  CmAudioBuffer.h
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

@class CmAudioBuffer;

@interface CmAudioBuffer : NSObject {
 @protected
    NSString *  contentType_;
	UInt8 *     buffer_;
	UInt32      numBufferBytes_;
	UInt32      minDataAmount_;
	SInt64      inTotal_;
    SInt64      outTotal_;
    time_t      streamStartTime_;
    SInt64      lastReportBytes_;
}

@property (nonatomic, readonly) SInt64 inTotal;
@property (nonatomic, retain)   NSString * contentType;

- (id)    initWithSize:(UInt32) numBytes;
- (void)  reset;
- (void)  addData:(NSData *) data;

- (UInt32)  dataCount;
- (UInt32)  copyDataIntoBuffer:(UInt8 *) outBuffer atPosition:(UInt64) posTotal forCount:(UInt32) numBytes;

@end
