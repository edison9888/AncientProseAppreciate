#import "CALevelMeter.h"

#import "LevelMeter.h"
#import "GLLevelMeter.h"

@interface CALevelMeter (CALevelMeter_priv)
- (void)layoutSubLevelMeters;
@end


@implementation CALevelMeter

@synthesize showsPeaks = _showsPeaks;
@synthesize vertical = _vertical;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_refreshHz = 1. / 60.;
		_showsPeaks = YES;
		_channelNumbers = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
		_vertical = NO;
		_useGL = YES;
		_meterTable = new MeterTable(kMinDBvalue);
		[self layoutSubLevelMeters];
	}
	return self;
}


- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		_refreshHz = 1. / 60.;
		_showsPeaks = YES;
		_channelNumbers = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
		_vertical = NO;
		_useGL = YES;
		_meterTable = new MeterTable(kMinDBvalue);
		[self layoutSubLevelMeters];
	}
	return self;
}


- (void)layoutSubLevelMeters
{
	int i;
	for (i=0; i<[_subLevelMeters count]; i++)
	{
		UIView *thisMeter = [_subLevelMeters objectAtIndex:i];
		[thisMeter removeFromSuperview];
	}
	[_subLevelMeters release];
	
	NSMutableArray *meters_build = [[NSMutableArray alloc] initWithCapacity:[_channelNumbers count]];
	
	CGRect totalRect;
	
	if (_vertical) totalRect = CGRectMake(0., 0., [self frame].size.width + 2., [self frame].size.height);
	else  totalRect = CGRectMake(0., 0., [self frame].size.width, [self frame].size.height + 2.);
	
	for (i=0; i<[_channelNumbers count]; i++)
	{
		CGRect fr;
		
		if (_vertical) {
			fr = CGRectMake(
							totalRect.origin.x + (((CGFloat)i / (CGFloat)[_channelNumbers count]) * totalRect.size.width), 
							totalRect.origin.y, 
							(1. / (CGFloat)[_channelNumbers count]) * totalRect.size.width - 2., 
							totalRect.size.height
							);
		} else {
			fr = CGRectMake(
							totalRect.origin.x, 
							totalRect.origin.y + (((CGFloat)i / (CGFloat)[_channelNumbers count]) * totalRect.size.height), 
							totalRect.size.width, 
							(1. / (CGFloat)[_channelNumbers count]) * totalRect.size.height - 2.
							);
		}
		
		LevelMeter *newMeter;

		if (_useGL) newMeter = [[GLLevelMeter alloc] initWithFrame:fr];
		else newMeter = [[LevelMeter alloc] initWithFrame:fr];
		
		newMeter.numLights = 30;
		newMeter.vertical = self.vertical;
		[meters_build addObject:newMeter];
		[self addSubview:newMeter];
		[newMeter release];
	}	
	
	_subLevelMeters = [[NSArray alloc] initWithArray:meters_build];
	
	[meters_build release];
}



- (void)_refresh
{
	BOOL success = NO;

	// if we have no queue, but still have levels, gradually bring them down
    
	if (_player == NULL)
	{
		CGFloat maxLvl = -1.;
		CFAbsoluteTime thisFire = CFAbsoluteTimeGetCurrent();
		// calculate how much time passed since the last draw
		CFAbsoluteTime timePassed = thisFire - _peakFalloffLastFire;
		for (LevelMeter *thisMeter in _subLevelMeters)
		{
			CGFloat newPeak, newLevel;
			newLevel = thisMeter.level - timePassed * kLevelFalloffPerSec;
			if (newLevel < 0.) newLevel = 0.;
			thisMeter.level = newLevel;
			if (_showsPeaks)
			{
				newPeak = thisMeter.peakLevel - timePassed * kPeakFalloffPerSec;
				if (newPeak < 0.) newPeak = 0.;
				thisMeter.peakLevel = newPeak;
				if (newPeak > maxLvl) maxLvl = newPeak;
			}
			else if (newLevel > maxLvl) maxLvl = newLevel;
			
			[thisMeter setNeedsDisplay];
		}
		// stop the timer when the last level has hit 0
		if (maxLvl <= 0.)
		{
			[_updateTimer invalidate];
			_updateTimer = nil;
		}
		
		_peakFalloffLastFire = thisFire;
		success = YES;
	} 
    else 
    {
		[_player updateMeters];
		for (int i=0; i<[_channelNumbers count]; i++)
		{
			NSInteger channelIdx = [(NSNumber *)[_channelNumbers objectAtIndex:i] intValue];
			LevelMeter *channelView = [_subLevelMeters objectAtIndex:channelIdx];
			
			if (channelIdx >= [_channelNumbers count]) goto bail;
			if (channelIdx > 127) goto bail;
			
			channelView.level = _meterTable->ValueAt([_player averagePowerForChannel:i]);
			if (_showsPeaks) channelView.peakLevel = _meterTable->ValueAt([_player peakPowerForChannel:i]);
			else
				channelView.peakLevel = 0.;
			[channelView setNeedsDisplay];
			success = YES;		
		}
	}
	
bail:
	
	if (!success)
	{
		for (LevelMeter *thisMeter in _subLevelMeters) { thisMeter.level = 0.; [thisMeter setNeedsDisplay]; }
		NSLog(@"ERROR: metering failed\n");
	}
}


