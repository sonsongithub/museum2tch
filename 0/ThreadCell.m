
#import "ThreadCell.h"

@implementation ThreadCell

#define		WIDTH_JAPANESE_CHARACTRER	13.0f
#define		WIDTH_ALPHABET_CHARACTRER	7.8f

- (NSString*) divideStringAtAWidth:(NSString*)str {
	NSMutableString *newStr = [NSMutableString string];
	int strIndex = 0;
	int textLen = [str length];
	
	float lineWidth = 0;
	
	//DNSLog( @"%@ (charcters->%d)", str, textLen );
	
	while( strIndex < textLen) {
		unichar c = [str characterAtIndex: strIndex];
		[newStr appendFormat: @"%C", c];
		if( c == '\n' ) {
			lineWidth = 0;
			strIndex++;
			continue;
		}
		if( c >> 8 )	// single byte or multi byte?
			lineWidth+=WIDTH_JAPANESE_CHARACTRER;
		else
			lineWidth+=WIDTH_ALPHABET_CHARACTRER;
			
		if( lineWidth > 295 ) {
			lineWidth = 0;
			[newStr appendFormat: @"\n"];
		}
		strIndex++;
	}
	return newStr;
}

- (float) height {
	return height_;
}

- (void) setDataWithDictionary:(NSDictionary*)dict {
	// make information label
	UITextLabel* info_label = [[[UITextLabel alloc] initWithFrame:CGRectMake( 5, 5, 310, 13)] autorelease];
	GSFontRef infoFont = GSFontCreateWithName("courier new", 2, 11.0f);
	[info_label setFont:infoFont];
	[info_label setWrapsText:YES];
	CFRelease(infoFont);
	
	// make body label
	UITextLabel* body_label = [[[UITextLabel alloc] initWithFrame:CGRectMake( 5, 27, 310, 60)] autorelease];;
	GSFontRef bodyFont = GSFontCreateWithName("courier new", 0, 13.0f);
	[body_label setFont:bodyFont];
	[body_label setWrapsText:YES];
	CFRelease(bodyFont);
			
	// set string
	id numberStr = [dict valueForKey:@"number"];
	id idStr = [dict valueForKey:@"id"];
	id nameStr = [dict valueForKey:@"name"];
	id dateStr = [dict valueForKey:@"date"];
	id mailStr = [dict valueForKey:@"mail"];
	NSString *info_string = [NSString stringWithFormat:@"%@:%@ %@ %@ %@", numberStr, nameStr, mailStr, dateStr, idStr];
	
	[info_label setText:info_string];
	
	[body_label setText:[self divideStringAtAWidth:[dict valueForKey:@"body"]]];

	[info_label sizeToFit];
	[body_label sizeToFit];

	[self addSubview:body_label];
	[self addSubview:info_label];
	
	CGRect rect_data = [info_label bounds];
	CGRect rect_body = [body_label bounds];
	height_ = rect_data.size.height + rect_body.size.height + 30;
}

@end
