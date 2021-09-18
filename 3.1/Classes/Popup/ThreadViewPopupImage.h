//
//  ThreadViewPopupImage.h
//  2tchfree
//
//  Created by sonson on 08/08/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadViewPopup.h"
#import "Downloader.h"

@interface ThreadViewPopupImage : ThreadViewPopup <DownloaderDelegate> {
	UIImageView* contentImage_;
	UIActivityIndicatorView* indicator_;
}
- (void) setImageWithURL:(NSString*)url;
- (void) saveImage:(id)sender;
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (void)threadViewPopupImageUIViewAnimationDelegate:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end
