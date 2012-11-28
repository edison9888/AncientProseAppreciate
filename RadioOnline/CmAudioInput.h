/*
 *  CmAudioInput.h
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
#import "CmAudioStream.h"

@class CmAudioBufferFile;
@class CmAudioProtocol;
@class CmAudioInput;

@protocol CmAudioInputDelegate

- (void) inputConnected:(CmAudioInput *) input;
- (void) inputFinished:(CmAudioInput *) input;
- (void) inputFailed:(CmAudioInput *) input withError:(NSString *) message;
- (void) input:(CmAudioInput *) input hasMetadata:(NSString *) metadata forTag:(NSString *) tag;

@end

@interface CmAudioInput : NSObject <CmAudioStreamDelegate> {
 @private
  CmAudioStream *     stream_;
  NSDictionary *      streamParameters_;
  CmAudioProtocol *   protocol_;
  CmAudioBufferFile * bufferFile_;
  
  id<CmAudioInputDelegate> delegate_;
}

@property (nonatomic, readonly) CmAudioBufferFile * bufferFile;
@property (nonatomic, readonly) CmAudioStream *     stream;
@property (nonatomic, readonly) CmAudioProtocol *   protocol;
@property (nonatomic, assign)   id<CmAudioInputDelegate> delegate;

- (id) initWithDelegate:(id<CmAudioInputDelegate>) delegate;
- (void) startStreamingURL:(NSString *) urlStream withUserAgent:(NSString *) userAgent;
- (void) stopStreaming;

@end
