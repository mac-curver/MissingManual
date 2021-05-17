#import <Cocoa/Cocoa.h>

@interface CircleView: NSView {
    NSPoint offset;
    double radius;
    float startingAngle;
    float angularVelocity;
    NSTextStorage *textStorage;
    NSLayoutManager *layoutManager;
    NSTextContainer *textContainer;
    NSTimer *timer;
    NSTimeInterval lastTime;
    NSPoint mouseDownLocation;
    //NSTrackingArea *trackingArea;
}


@property (weak) IBOutlet NSSlider *slider;

@property CGFloat floatValue;

@property (strong) IBOutlet NSTextField *angleAsText;
@property (strong) IBOutlet NSStepper *angleStepper;

// Standard view create/free methods

- (void)dealloc;

// Drawing
- (void)drawRect:(NSRect)rect;
- (BOOL)isOpaque;

// Event handling
- (void)mouseDown:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;

// Methods to set parameters
- (void)setColor:(NSColor *)color;
//- (void)setRadius:(float)distance;
- (void)setStartingAngle:(float)angle;
- (void)setAngularVelocity:(float)velocity;
- (void)setString:(NSString *)string;


// Custom methods for actions this view implements
/*
- (IBAction)takeColorFrom:(id)sender;
- (IBAction)takeStartingAngleFrom:(id)sender;
- (IBAction)takeAngularVelocityFrom:(id)sender;
- (IBAction)takeStringFrom:(id)sender;
- (IBAction)startAnimation:(id)sender;
- (IBAction)stopAnimation:(id)sender;
- (IBAction)toggleAnimation:(id)sender;
*/

// Method invoked by timer
- (void)performAnimation:(NSTimer *)aTimer;

@end
