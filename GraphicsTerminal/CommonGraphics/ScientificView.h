////  ScientificView.h//  BodeDiagram////  Created by Heinz-J�rg on Sun Jun 1 2003.//  Copyright (c) 2003 Heinz-J�rg SCHR�DER. All rights reserved.#import <Cocoa/Cocoa.h>#import "MyCursor.h"@class GraphAxis;									                        // should be replaced by HorizontalGraphAxis and VerticalGraphAxis%%%%%@class HorizontalGraphAxis;	@class VerticalGraphAxis;@class ZoomAnimation;/* --- from: https://stackoverflow.com/questions/626898/how-do-i-create-delegates-in-objective-c - The approved answer is great, but if you're looking for a 1 minute answer try this: - MyClass.h file should look like this (add delegate lines with comments!)  #import <BlaClass/BlaClass.h> @class MyClass;                                            //define class, so protocol can see MyClass @protocol MyClassDelegate <NSObject>                       //define delegate protocol - (void) myClassDelegateMethod: (MyClass *) sender;        //define delegate method to be implemented within another class @end //end protocol @interface MyClass: NSObject {  } @property (nonatomic, weak) id <MyClassDelegate> delegate; //define MyClassDelegate as delegate @end  - MyClass.m file should look like this #import "MyClass.h" @implementation MyClass @synthesize delegate;                                      //synthesise  MyClassDelegate delegate - (void) myMethodToDoStuff {    [self.delegate myClassDelegateMethod:self];             //this will call the method implemented in your other class } @end  - To use your delegate in another class (UIViewController called MyVC in this case) MyVC.h: #import "MyClass.h" @interface MyVC:UIViewController <MyClassDelegate> {       //make it a delegate for MyClassDelegate }  - MyVC.m: myClass.delegate = self;                                   //set its delegate to self somewhere - Implement delegate method - (void) myClassDelegateMethod: (MyClass *) sender {    NSLog(@"Delegates are great!"); }*/typedef enum MaginficationMode {      None    , Magnify    , Horizontal    , Vertical    , N_MaginficationModes} MaginficationMode;// text position constants gives text vs point position typedef enum TextPosition {	  TopLeft = 1			//	, TopCenter				// (bottom right)     (bottom center)     (bottom left)	, TopRight				//         *******   *******   *    *   *******	, Left					//            *      *          *  *       *	, Center				//   (right)  *      **** (center)*		   *  (left)	, Right					//            *      *          *  *	   *	, BottomLeft			//            *		 *******   *    *      *	, BottomCenter			//  (top right)	       (top center)         (top left)	, BottomRight			//    , N_TextPositions    , Bottom = BottomCenter    , Top = TopCenter} TextPosition;typedef enum TriggerState {      NoTrigger    , WaitForLow    , WaitForHigh    , Triggered    , N_TriggerStates} TriggerState;typedef enum TriggerMode {      AutoTrigger    , NormalTrigger    , SingleTrigger    , N_TriggerModes} TriggerMode;static const int MaxSamples = 499;/// Scientific graphics Only zooms scales, but not lines or annotation/// Sometimes behaves strange as line thickness changes automatically@interface ScientificView: NSView <NSAnimationDelegate> {        IBOutlet HorizontalGraphAxis   *horizontalAxis;    IBOutlet VerticalGraphAxis	   *secondaryAxis;    IBOutlet VerticalGraphAxis	   *verticalAxis;    IBOutlet NSScrollView          *scrollView;    IBOutlet NSTextView            *scrollTextView;                                                                                // width = 1/xScale, height = 1/yScale    NSRect				            secondaryRect;				                // secondary window in user coordinates    NSRect			               *currentRect;				                // either windowRect or secondaryRect    NSPoint                         _scale;    NSPoint                         _offset;    	NSRect				            rubberbandRect;				                // for the selection	BOOL				            penIsDown;					                // for plot statement to indicate penstate	double				            symbolSize;					                // half of centered symbol size	NSPoint				            cursorPosition;				                // last point drawn	NSTrackingRectTag	            trackingTag;				                // for the mouse move (setBounds)	NSResponder			           *lastFirstResponder;	NSMutableDictionary            *attrs;            //    NSPoint                         zoomOffset;    NSPoint                         zoomScale;    NSPoint                         redPoint, greenPoint, yellowPoint;    NSPoint                         mouseDownLocation;    NSRect                          sourceRect;                                 ///< intermediate rectangles for the animated zoom operation    NSRect                          destinationRect;    ZoomAnimation                  *animate;    MyCursor                       *myCursor;                                   // state: zoom-in, zoom-out, drag, etc    double                          sinePhase;        NSRect                          homeRect;    NSRect                          mouseDownWindowRect;    MaginficationMode               magnificationMode;@public    NSRect                          windowRect;                                 // maximum window in user coordinates                                                                                // offset to origin    NSBezierPath                   *threePathes[9];    int                             index;    NSPoint                        *threeArrays[9];    double                          x;}@property(nonatomic, readwrite) double          scientificWidth;@property(nonatomic, readwrite) double          scientificHeight;@property(nonatomic, readwrite) double          widthMargin;@property(nonatomic, readwrite) double          heightMargin;@property(assign)               NSPoint         offset;@property(assign)               NSPoint         scale;@property(assign)               TriggerState    triggerState;@property(assign)               TriggerMode     triggerMode;@property(assign)               int             triggerPolarity;@property(assign)               int             triggerChannel;@property (weak) IBOutlet NSSegmentedControl *modeSelector;- (IBAction)            zoomIn:(id)sender;- (IBAction)            zoomOut:(id)sender;- (IBAction)            changeMode:(NSSegmentedControl *)sender;- (IBAction)            slider0:(NSSlider *)sender;- (IBAction)            slider1:(NSSlider *)sender;- (IBAction)            slider2:(NSSlider *)sender;- (void)                changeTriggerMode:(int) newTriggerMode;- (void)                readText:(NSString *)availableText;- (void)	            zoomInFromPoint:(NSPoint)mouseLoc;- (void)	            zoomOutFromPoint:(NSPoint)mouseLoc;- (void)	            zoomInToRect:(NSRect)mouseRect;- (void)                zoomInToRectFixed2:(NSRect)mouseRect;- (void)                panRect:(NSRect)sourceRect distanceX:(double)dx                                                   distanceY:(double)dy;- (void)	            choosePrimary;- (void)	            chooseSecondary;- (void)	            calcScaling;- (double)	            minX;									                // returns minimum x-value- (double)	            maxX;									                // returns maximum x-value- (NSRect)	            windowRect;								                // first window in user coordinates- (NSRect)	            secondaryRect;							                // secondary window in user coordinates- (void)	            setWindowRect:(NSRect)newRect;			                // first window in user coordinates- (void)	            setSecondaryRect:(NSRect)newRect;		                // secondary window in user coordinates- (void)                setHome;- (void)                animateHome;            - (void)	            penup;                                                  // stop drawing with plot- (void)	            pendown;                                                // start drawing with plot- (void)	            setLineWidth:(double)width;                             // set the line width of bezier path- (void)	            move:(double)dx :(double)dy;				            // move relative- (void)	            moveto:(double)x :(double)y;				            // move absolute- (void)	            draw:(double)dx :(double)dy;				            // draw relative- (void)	            drawto:(double)x :(double)y;				            // draw absolute- (void)	            plot:(double)dx :(double)dy;				            // plot relative- (void)	            plotto:(double)x :(double)y;				            // plot absolute- (void)	            setColor:(NSColor *)newColor;			                // set color for following outputs for text and stroke- (void)	            drawString:(NSString *)markString			            	alignment:(TextPosition)textAlignment;		        // draw string at cursor position- (void)	            setSymbolSize:(int)newSymbolSize;		                // set symbol size- (void)	            drawCenteredSymbol:(int)symbolCode;		                // draw a oval, glyph or rectangle- (void)                plotCircleAt:(NSPoint) point;                           // plot circle with radius = 20 at window coordinate point- (void)                plotCircleAt:(NSPoint) point radius:(double) radius;    // plot circle with radius at window coordinate point- (void)                appendText:(NSString *) text;- (void)                appendLine:(NSString *) text;            - (void)                doAnimation:(double) value;                             // zooms from sourceRect to destinationRect [0...1]- (void)                animateContents:(NSTimer *)timer;                       // animate the graphics contents@end