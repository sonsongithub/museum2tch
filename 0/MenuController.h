#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "invariables.h"

@interface MenuController : NSObject {
	NSMutableArray	*boardData_;
	NSMutableArray	*categoryData_;
	NSString		*menufilePath_;
	int				currentCategory_;
	int				currentBoard_;
}
- (void) dealloc;
- (id) initWithUserLibraryPath:(NSString*)path;
- (void) setCurrentCategoryId:(int)categoryId;
- (NSMutableArray*) pullBoardTitles:(NSString*)url;
- (NSMutableArray*) processXML:(NSString*)data;
- (id) currentBoardName;
- (void) setCurrentBoardId:(int)input;
- (BOOL) readXML;
- (BOOL) writeXML;
- (void) reload;
- (id) getCategories;
- (id) getCurrentCategoryName;
- (id) getTitlesInCurrentCategory;
- (id) getURLsInCurrentCategory;
@end
