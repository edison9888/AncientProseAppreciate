/*
 *  CmAudioProtocol_SHOUTcast.h
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

#import "CmAudioProtocol.h"

@class CmAudioStream;

#define kSHOUTcast_MaxMetadataBytes (256<<4) /* 4096 */

typedef enum CmAudioProtocol_SHOUTcastState {
  kCmAudioProtocol_SHOUTcastStateHeaderStart = 0,
  kCmAudioProtocol_SHOUTcastStateHeader,
  kCmAudioProtocol_SHOUTcastStateMetadataLength,
  kCmAudioProtocol_SHOUTcastStateMetadata,
  kCmAudioProtocol_SHOUTcastStatePayload,
} CmAudioProtocol_SHOUTcastState;

@interface CmAudioProtocol_SHOUTcast : CmAudioProtocol {
 @private
  CmAudioProtocol_SHOUTcastState  state_;
  
  UInt64          totalBytes_;
  CmAudioStream * currentStream_;
  NSData *        currentData_;
  const char *    currentBytes_;
  size_t          currentBytesLeft_;
  size_t          currentMetadataBytes_;
  size_t          currentPayloadBytesLeft_;
  size_t          payloadByteCount_;
  char            rawMetadata_[kSHOUTcast_MaxMetadataBytes];
  size_t          rawMetadataBytes_;
  
  NSDictionary *        streamParameters_;
  NSMutableDictionary * streamMetadata_;
}

@property (nonatomic, readonly) UInt64 totalBytes;

+ (BOOL) isSHOUTcastStreamFromData:(NSData *) data andParameters:(NSDictionary *) parameters;

- (id)    initWithBuffer:(CmAudioBuffer *) buffer;
- (void)  reset;

@end
