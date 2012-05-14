#import "PagedChooser.h"
#import "CGPointExtension.h"
#import "CCTouchDispatcher.h"
#import "CCActionInterval.h"

static CGFloat kMinScale = 0.7;

CGFloat clamp(CGFloat x, CGFloat a, CGFloat b) {
    if (x < a)
        return a;
    if (x > b)
        return b;
    return x;
}

CGFloat lerp(CGFloat t, CGFloat a, CGFloat b) {
    return a + (b - a) * t;
}

@interface PagedChooser ()

@property (nonatomic, assign) CGPoint originalPosition;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger pageCount;

- (void)updateScales;

@end

@implementation PagedChooser

@synthesize delegate, originalPosition, pageSize, currentPageIndex, pageCount;

- (id)initWithPages:(NSArray *)pages pageSize:(CGSize)thePageSize delegate:(id<PagedChooserDelegate>)theDelegate {
    self = [super init];
    
    if (self) {
        self.delegate = theDelegate;
        self.pageCount = pages.count;
        self.pageSize = thePageSize;
        
        CGFloat x = self.contentSize.width/2;
        for (NSUInteger i = 0; i < pages.count; ++i, x += thePageSize.width) {
            CCLayer *thisPage = [pages objectAtIndex:i];
            thisPage.anchorPoint = ccp(0.5, 0.5);
            thisPage.isRelativeAnchorPoint = YES;
            thisPage.position = ccp(x, self.contentSize.height/2);
            [self addChild:thisPage];
        }
        
        [self updateScales];        
    }
    
    return self;
}

- (CGFloat)scaleForPagePosition:(CGFloat)x {
    CGFloat midX = self.contentSize.width/2;
    return lerp(clamp(fabs(x - midX)/midX, 0.0, 1.0), 1.0, kMinScale);
}

- (CGFloat)scaleForPage:(CCLayer *)page {
    return [self scaleForPagePosition:page.position.x];
}

- (void)updateScales {
    CCLayer* page;
    CCARRAY_FOREACH(children_, page) {
        [[page.children objectAtIndex:0] setScale:[self scaleForPage:page]];
    }
}

- (void)onEnter {
    [super onEnter];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

- (void)onExit {
    [super onExit];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.visible) {
        CGPoint curr = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
        if (CGRectContainsPoint(self.boundingBox, curr)) {
            self.originalPosition = curr;
            return YES;
        }
    }
    return NO;
}

- (void)ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event {
    if (self.visible) {
        CGPoint curr = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
        CGPoint prev = [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:touch.view]];
        CGPoint delta = ccp(curr.x - prev.x, 0);
        
        CCLayer* page;
        CCARRAY_FOREACH(children_, page) {
            page.position = ccpAdd(page.position, delta);
            [[page.children objectAtIndex:0] setScale:[self scaleForPage:page]];
        }
    }        
}

- (void)animateIntoProperPositions {
    CGFloat pageWidth = self.pageSize.width;
    NSInteger currentPage = self.currentPageIndex;
    CGFloat midX = self.contentSize.width/2;

    int i = 0;
    CCLayer* page;
    CCARRAY_FOREACH(children_, page) {
        CGFloat newX = midX + (i - currentPage) * pageWidth;
        
        [page runAction:[CCMoveTo actionWithDuration:0.2 position:ccp(newX, page.position.y)]];
        [[page.children objectAtIndex:0] runAction:[CCScaleTo actionWithDuration:0.2 scale:[self scaleForPagePosition:newX]]];
         
        ++i;
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CCLayer* currentPage = [self.children objectAtIndex:self.currentPageIndex];
    CGFloat midX = self.contentSize.width/2;
    CGFloat halfPageWidth = self.pageSize.width/2;
    
    BOOL pageDidChange = YES;
    
    if (currentPage.position.x + halfPageWidth < midX) {
        self.currentPageIndex = MIN(self.currentPageIndex + 1, self.children.count - 1);
    } else if (currentPage.position.x - halfPageWidth > midX) {
        self.currentPageIndex = MAX(self.currentPageIndex - 1, 0);
    } else {
        pageDidChange = NO;
    }
    
    if (pageDidChange) {
        if (self.delegate) {
            [self.delegate page:self.currentPageIndex didBecomeCurrentInChooser:self];
        }
    }
    
    [self animateIntoProperPositions];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self animateIntoProperPositions];
}

- (void)makePageCurrent:(NSUInteger)index {
    self.currentPageIndex = MIN(self.pageCount - 1, MAX(0, index));
    [self animateIntoProperPositions];
}

@end