/*
 *  CmAudioSession.m
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
#import "CmAudioSession.h"

@implementation CmAudioSession

+ (void) initialize {
  
  OSStatus sts = AudioSessionInitialize(NULL, NULL, NULL, NULL);
#if (CM_LOG_AUDIO == 1)    
  NSLog(@"AudioSessionInitialize [sts = %i (%c%c%c%c)]", sts, STS2C(sts));
#endif

  // use kAudioSessionCategory_MediaPlayback to keep audio playing while the device is locked	
  UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
  sts = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
#if (CM_LOG_AUDIO == 1)    
  NSLog(@"AudioSessionSetProperty(MediaPlayback) [sts = %i (%c%c%c%c)]", sts, STS2C(sts));
#endif
  
  sts = AudioSessionSetActive(TRUE);
#if (CM_LOG_AUDIO == 1)    
  NSLog(@"AudioSessionSetActive(TRUE) [sts = %i (%c%c%c%c)]", sts, STS2C(sts));
#endif
  
  sts; // prevent unused variable warning
}

@end
