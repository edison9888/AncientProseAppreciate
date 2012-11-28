//
//  iPhoneStreamingPlayerViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Matt Gallagher on 28/10/08.
//  Copyright Matt Gallagher 2008. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "iPhoneStreamingPlayerViewController.h"
#import "AudioStreamer.h"
#import "LevelMeterView.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@implementation iPhoneStreamingPlayerViewController
@synthesize downloadSourceField,musicurl,lvlMeter_in;
//功能:获取字符串的UTF8编码
//参数:好友名
//参数:返回账户名的字符串
//备注:11/3 lilin 添加
+(NSString *)EncodeUTF8Str:(NSString *)encodeStr
{  
    CFStringRef nonAlphaNumValidChars = CFSTR("![        DISCUZ_CODE_1        ]’()*+,-./:;=?@_~");          
    NSString *preprocessedString = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)encodeStr, CFSTR(""), kCFStringEncodingUTF8);          
    NSString *newStr = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)preprocessedString,NULL,nonAlphaNumValidChars,kCFStringEncodingUTF8) autorelease];  
    [preprocessedString release];  
    return newStr;          
}

//功能:获取字符串的GB2312编码
//参数:好友名
//参数:返回账户名的字符串
//备注:11/3 lilin 添加
+(NSString *)EncodeGB2312Str:(NSString *)encodeStr
{  
    CFStringRef nonAlphaNumValidChars = CFSTR("![        DISCUZ_CODE_1        ]’()*+,-./:;=?@_~");          
    
    NSString *preprocessedString = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)encodeStr, CFSTR(""), kCFStringEncodingGB_18030_2000);          
    
    NSString *newStr = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)preprocessedString,NULL,nonAlphaNumValidChars,kCFStringEncodingGB_18030_2000) autorelease];  
    
    [preprocessedString release];  
    return newStr;          
} 

//
// setButtonImage:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    image - the image to set on the play button.
//
- (void)setButtonImage:(UIImage *)image
{
	[button.layer removeAllAnimations];
	if (!image)
	{
		[button setImage:[UIImage imageNamed:@"playbutton.png"] forState:0];
	}
	else
	{
		[button setImage:image forState:0];
		
		if ([button.currentImage isEqual:[UIImage imageNamed:@"loadingbutton.png"]])
		{
			[self spinButton];
		}
	}
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
			removeObserver:self
			name:ASStatusChangedNotification
			object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer
{
	if (streamer)
	{
		return;
	}

	[self destroyStreamer];
	
	NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
			nil,
			(CFStringRef)downloadSourceField.text,
			NULL,
			NULL,
			kCFStringEncodingUTF8)
		autorelease];
    NSLog(@"%@",escapedValue);
	//NSURL *url = [NSURL URLWithString:@"http://ftp.jledu.gov.cn/kejian/glb/music/%E7%89%87%E7%89%87%E6%9E%AB%E5%8F%B6%E6%83%85.mp3"];
    //url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"蓝色" ofType:@"mp3"]];
    //url = [NSURL URLWithString:@"http://www.music-aa.cn/filesUp/2/4/%D5%C5%F6%A6%D3%B1-%C8%E7%B9%FB%D5%E2%BE%CD%CA%C7%B0%AE%C7%E9.mp3"];
    NSLog(@"----%@----",downloadSourceField.text);
    NSURL *url = [NSURL URLWithString:musicurl];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	progressUpdateTimer =
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(updateProgress:)
                                   userInfo:nil
                                    repeats:YES];
	levelMeterUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:.1 
															 target:self 
														   selector:@selector(updateLevelMeters:) 
														   userInfo:nil 
															repeats:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:ASStatusChangedNotification
                                               object:streamer];
#ifdef SHOUTCAST_METADATA
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(metadataChanged:)
                                                 name:ASUpdateMetadataNotification
                                               object:streamer];
#endif
}

//
// viewDidLoad
//
// Creates the volume slider, sets the default path for the local file and
// creates the streamer immediately if we already have a file at the local
// location.
//
- (void)viewDidLoad
{
	[super viewDidLoad];
	lvlMeter_in = [[AQLevelMeter alloc] initWithFrame:CGRectMake(100, 100, 240, 40)];
    [self.view addSubview:lvlMeter_in];
//    NSString* s = [NSString stringWithUTF8String:[@"http://mp3.sogou.com/down.so?t=%E0%D6%B4%F0&s=%D9%A9%D9%A9&w=02220600" UTF8String]];
//
//    s = [iPhoneStreamingPlayerViewController EncodeUTF8Str:@"李林"];
//    NSLog(@"%@",s);
//	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volumeSlider.bounds] autorelease];
//	[volumeSlider addSubview:volumeView];
//	[volumeView sizeToFit];
	
	[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
	
	levelMeterView = [[LevelMeterView alloc] initWithFrame:CGRectMake(10.0, 310.0, 300.0, 60.0)];
	[self.view addSubview:levelMeterView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	UIApplication *application = [UIApplication sharedApplication];
	if([application respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
		[application beginReceivingRemoteControlEvents];
	[self becomeFirstResponder]; // this enables listening for events
	// update the UI in case we were in the background
	NSNotification *notification = [NSNotification notificationWithName:ASStatusChangedNotification
                                                                 object:self];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

//
// spinButton
//
// Shows the spin button when the audio is loading. This is largely irrelevant
// now that the audio is loaded from a local file.
//
- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [button frame];
	button.layer.anchorPoint = CGPointMake(0.5, 0.5);
	button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];

	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];

	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];

	[CATransaction commit];
}

//
// animationDidStop:finished:
//
// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.
//
// Parameters:
//    theAnimation - the animation that rotated the button.
//    finished - is the animation finised?
//
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}

