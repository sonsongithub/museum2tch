//
//  Downloader.h
//  2tch
//
//  Created by sonson on 08/05/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloaderDelegate
- (void) didFinishLoading:(id)data identifier:(NSString*)identifier;
- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL;
@end

@interface Downloader : NSObject {
	NSURLConnection		*connection_;
	NSMutableData		*data_;
	NSString			*identifier_;
	id					delegate_;
	BOOL				isDownloading_;
	id					response_;
	id					url_;
	int					dataSizeToReceive_;
	UINavigationItem	*navitaionItemDelegate_;
	UIView				*progressBarView_;
	UIProgressView		*progressBar_;
	NSURLResponse		*lastResponse_;
	
	UIView				*backupTitleView_;
	UIViewController	*backupViewController_;
	NSString			*backupTitleString_;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) UINavigationItem	*navitaionItemDelegate;
@property (nonatomic, assign) NSURLResponse		*lastResponse;
#pragma mark Override method
- (void) dealloc;
#pragma mark Original method
- (void) startWithURL:(NSString*)url identifier:(NSString*)identifier;
- (void) startWithURL:(NSString*)url lastModified:(NSString*)lastModified size:(int)length identifier:(NSString*)identifier;
- (void) cancelDownload:(NSNotification *)notification;
- (void) cancel;
- (int)getContentLength:(NSURLResponse *)response;
- (void)outputResponse:(NSURLResponse *)response;
#pragma mark for progress animation
- (void) startProgressAnimation;
- (void) setProgress;
- (void) stopProgressAnimation;
#pragma mark NSURLConnection delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data lengthReceived:(int)length;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
@end
