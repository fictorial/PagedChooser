#import "CCLayer.h"
#import "CCArray.h"

@class PagedChooser;

// Use this for instance to update something like UIPageControl

@protocol PagedChooserDelegate <NSObject>

- (void)page:(NSUInteger)index didBecomeCurrentInChooser:(PagedChooser *)chooser;

@end

@interface PagedChooser : CCLayer

- (id)initWithPages:(NSArray *)pages pageSize:(CGSize)pageSize delegate:(id<PagedChooserDelegate>)delegate;

@property (nonatomic, assign) id<PagedChooserDelegate> delegate;

@end
