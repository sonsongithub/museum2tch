
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

#define		_RES_PER_PAGE	100

@interface DatFile : NSObject {
	id		downloader_;
	id		datInfoPath_;
	id		datFilePath_;
	BOOL	isGettingDiff_;
	
	id		datInfo_;
	
	int		resNum_;
	int		nowTailRes_;
	int		resPerPage_;
	int		page_;
}
- (id) init;
- (void) dealloc;
- (void) extractLines;
- (NSString*) getForwardPage;
- (NSString*) getBackwardPage;
- (NSMutableString*) extractLink:(NSString*) input;
- (NSString*) getCurrentPage;
- (void) didSelectThread:(NSNotification *)notification;
- (void) startDownload;
- (void) didFinishLoadging:(id)fp;
- (id) datInfo;
- (void) didFailLoadging:(NSString*)str;
@end