//
// buttonPressed:
//
// Handles the play/stop button. Creates, observes and starts the
// audio streamer when it is a play button. Stops the audio streamer when
// it isn't.
//
// Parameters:
//    sender - normally, the play/stop button.
//
- (IBAction)buttonPressed:(id)sender
{
	if ([button.currentImage isEqual:[UIImage imageNamed:@"playbutton.png"]])
	{
		[downloadSourceField resignFirstResponder];
		
		[self createStreamer];
		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
		[streamer start];
        [lvlMeter_in setAq:streamer.audioQueue];
	}
	else
	{
		[streamer stop];
        [lvlMeter_in setAq:nil];
	}
}

//
// sliderMoved:
//
// Invoked when the user moves the slider
//
// Parameters:
//    aSlider - the slider (assumed to be the progress slider)
//
- (IBAction)sliderMoved:(UISlider *)aSlider
{
	if (streamer.duration)
	{
		double newSeekTime = (aSlider.value / 100.0) * streamer.duration;
		[streamer seekToTime:newSeekTime];
	}
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[levelMeterView updateMeterWithLeftValue:0.0 
									  rightValue:0.0];
		[streamer setMeteringEnabled:NO];
		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
	}
	else if ([streamer isPlaying])
	{
		[streamer setMeteringEnabled:YES];
		[self setButtonImage:[UIImage imageNamed:@"stopbutton.png"]];
	}
	else if ([streamer isIdle])
	{
		[levelMeterView updateMeterWithLeftValue:0.0 
									  rightValue:0.0];
		[self destroyStreamer];
		[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
	}
}

#ifdef SHOUTCAST_METADATA
/** Example metadata
 * 
 StreamTitle='Kim Sozzi / Amuka / Livvi Franc - Secret Love / It's Over / Automatik',
 StreamUrl='&artist=Kim%20Sozzi%20%2F%20Amuka%20%2F%20Livvi%20Franc&title=Secret%20Love%20%2F%20It%27s%20Over%20%2F%20Automatik&album=&duration=1133453&songtype=S&overlay=no&buycd=&website=&picture=',

 Format is generally "Artist hypen Title" although servers may deliver only one. This code assumes 1 field is artist.
 */
- (void)metadataChanged:(NSNotification *)aNotification
{
	NSString *streamArtist;
	NSString *streamTitle;
	NSArray *metaParts = [[[aNotification userInfo] objectForKey:@"metadata"] componentsSeparatedByString:@";"];
	NSString *item;
	NSMutableDictionary *hash = [[NSMutableDictionary alloc] init];
	for (item in metaParts) {
		// split the key/value pair
		NSArray *pair = [item componentsSeparatedByString:@"="];
		// don't bother with bad metadata
		if ([pair count] == 2)
			[hash setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
	}

	// do something with the StreamTitle
	NSString *streamString = [[hash objectForKey:@"StreamTitle"] stringByReplacingOccurrencesOfString:@"'" withString:@""];
	
	NSArray *streamParts = [streamString componentsSeparatedByString:@" - "];
	if ([streamParts count] > 0) {
		streamArtist = [streamParts objectAtIndex:0];
	} else {
		streamArtist = @"";
	}
	// this looks odd but not every server will have all artist hyphen title
	if ([streamParts count] == 2) {
		streamTitle = [streamParts objectAtIndex:1];
	} else {
		streamTitle = @"";
	}
	NSLog(@"%@ by %@", streamTitle, streamArtist);

	// only update the UI if in foreground
	iPhoneStreamingPlayerAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	if (appDelegate.uiIsVisible) {
		metadataArtist.text = streamArtist;
		metadataTitle.text = streamTitle;
	}
}
#endif

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
			[positionLabel setText:
				[NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
					progress,
					duration]];
			[progressSlider setEnabled:YES];
			[progressSlider setValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		positionLabel.text = @"Time Played:";
	}
}


//
// updateLevelMeters:
//

- (void)updateLevelMeters:(NSTimer *)timer 
{
	
	if([streamer isMeteringEnabled]) 
    {
		[levelMeterView updateMeterWithLeftValue:[streamer averagePowerForChannel:0] 
									  rightValue:[streamer averagePowerForChannel:([streamer numberOfChannels] > 1 ? 1 : 0)]];

        [lvlMeter_in setAq:streamer.audioQueue];
	}
}


//
// textFieldShouldReturn:
//
// Dismiss the text field when done is pressed
//
// Parameters:
//    sender - the text field
//
// returns YES
//
- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
	[sender resignFirstResponder];
	[self createStreamer];
	return YES;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[self destroyStreamer];
	if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}
	if(levelMeterUpdateTimer) {
		[levelMeterUpdateTimer invalidate];
		levelMeterUpdateTimer = nil;
	}
	[levelMeterView release];
	[super dealloc];
}

#pragma mark Remote Control Events
/* The iPod controls will send these events when the app is in the background */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			if ([streamer isPlaying])
				[streamer stop];
			else {
				[self createStreamer];
				[streamer start];
			}
			break;
		case UIEventSubtypeRemoteControlPlay:
			[streamer start];
			break;
		case UIEventSubtypeRemoteControlPause:
			[streamer pause];
			break;
		case UIEventSubtypeRemoteControlStop:
			[streamer stop];
			break;
		default:
			break;
	}
}

@end
