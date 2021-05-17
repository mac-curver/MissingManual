#import "AudioApplication.h"

@implementation AudioApplication

#pragma mark --- my methods ---

+ (NSWindow *)	getLastFrontWindow
{
	NSWindow *myMainWindow;
	
	//myWindow = [[NSApplication sharedApplication] keyWindow];
	myMainWindow = [[NSApplication sharedApplication] mainWindow];
		
	
	return myMainWindow;
}

#pragma mark --- overwriting standard methods ---


- (BOOL)	validateMenuItem:(NSMenuItem*)anItem 
{
    if ([[anItem title] isEqualToString:@"Audio In"]) {
		return YES;
    }
    return [super validateMenuItem:anItem];
}

@end
