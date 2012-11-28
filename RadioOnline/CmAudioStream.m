/*
 *  CmAudioStream.m
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

#import "NSError+CmExtension.h"
#import "CmAudioCommon.h"
#import "CmAudioBuffer.h"
#import "CmAudioStream.h"

@interface CmAudioStream (Internal)

- (void) resetConnection;

@end

@implementation CmAudioStream

@synthesize delegate = delegate_;
@synthesize url = url_;
@synthesize state = state_;

- (id) initWithDelegate:(id<CmAudioStreamDelegate>) delegate {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"init: stream (%p)", self);  
#endif
  
  if (self = [super init]) {
    delegate_ = delegate;
  }
  
  return self;
}

- (void) dealloc {
#if (CM_LOG_ALLOC == 1)
  NSLog(@"dealloc: stream (%p)", self);
#endif
  
  [url_ release];
  
  [self resetConnection];

  [super dealloc];
}

- (BOOL) startStreamingURL:(NSString *) url withParameters:(NSDictionary *) parameters {
  
  if (state_ != kCmAudioStreamState_Stopped) {
    NSLog(@"stream: attempting to start streaming while in progress");
    return NO;
  }
  
  NSLog(@"stream: connecting to stream at %@", url);
  
  [url_ release];
  url_ = [url copy];

  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url_]
                                                            cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval: 5.0];
  
  [urlRequest setHTTPMethod: @"GET"];
 
  for (NSString * parameterKey in [parameters allKeys]) {
    NSString *parameterValue = [parameters objectForKey: parameterKey];
    
    [urlRequest addValue: parameterValue forHTTPHeaderField: parameterKey];
  }

  [cnx_ release];
  cnx_ = [[NSURLConnection connectionWithRequest: urlRequest delegate: self] retain];
 
  return YES;
}

- (void) stopStreaming {
  if (state_ != kCmAudioStreamState_Streaming) {
    return;
  }
  
  self.state = kCmAudioStreamState_Stopping;
}

#pragma mark NSURLConnection callbacks

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSHTTPURLResponse *) response {
  NSLog(@"stream: didReceiveResponse [cnx = %p]", connection);
  
  if (cnx_ != connection) {
    NSLog(@"*** stream: connection:didReceiveResponse: on old connection");
    return;
  }
  
  if ([response statusCode] != 200) {
    [delegate_ streamFailed: self withError: [NSString stringWithFormat: @"Audio stream connection failed. (%d)", [response statusCode]]];
    [connection cancel];
    return;
  }
  
  self.state = kCmAudioStreamState_Streaming;
  
  [delegate_ streamConnected: self withParameters: [response allHeaderFields]];
}

- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
#if (CM_FULL_LOG == 1) 
  NSLog(@"stream: didReceiveData [cnx = %p]", connection);
#endif
 
  if (cnx_ != connection) {
    NSLog(@"*** stream: connection:didReceiveData: on old connection");
    [connection cancel];
    return;
  }
  
  if (state_ == kCmAudioStreamState_Stopping) {
#if (CM_FULL_LOG == 1)    
    NSLog(@"stream: didReceiveData [cnx = %p], in stopping mode", connection);
#endif
    
    [self resetConnection];

    [delegate_ streamFinished: self];
    return;
  }
  
  [delegate_ stream: self receivedData: data];
}

- (void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
	NSLog(@"stream: didFailWithError [cnx = %p, err = %@]", connection, error);
  
  if (cnx_ != connection) {
    NSLog(@"*** stream: connection:didFailWithError: on old connection");
    return;
  }
  
  [self resetConnection];
  
  [delegate_ streamFailed: self withError: [error friendlyErrorMessage]];
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection {
  NSLog(@"stream: connectionDidFinishLoading [cnx = %p]", connection);

  if (cnx_ != connection) {
    NSLog(@"*** stream: connectionDidFinishLoading: on old connection");
    return;
  }
  
  self.state = kCmAudioStreamState_Stopped;
  
  [self resetConnection];
  
  [delegate_ streamFinished: self];
}

#pragma mark CmAudioStream (Internal)

- (void) resetConnection {
  NSLog(@"stream: reset connection");
  
  [cnx_ cancel];
  [cnx_ release];
  cnx_ = nil;
  
  self.state = kCmAudioStreamState_Stopped;
}

@end
