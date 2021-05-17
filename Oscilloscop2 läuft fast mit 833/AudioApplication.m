#import "AudioApplication.h"

@implementation AudioApplication

#pragma mark --- my methods ---

+ (NSWindow *) getLastFrontWindow {
	NSWindow *myMainWindow;
	
	myMainWindow = NSApplication.sharedApplication.mainWindow;
		
	
	return myMainWindow;
}

#pragma mark --- overwriting standard methods ---


- (BOOL) validateMenuItem:(NSMenuItem*)anItem {
    if ([anItem.title isEqualToString:@"Audio In"]) {
		return YES;
    }
    return [super validateMenuItem:anItem];
}

/*
- (void)terminate:(id)sender {
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}
*/


@end
