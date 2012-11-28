/*
 *  CmAudioProtocol_SHOUTcast.m
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
#import "CmAudioBuffer.h"
#import "CmAudioProtocol_SHOUTcast.h"

@interface CmAudioProtocol_SHOUTcast (Internal)

- (void) sendHeaderMetadata:(NSString *) metadata forICYTag:(NSString *) icyTag;

@end

@implementation CmAudioProtocol_SHOUTcast

@synthesize totalBytes = totalBytes_;

- (id) initWithBuffer:(CmAudioBuffer *) buffer {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"init: protocol shoutcast (%p)", self);
#endif
  
  if (self = [super initWithBuffer: buffer]) {
    streamMetadata_ = [[NSMutableDictionary alloc] init];
  }
  
  return self;
}

- (void) dealloc {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"dealloc: protocol shoutcast (%p)", self);
#endif
  
  [streamMetadata_ release];
  [streamParameters_ release];
  [super dealloc];
}

+ (BOOL) isSHOUTcastStreamFromData:(NSData *) data andParameters:(NSDictionary *) parameters {
  
  for (NSString *key in [parameters allKeys]) {
  
    NSRange r = [[key lowercaseString] rangeOfString: @"icy-"];
    
    if (r.location == 0 && r.length == 4) {
      return YES;
    }
  }
  
  if ([data length] <= 3) {
    NSLog(@"*** protocol(SHOUTcast): initial header is too small");
    return NO;
  }
  
  return memcmp([data bytes], "ICY", 3) == 0;
}

- (void) reset {
  state_ = kCmAudioProtocol_SHOUTcastStateHeaderStart;
  
  [streamMetadata_ removeAllObjects];
  [streamParameters_ release]; streamParameters_ = nil;
  
  payloadByteCount_ = 0;
  totalBytes_ = 0;
  
  currentData_ = nil;
  currentBytes_ = nil;
  currentBytesLeft_ = 0;
  currentMetadataBytes_ = 0;
  currentPayloadBytesLeft_ = 0;
}

- (void) parseHeaderStart {
  
  if (currentBytesLeft_ < 4) {
    NSLog(@"*** protocol(SHOUTcast): not enough data left");
    [self reset];
    return;
  }
  
  if (strncasecmp(currentBytes_, "ICY 200 OK\r\n", 12) != 0) {
    
    // no signature, use the passed parameters
    
    for (NSString * nsKey in streamParameters_.allKeys) {
      NSString * nsValue = [streamParameters_ objectForKey: nsKey];
      
      nsKey = [nsKey lowercaseString];
      
#if (CM_FULL_LOG == 1)    
      NSLog(@"protocol(SHOUTcast): <header> %@ = %@", nsKey, nsValue);
#endif      
      
      [self sendHeaderMetadata: nsValue forICYTag: nsKey];

      [streamMetadata_ setObject: nsValue forKey: nsKey];
    }

    payloadByteCount_ = [[streamMetadata_ objectForKey: @"icy-metaint"] integerValue];
    
    buffer_.contentType = [streamMetadata_ objectForKey: @"content-type"];
    
    state_ = kCmAudioProtocol_SHOUTcastStatePayload;
    currentPayloadBytesLeft_ = payloadByteCount_;    
    
    return;
  }
  
  currentBytes_ += 12;
  currentBytesLeft_ -= 12; // ICY 200 OK\r\n
  state_ = kCmAudioProtocol_SHOUTcastStateHeader;
}

- (void) parseHeader {
  
  char * crlf = strnstr(currentBytes_, "\r\n", currentBytesLeft_);
  
  if (crlf == NULL) {
    NSLog(@"*** protocol(SHOUTcast): no <cr><lf> found");
    [self reset];
    return;
  }
  
  size_t keyValueBytes = crlf - currentBytes_;
  
  if (keyValueBytes == 0) {
#if (CM_FULL_LOG == 1)
    NSLog(@"protocol(SHOUTcast): <end of header>");
#endif
    
    payloadByteCount_ = [[streamMetadata_ objectForKey: @"icy-metaint"] integerValue];
    
    buffer_.contentType = [streamMetadata_ objectForKey: @"content-type"];
    
    state_ = kCmAudioProtocol_SHOUTcastStatePayload;
    currentPayloadBytesLeft_ = payloadByteCount_;
  }
  else {
    const char * key   = currentBytes_;
    const char * value = 0;
    
    char * colon = strnstr(key, ":", keyValueBytes);
    
    if (colon) {
      *colon = 0;
      value = colon + 1;
      *crlf = 0;
    }
    
    NSString * nsKey = [[NSString stringWithUTF8String: key] lowercaseString];
    NSString * nsValue = [[NSString stringWithUTF8String: value] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
#if (CM_FULL_LOG == 1)    
    NSLog(@"protocol(SHOUTcast): <header> %@ = %@", nsKey, nsValue);
#endif
    
    [self sendHeaderMetadata: nsValue forICYTag: nsKey];
	  @try {		  
		  [streamMetadata_ setObject: nsValue forKey: nsKey];
	  }
	  @catch (NSException * e) {
		  
		  NSLog(@"streamMetadata_ setObject exception");
	  }
	  @finally {
		  
	  }
        
  }
  
  keyValueBytes += 2; // next location after <cr><lf>
  
  currentBytesLeft_ -= keyValueBytes;
  currentBytes_ += keyValueBytes;
}

- (void) sendHeaderMetadata:(NSString *) metadata forICYTag:(NSString *) icyTag {

  NSString * tag = nil;
  NSString * value = nil;
  
  icyTag = [icyTag lowercaseString];
  
  if ([icyTag isEqualToString: @"icy-name"]) {
    tag   = kCmMetadata_StreamName;
    value = metadata;
  }
  else if ([icyTag isEqualToString: @"icy-genre"]) {
    tag   = kCmMetadata_StreamGenre;
    value = metadata;
  }
  else if ([icyTag isEqualToString: @"icy-url"]) {
    tag   = kCmMetadata_StreamUrl;
    value = metadata;
  }
  else if ([icyTag isEqualToString: @"content-type"]) {
    tag   = kCmMetadata_StreamContentType;
    value = [metadata lowercaseString];
  }
  else if ([icyTag isEqualToString: @"icy-br"]) {
    tag   = kCmMetadata_StreamBitrate;
    value = [NSString stringWithFormat: @"%@ kbps", metadata];
  }  
  else {
    return;
  }
  
  [delegate_ stream: currentStream_ hasMetadata: value forTag: tag];
}

- (void) parseMetadataLength {
  
  uint8_t metadataLengthByte = *currentBytes_;
  
  size_t metadataBytes = metadataLengthByte * 16;
  
  currentBytes_++;
  currentBytesLeft_--;
  
  currentMetadataBytes_ = metadataBytes;
  rawMetadataBytes_ = 0;
  
  if (metadataBytes == 0) {
    currentPayloadBytesLeft_ = payloadByteCount_;    
    state_ = kCmAudioProtocol_SHOUTcastStatePayload;
  }
  else {
    state_ = kCmAudioProtocol_SHOUTcastStateMetadata;
  }

#if (CM_FULL_LOG == 1)      
  NSLog(@"protocol(SHOUTcast): <metadata length = %u>", currentMetadataBytes_);
#endif
}

- (void) parseMetadata {
  
  if (currentMetadataBytes_ > currentBytesLeft_) {
    memcpy(rawMetadata_ + rawMetadataBytes_, currentBytes_, currentBytesLeft_);
    rawMetadataBytes_ += currentBytesLeft_;
    currentMetadataBytes_ -= currentBytesLeft_;
    currentBytesLeft_ = 0;
    return;
  }
  
  if (currentMetadataBytes_ > 0) {
    
    memcpy(rawMetadata_ + rawMetadataBytes_, currentBytes_, currentMetadataBytes_);
    rawMetadata_[rawMetadataBytes_ + currentMetadataBytes_] = 0;
    
    char key[4096];
    char value[4096];
    
    char * rawMetadata = rawMetadata_;
    
    while (rawMetadata < (rawMetadata_ + sizeof(rawMetadata_))) {
      int n = sscanf(rawMetadata, "%[^=]=%[^;];", key, value);
      
      if (n != 2) {
        break;
      }
      
      value[strlen(value) - 1] = 0; // remove final apostrophe
      
      rawMetadata += strlen(key) + strlen(value) + 3; // ='';

      NSString * nsKey = [NSString stringWithUTF8String: key];
      NSString * nsValue = [NSString stringWithUTF8String: &value[1]]; // remove leading apostrophe
 
#if (CM_FULL_LOG == 1)      
      NSLog(@"protocol(SHOUTcast): <metadata> %@ = %@", nsKey, nsValue);
#endif
      
      if (nsValue == nil) {
        nsValue = @"";
      }
      
      [delegate_ stream: currentStream_ hasMetadata: nsValue forTag: nsKey];

      [streamMetadata_ setObject: nsValue forKey: nsKey];
    }
    
    currentBytes_ += currentMetadataBytes_;
    currentBytesLeft_ -= currentMetadataBytes_;
    
    currentMetadataBytes_ = 0;
  }
  
  currentPayloadBytesLeft_ = payloadByteCount_;
  state_ = kCmAudioProtocol_SHOUTcastStatePayload;
}

- (void) parsePayload {
  
  if (payloadByteCount_ == 0) {
    [buffer_ addData: [NSData dataWithBytes: currentBytes_ length: currentBytesLeft_]];
    currentBytesLeft_ = 0;
    return;
  }
  
  size_t availablePayloadBytes = MIN(currentBytesLeft_, currentPayloadBytesLeft_);
  
  [buffer_ addData: [NSData dataWithBytes: currentBytes_ length: availablePayloadBytes]];
  
  currentBytes_ += availablePayloadBytes;
  currentBytesLeft_ -= availablePayloadBytes;
  currentPayloadBytesLeft_ -= availablePayloadBytes;
  
  if (currentPayloadBytesLeft_ == 0) {
#if (CM_FULL_LOG == 1)    
    NSLog(@"protocol(SHOUTcast): <end of payload>");
#endif
    
    state_ = kCmAudioProtocol_SHOUTcastStateMetadataLength;
  }
}

#pragma mark CmAudioStreamDelegate

- (void) streamConnected:(CmAudioStream *) stream withParameters:(NSDictionary *) streamParameters {  
  NSLog(@"protocol(SHOUTcast): stream connected");
  
  [self reset];

  streamParameters_ = [streamParameters retain];
}

- (void) stream:(CmAudioStream *) stream receivedData:(NSData *) data {
#if (CM_FULL_LOG == 1)  
  NSLog(@"protocol(SHOUTcast): stream received data");
#endif
  
  currentStream_ = stream;
  currentData_ = data;
  currentBytes_ = [currentData_ bytes];
  currentBytesLeft_ = [currentData_ length];
  
  while (currentBytesLeft_ > 0) {
    
    switch (state_) {
      case kCmAudioProtocol_SHOUTcastStateHeaderStart:
        [self parseHeaderStart];
        break;
        
      case kCmAudioProtocol_SHOUTcastStateHeader:
        [self parseHeader];
        break;
        
      case kCmAudioProtocol_SHOUTcastStateMetadataLength:
        [self parseMetadataLength];
        break;
        
      case kCmAudioProtocol_SHOUTcastStateMetadata:
        [self parseMetadata];
        break;
        
      case kCmAudioProtocol_SHOUTcastStatePayload:
        [self parsePayload];
        break;
    }
  }
}

@end