- (void)dealloc
{
	[_updateTimer invalidate];
	[_channelNumbers release];
	[_subLevelMeters release];
	delete _meterTable;
	
	[super dealloc];
}


- (AVAudioPlayer*)player { return _player; }
- (void)setPlayer:(AVAudioPlayer*)v
{	
	if ((_player == NULL) && (v != NULL))//第一次初始化VolumeView 如：创建播放器 并准备播放时
	{
		if (_updateTimer) [_updateTimer invalidate];
		
		_updateTimer = [NSTimer 
						scheduledTimerWithTimeInterval:_refreshHz 
						target:self 
						selector:@selector(_refresh) 
						userInfo:nil 
						repeats:YES
						];
	} 
    else if ((_player != NULL) && (v == NULL)) //如暂停以后恢复播放
    {
		_peakFalloffLastFire = CFAbsoluteTimeGetCurrent();//取当前时间
	}
	
	_player = v;
	
	if (_player)
	{
		_player.meteringEnabled = YES;
		// now check the number of channels in the new queue, we will need to reallocate if this has changed
		if (_player.numberOfChannels != [_channelNumbers count])
		{
			NSArray *chan_array;
			if (_player.numberOfChannels < 2)
				chan_array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
			else
				chan_array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], nil];
            [self setChannelNumbers:chan_array];
			[chan_array release];				
		}
	} 
    else
    {
		for (LevelMeter *thisMeter in _subLevelMeters)
        {
			[thisMeter setNeedsDisplay];
//            4、layOutSubViews 可以在自己定制的视图中重载这个方法，用来调整子视图的尺寸和位置。 
//            5、UIView的setNeedsDisplay和setNeedsLayout方法。首先两个方法都是异步执行的。而setNeedsDisplay会调用自动调用drawRect方法，这样可以拿到UIGraphicsGetCurrentContext，就可以画画了。而setNeedsLayout会默认调用layoutSubViews，就可以处理子视图中的一些数据。
//            
//            宗上所诉，setNeedsDisplay方便绘图，而layoutSubViews方便出来数据
		}
	}
}

- (CGFloat)refreshHz { return _refreshHz; }
- (void)setRefreshHz:(CGFloat)v
{
	_refreshHz = v;
	if (_updateTimer)
	{
		[_updateTimer invalidate];
		_updateTimer = [NSTimer 
						scheduledTimerWithTimeInterval:_refreshHz 
						target:self 
						selector:@selector(_refresh) 
						userInfo:nil 
						repeats:YES
						];
	}
}


- (NSArray *)channelNumbers { return _channelNumbers; }
- (void)setChannelNumbers:(NSArray *)v
{
	[v retain];
	[_channelNumbers release];
	_channelNumbers = v;
	[self layoutSubLevelMeters];
}

- (BOOL)useGL { return _useGL; }
- (void)setUseGL:(BOOL)v
{
	_useGL = v;
	[self layoutSubLevelMeters];
}

@end
