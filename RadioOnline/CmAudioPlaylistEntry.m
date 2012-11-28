/*
 *  CmAudioPlaylistEntry.m
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

#import "CmAudioPlaylistEntry.h"

@implementation CmAudioPlaylistEntry

@synthesize streamTitle = streamTitle_;
@synthesize streamURL = streamURL_;
@synthesize streamLength = streamLength_;

- (id) init {
  
  if (self = [super init]) {
    streamLength_ = -1;
  }
  
  return self;
}

- (void) dealloc {
  [streamTitle_ release];
  [streamURL_ release];
  [super dealloc];
}

@end
