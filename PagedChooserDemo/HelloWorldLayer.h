#import "cocos2d.h"
#import "PagedChooser.h"
#import "PageIndicatorLayer.h"

@interface HelloWorldLayer : CCLayerColor <PagedChooserDelegate, PageIndicatorLayerDelegate>

+ (CCScene *)scene;

@end
