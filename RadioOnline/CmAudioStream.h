/*
 *  CmAudioStream.h
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

@class CmAudioStream;

typedef enum CmAudioStreamState {
  kCmAudioStreamState_Stopped = 0,
  kCmAudioStreamState_Stopping,
  kCmAudioStreamState_Streaming,
} CmAudioStreamState;

@protocol CmAudioStreamDelegate

- (void) streamConnected:(CmAudioStream *) stream withParameters:(NSDictionary *) parameters;
- (void) stream:(CmAudioStream *) stream receivedData:(NSData *) data;
- (void) streamFinished:(CmAudioStream *) stream;
- (void) streamFailed:(CmAudioStream *) stream withError:(NSString *) errorMessage;
- (void) stream:(CmAudioStream *) stream hasMetadata:(NSString *) metadata forTag:(NSString *) tag;

@end

@interface CmAudioStream : NSObject {
 @private
  NSString *                url_;
  NSURLConnection *         cnx_;
  CmAudioStreamState        state_;
  id<CmAudioStreamDelegate> delegate_; // weak reference
}

@property (nonatomic, readonly) NSString * url;
@property (nonatomic, assign)   id<CmAudioStreamDelegate> delegate;
@property (nonatomic, assign)   CmAudioStreamState state;

- (id) initWithDelegate:(id<CmAudioStreamDelegate>) delegate;

- (BOOL) startStreamingURL:(NSString *) url withParameters:(NSDictionary *) parameters;
- (void) stopStreaming;

@end
