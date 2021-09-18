
#import "ReplyViewController.h"
#import "ReplyViewCellBody.h"
#import "ReplyViewCellName.h"
#import "ReplyViewCellEmail.h"
#import "_tchAppDelegate.h"
#import "global.h"


#define kOFFSET_FOR_KEYBOARD					150.0

#include <ctype.h>

static int isSingleByte( int c ) {
	if( isalnum( c ) )
		return YES;
	if( c == '.' || c == '-' || c == '_' )
		return YES;
	return NO;
}

static int decodeMultiByteOfOnePass( int input ) {
	int c = 0;
	if( isdigit( input ) ) {
		c += ( input - '0' );
	} else if ('a' <= input && input <= 'f') {
		c += (10 + ( input - 'a' ) );
	}	
	return c;
}

@interface NSString (URLencode)
- (NSString*) URLencode;
- (NSString*) URLdecode;
@end

@implementation NSString (PercentEscape)
- (NSString*) URLdecode
{
	NSData* data = [self dataUsingEncoding: NSASCIIStringEncoding];
	NSMutableString* result = [NSMutableString string];
	
	int i;
	const unsigned char* bytes = [data bytes];
	for (i = 0; i < [data length]; i++) {
		if (bytes[i] == '%') {
			int c = 0;
			
			i++;
			if (isdigit(bytes[i])) {
				c += (bytes[i] - '0');
			} else if ('a' <= bytes[i] && bytes[i] <= 'f') {
				c += (10 + (bytes[i] - 'a'));
			}
			
			c <<= 4;
			
			i++;
			if (isdigit(bytes[i])) {
				c += (bytes[i] - '0');
			} else if ('a' <= bytes[i] && bytes[i] <= 'f') {
				c += (10 + (bytes[i] - 'a'));
			}
			
			[result appendFormat: @"%c", c];
		} else if (bytes[i] == '+') {
			[result appendString: @" "];
		} else {
			[result appendFormat: @"%c", bytes[i]];
		}
	}
	
	return result;
}

- (NSString*) URLencode
{
	NSData* data = [self dataUsingEncoding: NSShiftJISStringEncoding];
	NSMutableString* result = [NSMutableString string];
	
	int i;
	const unsigned char* bytes = [data bytes];
	for (i = 0; i < [data length]; i++) {
		if(isalnum(bytes[i]) || 
		   bytes[i] == '.' || bytes[i] == '-' || bytes[i] == '_') {
			[result appendFormat: @"%c", bytes[i]];
		} else if (bytes[i] == ' ') {
			[result appendString: @"+"];
		} else {
			[result appendFormat: @"%%%02x", bytes[i]];
		}
	}
	return result;
}

- (NSString*) URLdecodeNew {
	NSData* data = [self dataUsingEncoding: NSASCIIStringEncoding];
	NSMutableString* result = [NSMutableString string];
	
	int i;
	const unsigned char* bytes = [data bytes];
	for (i = 0; i < [data length]; i++) {
		if (bytes[i] == '%') {
			int c = 0;
			
			i++;
			if (isdigit(bytes[i])) {
				c += (bytes[i] - '0');
			} else if ('a' <= bytes[i] && bytes[i] <= 'f') {
				c += (10 + (bytes[i] - 'a'));
			}
			
			c <<= 4;
			
			i++;
			if (isdigit(bytes[i])) {
				c += (bytes[i] - '0');
			} else if ('a' <= bytes[i] && bytes[i] <= 'f') {
				c += (10 + (bytes[i] - 'a'));
			}
			
			[result appendFormat: @"%c", c];
		} else if (bytes[i] == '+') {
			[result appendString: @" "];
		} else {
			[result appendFormat: @"%c", bytes[i]];
		}
	}
	
	return result;
}

- (NSString*) URLencodeNew {
	NSData* data = [self dataUsingEncoding: NSShiftJISStringEncoding];
	NSMutableString* result = [NSMutableString string];
	
	int i;
	const unsigned char* bytes = [data bytes];
	for (i = 0; i < [data length]; i++) {
		if( isSingleByte( bytes[i] ) ) {
			[result appendFormat: @"%c", bytes[i]];
		} else if (bytes[i] == ' ') {
			[result appendString: @"+"];
		} else {
			[result appendFormat: @"%%%02x", bytes[i]];
		}
	}
	
	return result;
}
@end

