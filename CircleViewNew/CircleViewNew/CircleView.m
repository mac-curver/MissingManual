/*
 CircleView.m
 NSView subclass showing the use of the text system for drawing glyphs.

 Douglas Davidson

 Copyright (c) 2001 by Apple Computer, Inc., all rights reserved.
*/
/*
 IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. ("Apple") in
 consideration of your agreement to the following terms, and your use, installation, 
 modification or redistribution of this Apple software constitutes acceptance of these 
 terms.  If you do not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject to these 
 terms, Apple grants you a personal, non-exclusive license, under Apple�s copyrights in 
 this original Apple software (the "Apple Software"), to use, reproduce, modify and 
 redistribute the Apple Software, with or without modifications, in source and/or binary 
 forms; provided that if you redistribute the Apple Software in its entirety and without 
 modifications, you must retain this notice and the following text and disclaimers in all 
 such redistributions of the Apple Software.  Neither the name, trademarks, service marks 
 or logos of Apple Computer, Inc. may be used to endorse or promote products derived from 
 the Apple Software without specific prior written permission from Apple. Except as expressly
 stated in this notice, no other rights or licenses, express or implied, are granted by Apple
 herein, including but not limited to any patent rights that may be infringed by your 
 derivative works or by other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, 
 EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, 
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS 
 USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL 
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, 
 REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND 
 WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR 
 OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Cocoa/Cocoa.h>
#import "CircleView.h"

@implementation CircleView


@synthesize floatValue;

- (void) viewWillMoveToWindow:(NSWindow *)newWindow {
    // Setup a new tracking area when the view is added to the window.
    NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways)
                                                                  owner:self
                                                               userInfo:nil
                                   ];
    [self addTrackingArea:trackingArea];
}



-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

// Many of the methods here are similar to those in the simpler DotView example.
// See that example for detailed explanations; here we will discuss those
// features that are unique to CircleView. 

// CircleView draws text around a circle, using Cocoa's text system for
// glyph generation and layout, then calculating the positions of glyphs
// based on that layout, and using NSLayoutManager for drawing.


- (void) awakeFromNib {
    offset.x = 0;
    offset.y = 0;
    radius = 75;
    [_slider setDoubleValue:radius];
    startingAngle = M_PI_2;
    angularVelocity = M_PI_2;
    
    // First, we set default values for the various parameters.
    
    
    // Next, we create and initialize instances of the three
    // basic non-view components of the text system:
    // an NSTextStorage, an NSLayoutManager, and an NSTextContainer.
    textStorage = [[NSTextStorage alloc] initWithString:@"Here's to the crazy ones, the misfits, "
                   "the rebels, the troublemakers, the round pegs in the "
                   "square holes, the ones who see things differently."
                  ];
    layoutManager = [[NSLayoutManager alloc] init];
    textContainer = [[NSTextContainer alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    //[self startAnimation:self];
    
}




- (void) dealloc {
    [timer invalidate];
}



- (void) drawRect:(NSRect)rect {
    unsigned long glyphIndex;
    NSRange glyphRange;
    NSRect usedRect;
    
    NSPoint currentCenter;
    currentCenter.x = NSMidX(self.bounds);
    currentCenter.y = NSMidY(self.bounds);

    [[NSColor whiteColor] set];
    NSRectFill(self.bounds);
    
    // Note that usedRectForTextContainer: does not force layout, so it must 
    // be called after glyphRangeForTextContainer:, which does force layout.
    glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    usedRect = [layoutManager usedRectForTextContainer:textContainer];

    for (glyphIndex = glyphRange.location; glyphIndex < NSMaxRange(glyphRange); glyphIndex++) {
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        NSRect lineFragmentRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
        NSPoint viewLocation, layoutLocation = [layoutManager locationForGlyphAtIndex:glyphIndex];
        float angle, distance;
        NSAffineTransform *transform = [NSAffineTransform transform];
        
        // Here layoutLocation is the location (in container coordinates) where the glyph was laid out.
        layoutLocation.x += lineFragmentRect.origin.x;
        layoutLocation.y += lineFragmentRect.origin.y;
        
        // We then use the layoutLocation to calculate an appropriate position for the glyph
        // around the circle (by angle and distance, or viewLocation in rectangular coordinates).
        distance = radius + usedRect.size.height - layoutLocation.y;
        angle = startingAngle + layoutLocation.x / distance;
        
        viewLocation.x = currentCenter.x+offset.x + distance * sin(angle);
        viewLocation.y = currentCenter.y+offset.y + distance * cos(angle);
        
        // We use a different affine transform for each glyph, to position and rotate it
        // based on its calculated position around the circle.
        [transform translateXBy:viewLocation.x yBy:viewLocation.y];
        [transform rotateByRadians:-angle];
        
        // We save and restore the graphics state so that the transform applies only to this glyph.
        [context saveGraphicsState];
        [transform concat];
        // drawGlyphsForGlyphRange: draws the glyph at its laid-out location in container coordinates.
        // Since we are using the transform to place the glyph, we subtract the laid-out location here.
        [layoutManager drawGlyphsForGlyphRange:NSMakeRange(glyphIndex, 1) atPoint:NSMakePoint(-layoutLocation.x, -layoutLocation.y)];
        [context restoreGraphicsState];
    }
}

- (BOOL)isOpaque {
    return YES;
}

-(void) mouseEntered:(NSEvent *)theEvent {
    [[NSCursor openHandCursor] push];
}

-(void) mouseExited:(NSEvent *)theEvent {
    [NSCursor pop];
}

// DotView changes location on mouse up, but here we choose to do so
// on mouse down and mouse drags, so the text will follow the mouse.

- (void)mouseDown:(NSEvent *)event {
    mouseDownLocation = event.locationInWindow;
    mouseDownLocation.x -= offset.x;
    mouseDownLocation.y -= offset.y;
    [[NSCursor closedHandCursor] push];

}

- (void)mouseDragged:(NSEvent *)event {

    NSPoint dragLocation = event.locationInWindow;
    offset = NSMakePoint(dragLocation.x-mouseDownLocation.x, dragLocation.y-mouseDownLocation.y);
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
    [NSCursor pop];
}

// DotView uses action methods to set its parameters.  Here we have
// factored each of those into a method to set each parameter directly
// and a separate action method.

- (void)setColor:(NSColor *)color {
    // Text drawing uses the attributes set on the text storage rather
    // than drawing context attributes like the current color.
    [textStorage addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [textStorage length])];
    [self setNeedsDisplay:YES];
}


- (void)setStartingAngle:(float)angle {
    startingAngle = angle;
    [self setNeedsDisplay:YES];
}
    
- (void)setAngularVelocity:(float)velocity {
    angularVelocity = velocity;
    [self setNeedsDisplay:YES];
}
    
- (void)setString:(NSString *)string {
    [textStorage replaceCharactersInRange:NSMakeRange(0, [textStorage length]) withString:string];
    [self setNeedsDisplay:YES];
}

- (IBAction) setRadiusFrom:(NSSlider *)sender {
    radius = sender.doubleValue;
    [self setNeedsDisplay:YES];
}

- (IBAction)takeStartingAngleFrom:(id)sender {
    NSLog(@"%f", [sender doubleValue]);
    [self setStartingAngle:[sender doubleValue]];
}
- (IBAction)takeStartingAngleFromStepper:(id)sender {
    [self setStartingAngle:0.01*[sender doubleValue]];
}



- (IBAction)takeStringFrom:(id)sender {
    [self setString:[sender stringValue]];
}

- (IBAction)takeIbColorFrom:(NSColorWell *)sender {
    [self setColor:[sender color]];
}

- (IBAction)takeAngularVelocityFrom:(id)sender {
    [self setAngularVelocity:0.01*[sender intValue]];
}

- (void)startAnimation:(id)sender {
    [self stopAnimation:sender];
    
    // We schedule a timer with a 0 time interval so that it will be called
    // as often as possible.  In performAnimation: we determine exactly
    // how much time has elapsed and animate accordingly.
    //timer = [[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(performAnimation:) userInfo:nil repeats:YES] retain];
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(performAnimation:) userInfo:nil repeats:YES];
    
    // The next two lines make sure that animation will continue to occur
    // while modal panels are displayed and while event tracking is taking
    // place (for example, while a slider is being dragged).
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSModalPanelRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
    
    lastTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)stopAnimation:(id)sender {
    [timer invalidate];
    //[timer release];
    timer = nil;
}

- (IBAction)toggleAnimation:(id)sender {
    if (timer != nil) {
        [self stopAnimation:sender];
    } else {
        [self startAnimation:sender];
    }
}


- (void)performAnimation:(NSTimer *)aTimer {
    // We determine how much time has elapsed since the last animation,
    // and we advance the angle accordingly.
    NSTimeInterval thisTime = [NSDate timeIntervalSinceReferenceDate];
    [self setStartingAngle:startingAngle + angularVelocity * (thisTime - lastTime)];
    //[self setRadius:radius +0.01];
    lastTime = thisTime;
}

@end

