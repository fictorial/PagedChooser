#import "CCLayer.h"
#import "ccTypes.h"

@class PageIndicatorLayer;

@protocol PageIndicatorLayerDelegate <NSObject>
- (void)activePageIndexDidChangeFromTouchIn:(PageIndicatorLayer *)indicator;
@end

@interface PageIndicatorLayer : CCLayer

@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, assign) NSUInteger activePageIndex;
@property (nonatomic, assign) ccColor4B inactiveColor;
@property (nonatomic, assign) ccColor4B activeColor;
@property (nonatomic, assign) float dotSize;
@property (nonatomic, assign) id<PageIndicatorLayerDelegate> delegate;
@property (nonatomic, assign) BOOL touchesChangeActivePage;

@end
