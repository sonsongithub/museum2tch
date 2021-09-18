//
//  DatHTMLManager.m
//  2tch
//
//  Created by sonson on 08/11/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DatHTMLManager.h"
#import "DatParser_old.h"

@implementation DatHTMLManager

+ (NSString*) makeAnchorHTMLStringWithResNumberArray:(NSArray*)resNumberList resList:(NSMutableArray*)resList {
	NSMutableString *buff = [NSMutableString string];
	
	[buff appendString:@"<html><head>"];
	[buff appendString:@"<STYLE TYPE=\"text/css\"><!--"];
	[buff appendString:@"body{margin:0;padding:0;width:220px;}"];
//	[buff appendString:@"a:link{ color: #ccccff; }"];
	
	[buff appendString:@"p{margin:0;padding:0;font-size: 75%%;width:220px;}"];
	[buff appendString:@"div.entry{}"];
	//[buff appendString:@"div.info{font-size: 75%%;width: 230px;color:#000000;margin:0 0 0 0;padding:3 0 3 5;}"];
	//[buff appendString:@"div.body{font-size: 85%%;width: 220px;color:#000000;margin:0;padding:10 5 10 5;}"];
	[buff appendString:@"div.info{word-wrap: break-word;font-size: 75%%;width: 210px;background:#EFEFEF;margin:0 0 0 0;padding:3 0 3 5;}"];
	[buff appendString:@"div.body{word-wrap: break-word;font-size: 85%%;width: 210px;margin:0;padding:10 5 10 5;}"];
	[buff appendString:@"--></STYLE>"];
	[buff appendString:@"</head><body>"];
	
	for( NSNumber *num in resNumberList ) {
		int a = [num intValue]-1;
		if( a >= 0 && a < [resList count] ) {
			NSDictionary *dict = [resList objectAtIndex:a];
			
			[buff appendFormat:@"<div id=\"r%d\">",a+1,a+1];
			[buff appendFormat:@"<div class=\"info\">",a+1,a+1];
			[buff appendFormat:@"%d %@ %@", a+1, [dict objectForKey:@"name"], [dict objectForKey:@"date_id"]];
			[buff appendString:@"</div>"];
			[buff appendString:@"</div>"];
			
			[buff appendString:@"<div class=\"body\">"];
			[buff appendString:[dict objectForKey:@"body"]];		
			[buff appendString:@"</div>"];
		}
	}
	[buff appendString:@"</body></html>"];
	return buff;
}

+ (void) appendHeaderPart:(NSMutableString*)buff {
	[buff appendString:@"<html><head>"];
	[buff appendString:@"<script type=\"text/javascript\">"];
	[buff appendString:@"function scrollToID(id_string){var obj = document.getElementById(id_string);window.scroll(0, obj.offsetTop);}"];
	[buff appendString:@"var clickedID = 0; var d = \"\"; function linkScroll(linkId){var obj = document.getElementById(linkId);return obj.offsetTop;} function clicked(input){	if(input!=clickedID) {	if(clickedID!=0){divname='r'+clickedID; document.getElementById(divname).style.fontWeight='normal';} divname='r'+input;	document.getElementById(divname).style.fontWeight='bold';clickedID=input;	}else{divname='r'+input;	document.getElementById(divname).style.fontWeight='normal';clickedID=0;}}"];
	[buff appendString:@"var mini = \"body_ascii\";var max = \"body\";function toggleAsciiMode(input){var divname='body'+input;if( document.getElementById(divname).className == mini ) {document.getElementById(divname).className = max;}else if( document.getElementById(divname).className == max ) {document.getElementById(divname).className = mini;}else {document.getElementById(divname).className = mini;}scrollToID(\"r\"+input);}"];
	[buff appendString:@"</script>"];
	[buff appendString:@"<STYLE TYPE=\"text/css\"><!--"];
	[buff appendString:@"body{margin:0;padding:0;width:320px;}"];
	[buff appendString:@"p{margin:0;padding:0;font-size: 75%%;width:305px;}"];
	[buff appendString:@"div.entry{}"];
	[buff appendString:@"div.dogear{word-wrap: break-word;font-size: 100%%;font-weight:bold;color:#FFFFFF;width: 315px;background:#696969;margin:0 0 0 0;padding:3 0 3 5;}"];
	[buff appendString:@"div.info{word-wrap: break-word;font-size: 75%%;width: 315px;border-top:solid 1px #000000;background:#EFEFEF;margin:0 0 0 0;padding:3 0 3 5;}"];
	[buff appendString:@"div.info a{text-decoration:none;}"];
	[buff appendString:@"div.body{word-wrap: break-word;font-size: 85%%;width: 290px;margin:0;padding:10 5 10 5;}"];
	[buff appendString:@"div.body_ascii{font-size: 2%%;width:200%%;margin:0;padding:10 5 10 5;}"];
	[buff appendString:@"--></STYLE>"];
	[buff appendString:@"</head><body>"];
}

