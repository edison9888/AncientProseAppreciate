/*
 *  CmAudioPlaylist_M3U.m
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
#import "CmAudioPlaylist_M3U.h"

@implementation CmAudioPlaylist_M3U

- (id) initWithString:(NSString *) contents {
  
  if (self = [super initWithURLString: nil]) {
    NSScanner * scanner = [NSScanner scannerWithString: contents];
    
    [scanner setCaseSensitive: YES];
    [scanner setCharactersToBeSkipped: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [scanner scanString: @"#EXTM3U" intoString: NULL];
    
    NSUInteger oldScanLocation = [scanner scanLocation];
    
    while (TRUE) {
      
      CmAudioPlaylistEntry * entry = [[[CmAudioPlaylistEntry alloc] init] autorelease];
      
      if ([scanner scanString: @"#EXTINF:" intoString: NULL]) {
        
        int streamLength = -1;
        
        if ([scanner scanInt: &streamLength]) {
          entry.streamLength = streamLength;
        }
        
        if ([scanner scanString: @"," intoString: NULL]) {
          
          NSString * streamTitle = nil;
          
          if ([scanner scanUpToCharactersFromSet: [NSCharacterSet newlineCharacterSet] intoString: &streamTitle]) {
            entry.streamTitle = streamTitle;
          }
        }
      }
        
      NSString * streamURL = nil;
        
      if ([scanner scanUpToCharactersFromSet: [NSCharacterSet newlineCharacterSet] intoString: &streamURL]) {
        entry.streamURL = streamURL;
      }
        
      if (streamURL != nil) {  
        [entries_ addObject: entry];
      }
      
      NSUInteger newScanLocation = [scanner scanLocation];
      
      if (newScanLocation == oldScanLocation) {
        break;
      }
      
      oldScanLocation = newScanLocation;
    }
  }
  
  return self;
}

@end
