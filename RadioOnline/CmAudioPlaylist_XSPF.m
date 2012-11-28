/*
 *  CmAudioPlaylist_XSPF.m
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
#import "CmAudioPlaylist_XSPF.h"

@implementation CmAudioPlaylist_XSPF

- (id) initWithString:(NSString *) contents {
  
  if (self = [super initWithURLString: nil]) {
    
    NSXMLParser * parser = [[[NSXMLParser alloc] initWithData: [contents dataUsingEncoding: NSUTF8StringEncoding]] autorelease];
    
    [parser setDelegate: self];
    
    [parser parse];
    
#if 0    
    for (int i=1; i<=numberOfEntries; i++) {
      CmAudioPlaylistEntry * entry = [[[CmAudioPlaylistEntry alloc] init] autorelease];
      
      entry.streamTitle = [playlistItems objectForKey: [NSString stringWithFormat: @"title%u", i]];
      entry.streamURL = [playlistItems objectForKey: [NSString stringWithFormat: @"file%u", i]];
      entry.streamLength = [[playlistItems objectForKey: [NSString stringWithFormat: @"length%u", i]] intValue];                   
      
      [entries_ addObject: entry];
    }
#endif    
  }
  
  return self;
}

#pragma mark NSXMLParser



@end