@interface NSDate (RFC1123)
- (NSString*) descriptionInRFC1123;
@end

@implementation NSDate (RFC1123)
- (NSString*) descriptionInRFC1123 {
	return [self descriptionWithCalendarFormat: @"%a, %d %b %Y %H:%M:%S GMT"
									  timeZone: [NSTimeZone timeZoneWithName: @"GMT"]
										locale: nil];
}
@end

@implementation ReplyViewController

@synthesize server = server_;
@synthesize boardPath = boardPath_;
@synthesize dat = dat_;


- (void) dealloc {
//	[server_ release];
//	[boardPath_ release];
//	[dat_ release];
	[super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	return app.isAutorotateEnabled;
}
/*
- (void) setServer:(NSString*)server boardPath:(NSString*)boardPath dat:(NSString*)dat {
	[server_ release];
	[boardPath_ release];
	[dat_ release];
	server_ = [[NSString stringWithString:server] retain];
	boardPath_ = [[NSString stringWithString:boardPath] retain];
	dat_ = [[NSString stringWithString:dat] retain];
}
*/
- (IBAction)clear:(id)sender {
	[self clearCookie];
}

- (IBAction)close:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)send:(id)sender {
	
	DNSLog( @"server - %@", server_ );
	DNSLog( @"board - %@", boardPath_ );
	DNSLog( @"dat - %@", dat_ );
	
	DNSLog( @"name - %@", name_.text );
	DNSLog( @"email - %@", email_.text );
	DNSLog( @"body - %@", body_.text );
	
	Ch2ThreadPostResult result = [self  postWithName:name_.text mail:email_.text body:body_.text];
	
	if ( result == Ch2ThreadPostCheckCookie ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"ReplyAlertViewConfirmWriting", nil) message:result_body_
													   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		cookieConfirm_ = alert;
	}
	else if ( result == Ch2ThreadPostSuccess ){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"ReplyAlertViewConfirmComplete", nil) message:result_body_
													   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"ReplyAlertViewConfirmFail", nil) message:result_body_
													   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
	
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( actionSheet == cookieConfirm_ ) {
		if( buttonIndex == 0 ) {
			DNSLog( @"キャンセル" );
			//[self deleteCookieOfServer:self.server];
		}
		else if( buttonIndex == 1 ) {
			Ch2ThreadPostResult result = [self  postWithName:name_.text mail:email_.text body:body_.text];
			if( result == Ch2ThreadPostSuccess ) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"ReplyAlertViewConfirmComplete", nil) message:result_body_
															   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
				[alert show];
				[alert release];
			}
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"ReplyAlertViewConfirmFail", nil) message:result_body_
															   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
				[alert show];
				[alert release];
			}
		}
	}
	else {		// after error or success alert view
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		bodyHeight_ = 132.0f;
		[self prepareEditCells];
		
	}
	return self;
}

- (void) prepareEditCells {
	NSArray* ary;
	
	// prepare name cell
	ary = [[NSBundle mainBundle] loadNibNamed:@"ReplyViewCellName" owner:self options:nil];
	for( id obj in ary ){
		if( [obj isKindOfClass:[ReplyViewCellName class]] ) {
			nameCell_ = (ReplyViewCellName*)obj;
			name_ = nameCell_.name;
			nameCell_.prompt.text = NSLocalizedString( @"ReplyPromptName", nil );
			[nameCell_ retain];
			[nameCell_ setupFont];
			break;
		}
	}
	
	// prepare email cell
	ary = [[NSBundle mainBundle] loadNibNamed:@"ReplyViewCellEmail" owner:self options:nil];
	for( id obj in ary ){
		if( [obj isKindOfClass:[ReplyViewCellEmail class]] ) {
			emailCell_ = (ReplyViewCellEmail*)obj;
			email_ = emailCell_.email;
			emailCell_.prompt.text = NSLocalizedString( @"ReplyPromptEmail", nil );
			[emailCell_ setupFont];
			[emailCell_ retain];
			break;
		}
	}
	
	// prepare body cell
	ary = [[NSBundle mainBundle] loadNibNamed:@"ReplyViewCellBody" owner:self options:nil];
	for( id obj in ary ){
		if( [obj isKindOfClass:[ReplyViewCellBody class]] ) {
			bodyCell_ = obj;
			bodyCell_.body.delegate = self;
			body_ = bodyCell_.body;
			bodyCell_.prompt.text = NSLocalizedString( @"ReplyPromptBody", nil );
			[bodyCell_ retain];
			[bodyCell_ setupFont];
			break;
		}
	}

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row == 2 ) {
		return bodyHeight_;
	}
	else
		return 44.0f;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryNone;
