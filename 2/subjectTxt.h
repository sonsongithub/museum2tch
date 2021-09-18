
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

#define	_THREAD_PER_PAGE	50

@interface subjectTxt : NSObject {
	id		downloader_;
	
	id		subjectTxtPath_;
	id		boardData_;
	
	id		subjectTxtData_;
	id		backUpData_;
	BOOL	isRefined_;
	
	int		titleNum_;
	int		currentTitleTail_;
	int		byteOffset_;
}
- (id) init;
- (void) dealloc;
- (void) extractSubjectTxt;
- (id) subjectTxtData;
- (void) didSelectBoard:(NSNotification *)notification;
@end