+ (void)appendEntry:(NSMutableArray*)resList number:(int)number targetString:(NSMutableString*)data {
	NSDictionary *dict = [resList objectAtIndex:number-1];
	[data appendFormat:@"<div class=\"info\">"];
	[data appendFormat:@"%d %@ %@", number, [dict objectForKey:@"name"], [dict objectForKey:@"date_id"]];		
	[data appendFormat:@" <a href=\"javascript:clicked(%d);\">%C</a> <a href=\"javascript:toggleAsciiMode(%d);\">%C</a>", number, 0xE23C, number, 0xE532];
	[data appendString:@"</div>"];
	[data appendString:@"</div>"];
	[data appendFormat:@"<div class=\"body\" id=\"body%d\">",number];
	if( [dict objectForKey:@"body"] )
		[data appendString:[dict objectForKey:@"body"]];		
	[data appendString:@"</div>"];
}

+ (NSString*)makeDataFrom:(int)from to:(int)to path:(NSString*)path dat:(int)dat resList:(NSMutableArray*)resList isNewCommingTag:(BOOL)isNewCommingTag {
	DNSLogMethod
	int i;
	NSMutableString* data = [NSMutableString string];
	[DatHTMLManager appendHeaderPart:data];
	if( from != 1 ) {		
		[data appendFormat:@"<div id=\"r%d\">",1];
		[DatHTMLManager appendEntry:resList number:1 targetString:data];
		
		if( isNewCommingTag ) {
			[data appendFormat:@"<div id=\"r%d\">",from];
			[data appendFormat:@"<div id=\"dogear\" class=\"dogear\">"];
			[data appendString:NSLocalizedString( @"NewComming", nil)];
			[data appendString:@"</div>"];
		}
		else {
			[data appendFormat:@"<div id=\"r%d\">",from];
			[data appendFormat:@"<div id=\"dogear\"></div>"];		
			[data appendString:@"</div>"];
		}
	}
	else {
		[data appendFormat:@"<div id=\"r%d\">",from];
	}
	for( i = from; i <= to; i++  ) {
		if( i != from )
			[data appendFormat:@"<div id=\"r%d\">",i];
		[DatHTMLManager appendEntry:resList number:i targetString:data];
	}
	[data appendString:@"</body>"];
	[data appendString:@"</html>"];
	return data;
}

+ (NSString*)makeCacheFrom:(int)from to:(int)to path:(NSString*)path dat:(int)dat resList:(NSMutableArray*)resList {
	DNSLogMethod
	NSString* html_cache_path = [NSString stringWithFormat:@"%@/%@/%d-%04d-%04d.html", DocumentFolderPath, path, dat, from, to];
	if( [[NSFileManager defaultManager] fileExistsAtPath:html_cache_path] ) {
		DNSLog( @"Load cache" );
		return [NSString stringWithContentsOfFile:html_cache_path encoding:NSUTF8StringEncoding error:nil];
	}
	else {
		DNSLog( @"Make cache" );
		NSString* data = [DatHTMLManager makeDataFrom:from to:to path:path dat:dat resList:resList isNewCommingTag:NO];
		[data writeToFile:html_cache_path atomically:NO encoding:NSUTF8StringEncoding error:nil];
		return data;
	}
}

+ (NSString*)htmlNewModeFrom:(int)from to:(int)to path:(NSString*)path dat:(int)dat resList:(NSMutableArray*)resList {
	DNSLogMethod
	return [DatHTMLManager makeDataFrom:from to:to path:path dat:dat resList:resList isNewCommingTag:YES];
}

+ (NSString*)htmlFrom:(int)from to:(int)to path:(NSString*)path dat:(int)dat resList:(NSMutableArray*)resList {
	DNSLogMethod
	NSString *folder_path =[NSString stringWithFormat:@"%@/%@/", DocumentFolderPath, path];
	[DatParser_old makeDirectoryOfPath:folder_path];	
	
	NSString* html = nil;
	if( from % 200 == 1 && to % 200 == 0 ) {
		// make cache html
		DNSLog( @"Try to make cache" );
		html = [DatHTMLManager makeCacheFrom:from to:to path:path dat:dat resList:resList];
	}
	else {
		// use temporary data
		DNSLog( @"Try to make temporary data" );
		html = [DatHTMLManager makeDataFrom:from to:to path:path dat:dat resList:resList isNewCommingTag:NO];
	}
	return html;
}

@end
