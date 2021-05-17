#import		"OffsetPositionView.h"
#import 	"ScientificImage.h"													// can be removed!


@implementation OffsetPositionView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		startOffset = 0;
		stopOffset = [self bounds].size.width;
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSRect	offsetRect = NSMakeRect(rect.origin.x, startOffset, rect.size.height, stopOffset-startOffset);
	[[NSColor blackColor] set];
	NSRectFill(offsetRect);
}

- (IBAction)setOffsetPosition:(id)sender
{
	startOffset = [sender doubleValue];
	stopOffset = [self bounds].size.width;
	[self setNeedsDisplay: YES];
}

@end
