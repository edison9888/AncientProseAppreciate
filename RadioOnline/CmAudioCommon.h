/*
 *  CmAudioCommon.h
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

#import <sys/stat.h>
#import <sys/types.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#undef CM_LOG_AUDIO
#undef CM_FULL_LOG

#define CM_LOG_AUDIO 0
#define CM_LOG_ALLOC 0
#define CM_FULL_LOG 0

#define STS2C(x) ((x&0xff000000)>>24), ((x&0x00ff0000)>>16), ((x&0x0000ff00)>>8), (x&0x000000ff)

#define kCmAudioVersion             "1.2"
#define kCmPlayerMaxRetries         30
#define kCmMinBufferSeconds         3

#define kCmAudioBufferSize          (1<<20)
#define kCmAudioQueueBufferSize     (1<<12)
#define kCmNumAudioBuffersToPreload 8
#define kCmMaxAudioQueueBuffers     32

#define kCmMetadata_StreamName        @"StreamName"
#define kCmMetadata_StreamGenre       @"StreamGenre"
#define kCmMetadata_StreamUrl         @"StreamUrl"
#define kCmMetadata_StreamBitrate     @"StreamBitrate"
#define kCmMetadata_StreamTitle       @"StreamTitle"
#define kCmMetadata_StreamContentType @"Content-Type"
#define kCmMetadata_StreamIdNum       @"StreamIdNum"

