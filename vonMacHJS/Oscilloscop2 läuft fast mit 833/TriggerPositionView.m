
#import		"TriggerPositionView.h"
#import 	"ScientificImage.h"													// can be removed!

@implementation TriggerPositionView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		startTrigger = 0;
		stopTrigger = self.bounds.size.width;
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSRect	triggerRect = NSMakeRect(startTrigger, rect.origin.y,
                                     stopTrigger-startTrigger, rect.size.height
                          );
	[NSColor.blackColor set];
	NSRectFill(triggerRect);
}

- (IBAction)setTriggerPosition:(id)sender
{
	startTrigger = [sender doubleValue];
	stopTrigger = self.bounds.size.width;
	[self setNeedsDisplay: YES];
}

@end
