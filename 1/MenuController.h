#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface MenuController : NSObject {
	NSData			*downloadedData_;
	NSMutableArray	*boardData_;
	NSMutableArray	*categoryData_;
	NSString		*menufilePath_;
	int				currentCategory_;
	int				currentBoard_;
}
- (BOOL) updateBBSMenuHTML;
- (BOOL) reload;
- (NSData*) getDataOfBBSMenuHTML;
- (BOOL) extractBbsMenuHtml:(NSString*) htmlString;
- (void) setCurrentCategoryId:(int)categoryId;
- (void) setCurrentBoardId:(int) input;
- (id) getCategories;
- (id) currentBoardName;
- (id) getCurrentCategoryName;
- (id) getTitlesInCurrentCategory;
- (id) getURLsInCurrentCategory;
@end
