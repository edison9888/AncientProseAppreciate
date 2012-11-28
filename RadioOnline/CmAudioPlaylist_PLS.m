/*
 *  CmAudioPlaylist_PLS.m
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
#import "CmAudioPlaylist_PLS.h"

@implementation CmAudioPlaylist_PLS

- (id) initWithString:(NSString *) contents {
  
  if (self = [super initWithURLString: nil]) {
    
    NSScanner * scanner = [NSScanner scannerWithString: contents];
    
    [scanner setCaseSensitive: NO];
    [scanner setCharactersToBeSkipped: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![scanner scanString: @"[playlist]" intoString: NULL])
      return self;
  
    NSMutableDictionary * playlistItems = [NSMutableDictionary dictionary];
    
    while (TRUE) {
      NSString * key = nil;
      NSString * value = nil;
      
      if (![scanner scanUpToString: @"=" intoString: &key])
        break;
      
      if (![scanner scanString: @"=" intoString: NULL])
        break;
      
      if (![scanner scanUpToCharactersFromSet: [NSCharacterSet newlineCharacterSet] intoString: &value])
        break;

      [playlistItems setObject: value forKey: [key lowercaseString]];
    }
    
    int numberOfEntries = [[playlistItems objectForKey: @"numberofentries"] intValue];
    
    for (int i=1; i<=numberOfEntries; i++) {
      CmAudioPlaylistEntry * entry = [[[CmAudioPlaylistEntry alloc] init] autorelease];
      
      entry.streamTitle = [playlistItems objectForKey: [NSString stringWithFormat: @"title%u", i]];
      entry.streamURL = [playlistItems objectForKey: [NSString stringWithFormat: @"file%u", i]];
      entry.streamLength = [[playlistItems objectForKey: [NSString stringWithFormat: @"length%u", i]] intValue];                   
    
      [entries_ addObject: entry];
    }
  }
  
  return self;
}

@end
