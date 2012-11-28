#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioQueue.h>
#import <AVFoundation/AVFoundation.h>

#include "MeterTable.h"

#define kPeakFalloffPerSec	.7
#define kLevelFalloffPerSec .8
#define kMinDBvalue -80.0

// A LevelMeter subclass which is used specifically for AVAudioPlayer objects
@interface CALevelMeter : UIView {
	AVAudioPlayer				*_player;
	NSArray						*_channelNumbers;
	NSArray						*_subLevelMeters;
	MeterTable					*_meterTable;//一个格子
	NSTimer						*_updateTimer;
	CGFloat						_refreshHz;//刷新频率
	BOOL						_showsPeaks;//
	BOOL						_vertical;
	BOOL						_useGL;
	
	CFAbsoluteTime				_peakFalloffLastFire;
}

- (void)setPlayer:(AVAudioPlayer*)v;

@property (readonly)	AVAudioPlayer *player; // The AVAudioPlayer object
@property				CGFloat refreshHz; // How many times per second to redraw
@property (retain)		NSArray *channelNumbers; // Array of NSNumber objects: The indices of the channels to display in this meter
@property				BOOL showsPeaks; // Whether or not we show peak levels
@property				BOOL vertical; // Whether the view is oriented V or H
@property				BOOL useGL; // Whether or not to use OpenGL for drawing
@end
