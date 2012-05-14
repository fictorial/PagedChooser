#import "HelloWorldLayer.h"
#import "PageIndicatorLayer.h"

static float kPageIndicatorHeight = 40;

static int kChooserTag = 1;
static int kPageIndicatorTag = 2;

@implementation HelloWorldLayer

+ (CCScene *)scene {
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

- (CCLayer *)dummyLayer:(int)index {
    CCLayer *layer = [CCLayer node];
    CCSprite *sprite = [CCSprite spriteWithFile:@"TestPage.png"];
    layer.contentSize = CGSizeMake(sprite.contentSize.width, [CCDirector sharedDirector].winSize.height - kPageIndicatorHeight);
    sprite.position = ccp(layer.contentSize.width/2, layer.contentSize.height/2);
    [layer addChild:sprite];
    return layer;
}

- (id)init {
	if ((self = [super initWithColor:ccc4(200, 200, 200, 255)])) {
        CGSize winSize = [CCDirector sharedDirector].winSize;

        NSArray *pages = [NSArray arrayWithObjects:[self dummyLayer:0], [self dummyLayer:1], [self dummyLayer:2], nil];
		PagedChooser *chooser = [[[PagedChooser alloc] initWithPages:pages pageSize:[[pages objectAtIndex:0] contentSize] delegate:self] autorelease];
        chooser.contentSize = CGSizeMake(winSize.width, winSize.height - kPageIndicatorHeight);
        chooser.anchorPoint = CGPointZero;
        chooser.position = CGPointMake(0, kPageIndicatorHeight);
        chooser.tag = kChooserTag;
		[self addChild:chooser];
        
        PageIndicatorLayer *indicatorLayer = [PageIndicatorLayer node];
        indicatorLayer.delegate = self;
        indicatorLayer.touchesChangeActivePage = YES;
        indicatorLayer.pageCount = pages.count;
        indicatorLayer.contentSize = CGSizeMake(self.contentSize.width, kPageIndicatorHeight);
        indicatorLayer.anchorPoint = CGPointZero;
        indicatorLayer.position = CGPointZero;
        indicatorLayer.tag = kPageIndicatorTag;
        indicatorLayer.inactiveColor = ccc4(90, 90, 0, 255);
        indicatorLayer.activeColor = ccc4(190, 45, 0, 255);
        indicatorLayer.tag = kPageIndicatorTag;
        [self addChild:indicatorLayer];
	}
    
	return self;
}

- (void)page:(NSUInteger)index didBecomeCurrentInChooser:(PagedChooser *)chooser {
    PageIndicatorLayer *indicatorLayer = (PageIndicatorLayer *)[self getChildByTag:kPageIndicatorTag];
    indicatorLayer.activePageIndex = index;    
}

- (void)activePageIndexDidChangeFromTouchIn:(PageIndicatorLayer *)indicator {
    PagedChooser *chooser = (PagedChooser *)[self getChildByTag:kChooserTag];
    [chooser makePageCurrent:indicator.activePageIndex];
}

@end