//	return UITableViewCellAccessoryDetailDisclosureButton;
}

/*
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	DNSLog( @"[ReplyViewController] shouldChangeTextInRange" );
	return YES;
}
*/
 
- (void)textViewDidChange:(UITextView *)textView {
	DNSLog( @"[ReplyViewController] textViewDidChange" );

	CGRect textViewRect = textView.frame;	
	CGSize contentSize = textView.contentSize;

	DNSLog( @"textViewRect frame - %f,%f", textView.frame.origin.y, textView.frame.size.height );
	DNSLog( @"Content Height - %f", contentSize.height );
	
	// set textview height
	if( contentSize.height < 132.0f )
		textViewRect.size.height = 132.0f;
	else
		textViewRect.size.height = contentSize.height;
	
	textView.frame = textViewRect;
	bodyHeight_ = textView.frame.origin.y + textView.frame.size.height + 20;
	
	DNSLog( @"%f", bodyHeight_ );
	
	[tableView_ reloadData];
	[tableView_ scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//	[textView scrollRangeToVisible:NSMakeRange(0,0)];
/*	
	@try {
		if( [textView.text length] > 0 )
			[textView scrollRangeToVisible:NSMakeRange(0,0)];
	}
	@catch (NSException *exception) {
		DNSLog(@"[ReplyViewController] Caught %@: %@", [exception name], [exception reason]);
	}
	@finally {
	}
*/
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row == 0 ) {
		return nameCell_;
	}
	else if( indexPath.row == 1 ) {
		return emailCell_;
	}
	else if( indexPath.row == 2 ) {
		return bodyCell_;
	}
	return nil;
}

- (void) viewDidLoad {
	self.view = [replyNavController_ view];
	closeButton_.title = NSLocalizedString( @"ReplyRightButton", nil );
	sendButton_.title = NSLocalizedString( @"ReplyLeftButton", nil );
	replyNavController_.topViewController.title = NSLocalizedString( @"ReplyTitle", nil );
}

- (void) deleteCookieOfServer:(NSString*)server {
	
	DNSLog( server );
	
	id storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	id cookies = [storage cookies];
	DNSLog( @"%d", [cookies count] );
	int i;
	for( i = 0; i < [cookies count]; i++ ) {
		id cookie = [cookies objectAtIndex:i];
		if( [[cookie domain] rangeOfString:@".2ch.net"].location != NSNotFound ) {
			if( [[cookie name] isEqualToString:@"hana"] && [[cookie domain] isEqualToString:server] ) {
				DNSLog( @"Delete = %@ - %@ - %@ - %@", [cookie name], [cookie path], [cookie domain], [cookie commentURL] );
				[storage deleteCookie:cookie];
			}
			if( [[cookie name] isEqualToString:@"HAP"] && [[cookie domain] isEqualToString:server] ) {
				DNSLog( @"Delete = %@ - %@ - %@ - %@", [cookie name], [cookie path], [cookie domain], [cookie commentURL] );
				[storage deleteCookie:cookie];
			}
			if( [[cookie name] isEqualToString:@"PON"] && [[cookie domain] isEqualToString:server] ) {
				DNSLog( @"Delete = %@ - %@ - %@ - %@", [cookie name], [cookie path], [cookie domain], [cookie commentURL] );
				[storage deleteCookie:cookie];
			}
		}
	}
	
	// hana - / - etc7.2ch.net - (null)
	// HAP - / - etc7.2ch.net - (null)
	// PON - / - etc7.2ch.net - (null)
}

