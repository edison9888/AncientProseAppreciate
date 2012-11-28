/*
 *  CmAudioPlayer.h
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

typedef enum CmAudioPlayerState {
	kCmAudioPlayerState_Stopped = 0,
	kCmAudioPlayerState_Connecting = 1,
	kCmAudioPlayerState_Buffering = 2,
	kCmAudioPlayerState_Playing = 3,
	kCmAudioPlayerState_Stopping = 4,
	kCmAudioPlayerState_Restarting = 5,
} CmAudioPlayerState;

@class CmAudioPlayer;
@class CmAudioPlaylist;

@protocol CmAudioPlayerDelegate

- (void) player:(CmAudioPlayer *) player hasMetadata:(NSString *) metadata forTag:(NSString *) tag;
- (void) player:(CmAudioPlayer *) player failedWithError:(NSString *) message;

@end

@interface CmAudioPlayer : NSObject <CmAudioInputDelegate, CmAudioOutputDelegate> {
 @private
	int                 restartCount_;
	NSString *          restartError_;
	NSString *          userAgent_;
	NSString *          playURL_;
	int                 playlistIndex_;
	CmAudioPlaylist *   playlist_;
	CmAudioPlayerState  state_;
	CmAudioInput *      input_;
	CmAudioOutput *     output_;
	id<CmAudioPlayerDelegate>  delegate_;
}

@property (nonatomic, assign)   CmAudioPlayerState state;
@property (nonatomic, readonly) NSString *  playingURL;
@property (nonatomic, retain)   NSString *  restartError;

- (id) initWithDelegate:(id<CmAudioPlayerDelegate>) delegate andUserAgent:(NSString *) userAgent;

- (void) playURL:(NSString *) url;
- (void) stop;

@end
