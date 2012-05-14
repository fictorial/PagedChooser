#import "PageIndicatorLayer.h"
#import "CCDrawingPrimitives.h"
#import "CCTouchDispatcher.h"

@implementation PageIndicatorLayer

@synthesize pageCount;
@synthesize activePageIndex;
@synthesize inactiveColor;
@synthesize activeColor;
@synthesize dotSize;
@synthesize delegate;
@synthesize touchesChangeActivePage;

- (id)init {
    self = [super init];
    
    if (self) {
        self.dotSize = 6 * CC_CONTENT_SCALE_FACTOR();
        self.activeColor = ccc4(255, 255, 255, 255);
        self.inactiveColor = ccc4(128, 128, 128, 255);
    }
    
    return self;
}

- (void)draw {
    float spaceSize = dotSize * 2;
    float allDotsWidth = spaceSize * (pageCount - 1);
    CGPoint point = CGPointMake(self.contentSize.width/2 - allDotsWidth/2, self.contentSize.height/2);

    // Disable for "square dots" else this renders round dots
    glEnable(GL_POINT_SMOOTH);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glPointSize(dotSize);
    
    for (NSUInteger i = 0; i < pageCount; ++i) {
        if (i == activePageIndex) {
            glColor4ub(activeColor.r, activeColor.g, activeColor.b, activeColor.a);
        } else {
            glColor4ub(inactiveColor.r, inactiveColor.g, inactiveColor.b, inactiveColor.a);
        }
        
        ccDrawPoint(point);
        point.x += spaceSize;
    }
}

#pragma mark - layer

- (void)onEnter {
    [super onEnter];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)onExit {
    [super onExit];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

#pragma mark - touch

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint curr = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    return self.visible && self.touchesChangeActivePage &&CGRectContainsPoint(self.boundingBox, curr);
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.touchesChangeActivePage) {
        CGPoint curr = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
        
        if (curr.x > self.contentSize.width/2) {
            self.activePageIndex = MIN(self.activePageIndex + 1, self.pageCount - 1);
        } else {
            self.activePageIndex = MAX(self.activePageIndex - 1, 0);
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(activePageIndexDidChangeFromTouchIn:)]) {
            [self.delegate activePageIndexDidChangeFromTouchIn:self];
        }
    }
}

@end
