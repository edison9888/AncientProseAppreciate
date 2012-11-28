/*
 *  CmAudioPlaylist.m
 *
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
#import "CmAudioPlaylistEntry.h"
#import "CmAudioPlaylist.h"
#import "CmAudioPlaylist_M3U.h"
#import "CmAudioPlaylist_PLS.h"

@implementation CmAudioPlaylist

@synthesize entries = entries_;

- (id) initWithURLString:(NSString *) urlString {
  
  if (self = [super init]) {
    entries_ = [[NSMutableArray alloc] init];
    
    if (urlString != nil) {
      CmAudioPlaylistEntry * entry = [[[CmAudioPlaylistEntry alloc ] init] autorelease];
     
      entry.streamURL = urlString;
      
      [entries_ addObject: entry];
    }
  }
  
  return self;
}

- (void) dealloc {
  [entries_ release];
  [super dealloc];
}

+ (CmAudioPlaylist *) audioPlaylistFromURL:(NSURL *) url {
  
  NSString * extension = [[[url resourceSpecifier] pathExtension] uppercaseString];
  
  Class playListClass = NSClassFromString([NSString stringWithFormat: @"CmAudioPlaylist_%@", extension]);
  
  if (playListClass == nil) {
    // NOT .pls or .m3u, so assume it's a simple stream...
    
    return [[[CmAudioPlaylist alloc] initWithURLString: [url description]] autorelease];
  }
  
  NSError * error = nil;
	
  NSString * contents = [NSString stringWithContentsOfURL: url encoding: NSUTF8StringEncoding error: &error];	
  
  if (contents == nil) 
    return nil;
  
  return [[[playListClass alloc] initWithString: contents] autorelease];
}

@end