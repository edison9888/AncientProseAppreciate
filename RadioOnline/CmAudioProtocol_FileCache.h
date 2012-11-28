/*
 *  CmAudioProtocol_Passthru.h
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
#import "CmAudioBufferFile.h"

@class CmAudioBuffer;

@interface CmAudioProtocol_FileCache : CmAudioProtocol <CmAudioBufferFileInDelegate> {
 @private  
  NSUInteger  totalBytesIn_;
  NSUInteger  totalBytesOut_;
  NSUInteger  packetNumberIn_;
  NSUInteger  packetNumberOut_;
  NSUInteger  totalBytesAvailable_;
  
  NSTimer *   readTimer_;
  
  NSString *  tmpDirectory_;
}

- (id) initWithBuffer:(CmAudioBuffer *) buffer;

@end
