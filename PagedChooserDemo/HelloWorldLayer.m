#import "HelloWorldLayer.h"

@implementation HelloWorldLayer

+ (CCScene *)scene {
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

- (CCLayer *)dummyLayer:(int)index {
    ccColor4B colors[] = {
        ccc4(255, 255, 255, 255),
        ccc4(128, 128, 128, 255),
        ccc4(64, 64, 64, 255)
    };
    CCLayer *layer = [CCLayerColor layerWithColor:colors[index]];    
    CCSprite *sprite = [CCSprite spriteWithFile:@"TestPage.png"];
    layer.contentSize = CGSizeMake(sprite.contentSize.width, [CCDirector sharedDirector].winSize.height);
    sprite.position = ccp(layer.contentSize.width/2, layer.contentSize.height/2);
    [layer addChild:sprite];
    return layer;
}

- (id) init {
	if ((self = [super init])) {
        NSArray *pages = [NSArray arrayWithObjects:[self dummyLayer:0], [self dummyLayer:1], [self dummyLayer:2], nil];
		PagedChooser *chooser = [[[PagedChooser alloc] initWithPages:pages pageSize:[[pages objectAtIndex:0] contentSize] delegate:self] autorelease];
		[self addChild:chooser];
	}
    
	return self;
}

- (void)page:(NSUInteger)index didBecomeCurrentInChooser:(PagedChooser *)chooser {
    NSLog(@"page %u became current", index);
}

@end