- (void) clearCookie {
	id storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	id cookies = [storage cookies];
	DNSLog( @"%d", [cookies count] );
	int i;
	for( i = 0; i < [cookies count]; i++ ) {
		id cookie = [cookies objectAtIndex:i];
		if( [[cookie domain] rangeOfString:@".2ch.net"].location != NSNotFound ) {
			DNSLog( @"Delete = %@ - %@ - %@ - %@", [cookie name], [cookie path], [cookie domain], [cookie commentURL] );
			[storage deleteCookie:cookie];
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	//	[body_ resignFirstResponder];
	//[bodyCell_.body becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
	UITextView *textView =bodyCell_.body;
	CGRect textViewRect = bodyCell_.body.frame;	
	CGSize contentSize = bodyCell_.body.contentSize;
	
	DNSLog( @"textViewRect frame - %f,%f", textView.frame.origin.y, textView.frame.size.height );
	DNSLog( @"Content Height - %f", contentSize.height );
	
	// set textview height
	if( contentSize.height < 132.0f )
		textViewRect.size.height = 132.0f;
	else
		textViewRect.size.height = contentSize.height;
	
	textView.frame = textViewRect;
	bodyHeight_ = textView.frame.origin.y + textView.frame.size.height + 20;
	

	CGRect rect =tableView_.frame;

//	if( self.interfaceOrientation == UIInterfaceOrientationLandscapeRight || self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft )
//		rect.size.height =  110;//16;//rect.size.height - kOFFSET_FOR_KEYBOARD;
//	else
//		rect.size.height =  200;//16;//rect.size.height - kOFFSET_FOR_KEYBOARD;
	rect.size.height = 244.0f;
	
	emailCell_.email.text = @"sage";
//	bodyCell_.body.text = @"";
//	nameCell_.name.text = @"";
	tableView_.frame = rect;
	[bodyCell_.body becomeFirstResponder];
	[tableView_ reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
/*
 if( [indexPath row] == 2 ) {
		DNSLog( @"aa" );
		bodyCell_.body.userInteractionEnabled = YES;
	}
 */
}

/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0) {
		Ch2ThreadPostResult result = [self  postWithName:name_.text mail:email_.text body:body_.text];
	}
	else {
		DNSLog(@"cancel");
	}
}
*/

- (id) URLOfBoard {
	NSString* str = [NSString stringWithFormat:@"http://%@/%@/", server_, boardPath_];
	return [NSURL URLWithString:str];
}

- (int) postWithName: (NSString*) name mail: (NSString*) mail body: (NSString*) body {
	NSURL* url = [NSURL URLWithString: @"/test/bbs.cgi"
						relativeToURL: [self URLOfBoard]];
	
	DNSLog( [url absoluteString] );
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	
	[dict setValue:boardPath_ forKey: @"bbs"];
	[dict setValue:dat_ forKey: @"key"];
	[dict setValue:[NSString stringWithFormat: @"%d", 1] forKey: @"time"];
	[dict setValue:@"%8F%91%82%AB%8D%9E%82%DE" forKey:@"submit"];				// 書き込む
	
	[dict setValue: [name URLencode] forKey: @"FROM"];
	[dict setValue: [mail URLencode] forKey: @"mail"];
	[dict setValue: [body URLencode] forKey: @"MESSAGE"];
	
	//if( sharedPon_ != nil )
	[dict setValue: @"mogera" forKey: @"hana"];		// new method since 2006/05?
	
	NSMutableString* string = [NSMutableString string]; 
	
	NSEnumerator* enumerator = [dict keyEnumerator];
	id key;
	while ((key = [enumerator nextObject])) {
		[string appendString: key];
		[string appendString: @"="];
		[string appendString: [dict objectForKey: key]];
		[string appendString: @"&"];
	}	
	[string deleteCharactersInRange: NSMakeRange([string length] - 1, 1)];
	
	DNSLog( string );
	
	NSData* data = [string dataUsingEncoding: NSASCIIStringEncoding];
	
	NSMutableURLRequest* req;
	req = [NSMutableURLRequest requestWithURL: url];
	[req setHTTPMethod: @"POST"];
	[req setValue:@"Monazilla/1.00 (iphone/1.00)" forHTTPHeaderField: @"User-Agent"];
	[req setValue:[[self URLOfBoard] absoluteString] forHTTPHeaderField: @"Referer"];
	[req setValue: [NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField: @"Content-Length"];
	[req setHTTPBody: data];
	
	// Cookie
	NSString* cookie = [NSString stringWithFormat:
						@"NAME=%@; MAIL=%@; PON=%@; expires=%@; path=/",
						name, mail, 
						sharedPon_,
						[[NSDate dateWithTimeIntervalSinceNow: 60] descriptionInRFC1123]];
	[req setValue: cookie forHTTPHeaderField: @"Cookie"];
	
	NSHTTPURLResponse* resp;
	NSError* error;
	data = [NSURLConnection sendSynchronousRequest: req
								 returningResponse: &resp
											 error: &error];
//	[data writeToFile: @"/tmp/sevenfour-post.html" atomically: YES];
	
	if( error != nil ) {
		DNSLog( @"error - %@", [error localizedDescription] );
		return Ch2ThreadPostClientError;
	}
	
	NSString *str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
	DNSLog( @"aa" );
	Ch2ThreadPostResult result = [self extractReply2ch_X_String:str];
	DNSLog( str );
	NSString *temp = [self extractReplyBodyString:str];
	if( temp != nil ) {
		[result_body_ release];
		result_body_ = eliminateHTMLTag( [NSString stringWithString:temp] );
		[result_body_ retain];
	}
	
	DNSLog( @"Cookie - %@", [[resp allHeaderFields] objectForKey: @"Set-Cookie"] );
	
	if ( result == Ch2ThreadPostCheckCookie ) {
		if (sharedPon_) {
			[sharedPon_ release];
		}
		NSDictionary* receiveCookie = [self parseCookie:[[resp allHeaderFields] objectForKey: @"Set-Cookie"]];
		if( receiveCookie != nil )
			sharedPon_ = [[NSString stringWithString:[receiveCookie objectForKey: @"PON"]] retain];
	}
	return result;
}

- (id) parseCookie:(NSString*)str {
	if( str == nil )
		return nil;
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSArray* entries = [str componentsSeparatedByString:@"; "];
	int i;
	DNSLog( @"->%@", str );
	for( i = 0; i < [entries count]; i++ ) {
		NSString* entry = [entries objectAtIndex:i];
		NSArray* ary = [entry componentsSeparatedByString:@"="];
		NSString* key_eliminated_space = [[ary objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""];
		[dict setValue:[ary objectAtIndex:1] forKey:key_eliminated_space];
	}
	DNSLog( @"parse cookie result" );
	id keys = [dict allKeys];
	for( i = 0; i < [keys count]; i++ ) {
		id key = [keys objectAtIndex:i];
		DNSLog( @"%@->%@", key, [dict objectForKey:key] );
	}
	return dict;
}

- (Ch2ThreadPostResult) extractReply2ch_X_String:(NSString*) string {
	// find 2ch_X
	NSString* value_2ch_X = nil;
	NSRange range_2ch_X_start = [string rangeOfString:@"<!-- 2ch_X:"];
	NSRange range_2ch_X_end = [string rangeOfString:@" -->"];
	if( range_2ch_X_start.location != NSNotFound && range_2ch_X_end.location != NSNotFound ) { 
		DNSLog( @"%d-%d", range_2ch_X_start.location+11,range_2ch_X_end.location );
		value_2ch_X = [string substringWithRange:NSMakeRange(range_2ch_X_start.location+11,(range_2ch_X_end.location) - (range_2ch_X_start.location+11))];
	}
	
	DNSLog( @"value_2ch_X->%@", value_2ch_X );
	if ([value_2ch_X isEqualToString: @"true"]) {
		return Ch2ThreadPostSuccess;
	}
	else if (value_2ch_X == nil) {
		return Ch2ThreadPostSuccess;
	}
	else if ([value_2ch_X isEqualToString: @"false"]) {
		return Ch2ThreadPostWarning;
	}
	else if ([value_2ch_X isEqualToString: @"error"]) {
		return Ch2ThreadPostError;
	}
	else if ([value_2ch_X isEqualToString: @"check"]) {
		return Ch2ThreadPostCheck;
	}
	else if ([value_2ch_X isEqualToString: @"cookie"]) {
		return Ch2ThreadPostCheckCookie;
	}
	else {
		return Ch2ThreadPostClientError;
	}	
	
	return 0;
}

- (NSString*) extractReplyBodyString:(NSString*) string {
	// find body
	NSRange range_body_start = [string rangeOfString:@"<body"];
	NSRange range_body_end = [string rangeOfString:@"</body>"];
	if( range_body_start.location != NSNotFound && range_body_end.location != NSNotFound ) { 
		DNSLog( @"%d-%d", range_body_start.location,range_body_end.location );
		NSString* value_body = [string substringWithRange:NSMakeRange(range_body_start.location,range_body_end.location - range_body_start.location)];
		DNSLog( value_body );
		return value_body;
	}
	return nil;
}

@end
