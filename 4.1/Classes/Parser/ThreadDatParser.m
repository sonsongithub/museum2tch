//
//  ThreadDatParser.m
//  threadParser
//
//  Created by sonson on 09/01/09.
//  Copyright 2009 sonson. All rights reserved.
//

#import "ThreadDatParser.h"
#import "StringDecoder.h"
#import "ThreadLayoutComponent.h"
#import "ThreadResData.h"
#import "DatParser.h"
#import "SubjectParser.h"
#import "EmojiConverter.h"
#import "Dat.h"
#import "old_html_special.h"

int sjisTable[] = {
0,	//00
0,	//01
0,	//02
0,	//03
0,	//04
0,	//05
0,	//06
0,	//07
0,	//08
0,	//09
0,	//0A
0,	//0B
0,	//0C
0,	//0D
0,	//0E
0,	//0F
0,	//10
0,	//11
0,	//12
0,	//13
0,	//14
0,	//15
0,	//16
0,	//17
0,	//18
0,	//19
0,	//1A
0,	//1B
0,	//1C
0,	//1D
0,	//1E
0,	//1F
0,	//20
0,	//21
0,	//22
0,	//23
0,	//24
0,	//25
0,	//26
0,	//27
0,	//28
0,	//29
0,	//2A
0,	//2B
0,	//2C
0,	//2D
0,	//2E
0,	//2F
0,	//30
0,	//31
0,	//32
0,	//33
0,	//34
0,	//35
0,	//36
0,	//37
0,	//38
0,	//39
0,	//3A
0,	//3B
0,	//3C
0,	//3D
0,	//3E
0,	//3F
0,	//40
0,	//41
0,	//42
0,	//43
0,	//44
0,	//45
0,	//46
0,	//47
0,	//48
0,	//49
0,	//4A
0,	//4B
0,	//4C
0,	//4D
0,	//4E
0,	//4F
0,	//50
0,	//51
0,	//52
0,	//53
0,	//54
0,	//55
0,	//56
0,	//57
0,	//58
0,	//59
0,	//5A
0,	//5B
0,	//5C
0,	//5D
0,	//5E
0,	//5F
0,	//60
0,	//61
0,	//62
0,	//63
0,	//64
0,	//65
0,	//66
0,	//67
0,	//68
0,	//69
0,	//6A
0,	//6B
0,	//6C
0,	//6D
0,	//6E
0,	//6F
0,	//70
0,	//71
0,	//72
0,	//73
0,	//74
0,	//75
0,	//76
0,	//77
0,	//78
0,	//79
0,	//7A
0,	//7B
0,	//7C
0,	//7D
0,	//7E
0,	//7F
0,	//80
1,	//81
1,	//82
1,	//83
1,	//84
1,	//85
1,	//86
1,	//87
1,	//88
1,	//89
1,	//8A
1,	//8B
1,	//8C
1,	//8D
1,	//8E
1,	//8F
1,	//90
1,	//91
1,	//92
1,	//93
1,	//94
1,	//95
1,	//96
1,	//97
1,	//98
1,	//99
1,	//9A
1,	//9B
1,	//9C
1,	//9D
1,	//9E
1,	//9F
0,	//A0
0,	//A1
0,	//A2
0,	//A3
0,	//A4
0,	//A5
0,	//A6
0,	//A7
0,	//A8
0,	//A9
0,	//AA
0,	//AB
0,	//AC
0,	//AD
0,	//AE
0,	//AF
0,	//B0
0,	//B1
0,	//B2
0,	//B3
0,	//B4
0,	//B5
0,	//B6
0,	//B7
0,	//B8
0,	//B9
0,	//BA
0,	//BB
0,	//BC
0,	//BD
0,	//BE
0,	//BF
0,	//C0
0,	//C1
0,	//C2
0,	//C3
0,	//C4
0,	//C5
0,	//C6
0,	//C7
0,	//C8
0,	//C9
0,	//CA
0,	//CB
0,	//CC
0,	//CD
0,	//CE
0,	//CF
0,	//D0
0,	//D1
0,	//D2
0,	//D3
0,	//D4
0,	//D5
0,	//D6
0,	//D7
0,	//D8
0,	//D9
0,	//DA
0,	//DB
0,	//DC
0,	//DD
0,	//DE
0,	//DF
1,	//E0
1,	//E1
1,	//E2
1,	//E3
1,	//E4
1,	//E5
1,	//E6
1,	//E7
1,	//E8
1,	//E9
1,	//EA
1,	//EB
1,	//EC
1,	//ED
1,	//EE
1,	//EF
0,	//F0
0,	//F1
0,	//F2
0,	//F3
0,	//F4
0,	//F5
0,	//F6
0,	//F7
0,	//F8
0,	//F9
0,	//FA
0,	//FB
0,	//FC
0,	//FD
0,	//FE
0,	//FF
};

const char url_char[] = {
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1, // !
0,
0,
1, // $
1, // %
1, // &
1, // '
1, // (
1, // )
1, // *
1, // +
2, // ,
2, // -
1, // .
1, // /
2, // 0
2, // 1
2, // 2
2, // 3
2, // 4
2, // 5
2, // 6
2, // 7
2, // 8
2, // 9
1, // :
1, // ;
0,
1, // =
0,
1, // ?
1, // @
1, // A
1, // B
1, // C
1, // D
1, // E
1, // F
1, // G
1, // H
1, // I
1, // J
1, // K
1, // L
1, // M
1, // N
1, // O
1, // P
1, // Q
1, // R
1, // S
1, // T
1, // U
1, // V
1, // W
1, // X
1, // Y
1, // Z
0,
0,
0,
0,
1, // _
0,
1, // a
1, // b
1, // c
1, // d
1, // e
1, // f
1, // g
1, // h
1, // i
1, // j
1, // k
1, // l
1, // m
1, // n
1, // o
1, // p
1, // q
1, // r
1, // s
1, // t
1, // u
1, // v
1, // w
1, // x
1, // y
1, // z
0,
0,
0,
1, // ~
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
};

BOOL divideAnEntry( char*headPointer, int length, int *position ) {
	int i, counter = 0;
	const char* dat_template = "<>";
	if( length < 2 )
		return NO;
	for( i = 0; i < length - 1; i++ ) {
		if( !strncmp( headPointer + i, dat_template, 2 ) ) {
			*(position++) = i;
			counter++;
		}
	}
	if( counter == 4 )
		return YES;
	return NO;
}

@implementation ThreadDatParser

+ (void)getNumberFromDividedComma:(NSString*)string appendTo:(NSMutableArray*)res {
	NSArray *numbers = [string componentsSeparatedByString:@"-"];
	int i;
	if( [numbers count] > 1 ) {
		for( i = [[numbers objectAtIndex:0] intValue]; i <= [[numbers objectAtIndex:1] intValue]; i++ ) {
			[res addObject:[NSNumber numberWithInt:i]];
		}
	}
	else {
		[res addObject:[NSNumber numberWithInt:[string intValue]]];
	}
}

+ (NSMutableArray*)getNumber:(NSString*)anchor_string {
	NSArray *ary = [anchor_string componentsSeparatedByString:@">>"];
	NSString* res_num = [ary objectAtIndex:[ary count]-1];
	NSMutableArray* res = [NSMutableArray array];
	NSArray *components = [res_num componentsSeparatedByString:@","];
	for( NSString* component in components ) {
		[ThreadDatParser getNumberFromDividedComma:component appendTo:res];
	}
#ifdef _DEBUG
	for( NSNumber* n in res ) {
		DNSLog( @"Res:%d", [n intValue] );
	}
#endif
	return res;
}

- (int)currentCode {
	if( currentCode_ == 0 )
		currentCode_ = [StringDecoder encodeingFromBytes:currentEntryHead_ length:currentEntryLength_];
	return currentCode_;
}

- (int)parseAnchor:(char*)headPointer length:(int)length pointer:(int*)pointer {
	BOOL isCopying = YES;
	int i = *pointer;
	int safetyEndPoint = *pointer;
	
	memcpy( stack_, ">>", 2 );		// copy ">>" into stack.
	stackPointer_+=2;
	
	while( i < length ) {
		if( !strncmp( headPointer + i, "&gt;&gt;", 8 ) ) {
			// skip ">>" of anchor
			i += 8;
		}
		else if( !strncmp( headPointer + i, "</a>", 4 ) ) {
			// skip "</a>" as delimiter of anchor.
			i += 4;
			safetyEndPoint = i;
		}
		else if( *( headPointer + i ) == ' ' || *( headPointer + i ) == '<' || url_char[*( headPointer + i )] != 2 ) {
			[self popStackIntoComponents:kThreadLayoutAnchor];
			*pointer = i;
			return 0;
		}
		else if( isCopying ) {
			*(stack_ + stackPointer_) = *( headPointer + i );
			i++;
			stackPointer_++;
		}
	}
	*pointer = safetyEndPoint;
	return 0;
}

- (int)parseTagWithoutAnchor:(char*)headPointer length:(int)length pointer:(int*)pointer {
	int i = *pointer + 1;					// skip 1 byte of "<", delimiter
	int tagEnd = 0;
	while( i < length ) {
		if( *( headPointer + i ) == '>' ) {
			tagEnd = i;
			break;
		}
		i++;
	}
	*pointer = tagEnd+1;					// skip 1 byte of ">", delimiter 
	return 0;
}

- (int)parseTag:(char*)headPointer length:(int)length pointer:(int*)pointer {
	int i = *pointer + 1;					// skip 1 byte of "<", delimiter 
	int tagStart = *pointer + 1;			// same reason
	int tagEnd = 0;
	while( i < length ) {
		if( *( headPointer + i ) == '>' ) {
			tagEnd = i;
			break;
		}
		i++;
	}
	if( tagEnd - tagStart == 2 ) {
		if( !strncmp( headPointer+tagStart, "br", 2) || !strncmp( headPointer+tagStart, "BR", 2) ) {
			*(stack_ + stackPointer_) = '\r';
			stackPointer_++;
			*pointer = tagEnd+1;			// skip 1 byte of ">", delimiter
			if( *(headPointer+tagEnd+1) == ' ' )
				*pointer = tagEnd+2;		// skip 2 byte of ">" and "", delimiter
			return 0;
		}
		if( !strncmp( headPointer+tagStart, "hr", 2) || !strncmp( headPointer+tagStart, "HR", 2) ) {
			memcpy( stack_ + stackPointer_, "\r----\r", 6 );
			stackPointer_+=6;
			*pointer = tagEnd+1;			// skip 1 byte of ">", delimiter
			if( *(headPointer+tagEnd+1) == ' ' )
				*pointer = tagEnd+2;		// skip 2 byte of ">" and "", delimiter
			return 0;
		}
	}
	else if( tagEnd - tagStart > 24 ) {
		if( !strncmp( headPointer+tagStart, "a href=\"../test/read.cgi", 24 ) ) {
			// parse anchor
			*pointer = tagEnd+1;			// skip 1 byte of ">", delimiter
			[self popStackIntoComponents:kThreadLayoutText];
			[self parseAnchor:headPointer length:length pointer:pointer];
			return 0;
		}
	}
	*pointer = tagEnd+1;					// skip 1 byte of ">", delimiter 
	return 0;
}

- (int)parseHTTP:(char*)headPointer length:(int)length pointer:(int*)pointer {
	int i = *pointer + 4;					// skip 4 byte of "http" or "ttp:"
	int urlStart = *pointer;
	int urlEnd = 0;
	while( i < length ) {
		//if( url_char[*( headPointer + i )] == 0 ) {
		if( *( headPointer + i ) == ' ' || *( headPointer + i ) == '<' ) {
			*pointer = i;
			urlEnd = i;
			[self copyIntoComponents:headPointer+urlStart length:urlEnd-urlStart components:kThreadLayoutHTTPLink];
			return 0;
		}
		i++;
	}
	// skip last charcter of URL 
	[self copyIntoComponents:headPointer+urlStart length:i-urlStart components:kThreadLayoutHTTPLink];
	*pointer = i;
	return 0;
}

- (int)parseHTMLChar:(char*)headPointer length:(int)length pointer:(int*)pointer {
	int i = *pointer + 1;					// search from next to "&"
	int charStart = *pointer + 1;			// as same as above.
	int charEnd = 0;
	while( i < length ) {
		if( *( headPointer + i ) == ';' ) {
			charEnd = i;
			break;
		}
		else if( i - charStart > 8 ) {		// the maximum length of HTML special character is 8
			*pointer+=1;					// skip a byte of "&"
			return 0;
		}
		i++;
	}
	int code = utf8codeOfHTMLSpecialCharacter( headPointer+charStart, charEnd - charStart );
	if( code != 0 ) {
		[self popStackIntoComponents:kThreadLayoutText];
		[self appendSpecialCharacter:code];
	}	
	*pointer = i+1;							// skip a byte of ";"
	return 0;
}

- (int)skipHeadSingleSpace {
	if( !strncmp( stack_, " ", 1 ) ) {	// for first line
		stackPointer_--;
		return 1;
	}
	return 0;
}

- (int)skipHeadNewline {
	if( !strncmp( stack_, " \r ", 3 ) ) {	// skip a new line at heat of a new component
		stackPointer_-=3;
		return 3;
	}
	else if( !strncmp( stack_, " \r", 2 ) ) {
		stackPointer_-=2;
		return 2;
	}
	else if( !strncmp( stack_, "\r ", 2 ) ) {
		stackPointer_-=2;
		return 2;
	}
	else if( !strncmp( stack_, "\r", 1 ) ) {
		stackPointer_-=1;
		return 1;
	}
	else if( !strncmp( stack_, " ", 1 ) ) {	// for first line
		stackPointer_--;
		return 1;
	}
	return 0;
}

- (void)skipTailNewline {
	if( !strncmp( stack_+stackPointer_-2, "\r ", 2 ) ) {
		stackPointer_-=2;
	}
	else if( !strncmp( stack_+stackPointer_-1, "\r", 1 ) ) {
		stackPointer_--;
	}
}

- (void)appendSpecialCharacter:(int)charCode {
	if( [currentComponents_ count] > 0 ) {
		ThreadLayoutComponent* last_anchor = [currentComponents_ lastObject];
		if( last_anchor.textInfo == kThreadLayoutText ) {
			// combine last object string and new buffer
			NSString* newString = [NSString stringWithFormat:@"%C", charCode];
			last_anchor.text = [last_anchor.text stringByAppendingString:newString];
			return;
		}
	}
	// append new object
	ThreadLayoutComponent* p_anchor = [[ThreadLayoutComponent alloc] init];
	p_anchor.text = [NSString stringWithFormat:@"%C", charCode];
	p_anchor.textInfo = kThreadLayoutText;
	[currentComponents_ addObject:p_anchor];
	[p_anchor release];
}

- (void)popStackIntoComponents:(int)componentMode {
	if( stackPointer_ == 1 && *stack_ == ' ' ) {
		stackPointer_ = 0;
		return;
	}
	int stack_offset = 0;
	ThreadLayoutComponent* last_anchor = [currentComponents_ lastObject];
	if( last_anchor.textInfo != kThreadLayoutText ) {
		stack_offset = [self skipHeadNewline];
		[self skipTailNewline];
	}
	else {
		stack_offset = [self skipHeadSingleSpace];
	}
	
	if( [currentComponents_ count] > 0 ) {
		ThreadLayoutComponent* last_anchor = [currentComponents_ lastObject];
		if( last_anchor.textInfo == kThreadLayoutText && componentMode == kThreadLayoutText ) {
			// combine last object string and new buffer
			NSString* newString = [StringDecoder decodeBytesFrom:stack_+stack_offset length:stackPointer_ encoding:&currentCode_];
			stackPointer_ = 0;
			last_anchor.text = [[last_anchor.text stringByAppendingString:newString] retain];
			[newString release];
			return;
		}
	}
	// append new object
	ThreadLayoutComponent* p_anchor = [[ThreadLayoutComponent alloc] init];
	p_anchor.text = [StringDecoder decodeBytesFrom:stack_+stack_offset length:stackPointer_ encoding:&currentCode_];
	stackPointer_ = 0;
	[p_anchor.text  release];
	p_anchor.textInfo = componentMode;
	[currentComponents_ addObject:p_anchor];
	[p_anchor release];
}

- (void)copyIntoComponents:(char*)headPointer length:(int)length components:(int)componentMode {
	ThreadLayoutComponent* p_anchor = [[ThreadLayoutComponent alloc] init];
	p_anchor.text = [StringDecoder decodeBytesFrom:headPointer length:length encoding:&currentCode_];
	stackPointer_ = 0;
	[p_anchor.text  release];
	p_anchor.textInfo = componentMode;
	[currentComponents_ addObject:p_anchor];
	[p_anchor release];
}

- (NSString*)parseWithoutHTTPandAnchor:(char*)headPointer length:(int)length {
	int i = 0;
	stackPointer_ = 0;
	BOOL isCopying = YES;
	
	while( i < length ) {
		if( *( headPointer + i ) == '<' ) {
			[self parseTagWithoutAnchor:headPointer length:length pointer:&i];
		}
		else if( *( headPointer + i ) == '&' ) {
			[self parseHTMLChar:headPointer length:length pointer:&i];
		}
		else if( isCopying ) {
			*(stack_ + stackPointer_) = *( headPointer + i );
			i++;
			stackPointer_++;
		}
		else {
			i++;
		}
	}
	NSString* result = [StringDecoder decodeBytesFrom:stack_ length:stackPointer_ encoding:&currentCode_];
	stackPointer_ = 0;
	return result;
}

- (void)bodyParseWithEmoji:(char*)headPointer length:(int)length {
	int i = 0;
	stackPointer_ = 0;	
	while( i < length ) {
		if( *( headPointer + i ) == '<' ) {
			[self parseTag:headPointer length:length pointer:&i];
		}
		else if( *( headPointer + i ) == '&' ) {
			[self parseHTMLChar:headPointer length:length pointer:&i];
		}
		else if( length - i > 4 && ( !strncmp( headPointer + i, "http", 4) || !strncmp( headPointer + i, "ttp:", 3) ) ) {
			[self popStackIntoComponents:kThreadLayoutText];
			[self parseHTTP:headPointer length:length pointer:&i];
		}
		else {
#ifdef _USE_EMOJI
			int emojiCode = codeOfEmoji( headPointer + i );
			if( emojiCode > 0 ) {
				NSString* special_char = [NSString stringWithFormat:@"%C", emojiCode];
				NSData* special_char_byte = [special_char dataUsingEncoding:currentCode_];
				char* pp = (char*)[special_char_byte bytes];
				memcpy( stack_ + stackPointer_, pp, [special_char_byte length] );
				stackPointer_ += [special_char_byte length];
				i+=2;
			}
			else if( sjisTable[(unsigned char)*(headPointer + i)] ) {
				*(stack_ + stackPointer_) = *( headPointer + i );
				i++;
				stackPointer_++;
				*(stack_ + stackPointer_) = *( headPointer + i );
				i++;
				stackPointer_++;
			}
			else {
				*(stack_ + stackPointer_) = *( headPointer + i );
				i++;
				stackPointer_++;
			}
#else
			*(stack_ + stackPointer_) = *( headPointer + i );
			i++;
			stackPointer_++;
#endif
		}
	}
	[self popStackIntoComponents:kThreadLayoutText];
}

- (void)bodyParse:(char*)headPointer length:(int)length {
	int i = 0;
	stackPointer_ = 0;
	while( i < length ) {
		if( *( headPointer + i ) == '<' ) {
			[self parseTag:headPointer length:length pointer:&i];
		}
		else if( *( headPointer + i ) == '&' ) {
			[self parseHTMLChar:headPointer length:length pointer:&i];
		}
		else if( length - i > 4 && ( !strncmp( headPointer + i, "http", 4) || !strncmp( headPointer + i, "ttp:", 3) ) ) {
			[self popStackIntoComponents:kThreadLayoutText];
			[self parseHTTP:headPointer length:length pointer:&i];
		}
		else {
			*(stack_ + stackPointer_) = *( headPointer + i );
			i++;
			stackPointer_++;
		}
	}
	[self popStackIntoComponents:kThreadLayoutText];
}

- (id)parseAnEntry:(char*)headPointer length:(int)length {
	int position[5];
	BOOL re = divideAnEntry( headPointer, length, position );
	if( re ) {
		
		if( [array_ count] == 0 ) {
			NSString* thread_title = [self parseWithoutHTTPandAnchor:headPointer + position[3] + 2 length:length - position[3] - 2];
			DNSLog( @"%@", thread_title );
			dat_.title = thread_title;
			[thread_title release];
		}
		
		ThreadResData *p = [[ThreadResData alloc] init];
		[array_ addObject:p];
		p.body = [NSMutableArray array];
		currentComponents_ = p.body;
		[p release];
		NSString* name = [self parseWithoutHTTPandAnchor:headPointer length:position[0]];
		NSString* email = [self parseWithoutHTTPandAnchor:headPointer + position[0] + 2 length:position[1] - position[0]];
		NSString* date_id = [self parseWithoutHTTPandAnchor:headPointer + position[1] + 2 length:position[2] - position[1] - 2];
		
		if( [self currentCode] == NSShiftJISStringEncoding || [self currentCode] == kCFStringEncodingShiftJIS_X0213_00 )
			[self bodyParseWithEmoji:headPointer+position[2] + 2 length:(position[3]-position[2]-2)];
		else
			[self bodyParse:headPointer+position[2] + 2 length:(position[3]-position[2]-2)];
		
		p.date = date_id;
		p.email = email;
		p.name = name;
		p.number = [array_ count];
		p.numberString = [NSString stringWithFormat:@"%d", p.number];
		[name release];
		[email release];
		[date_id release];
		return nil;
	}
	return nil;
}

- (void)parse:(NSMutableData*)data appendToDat:(Dat*)dat {
	dat_ = dat;
	[self parse:data appendTo:dat.resList];
}

- (void)layout:(NSMutableArray*)array width:(int)width {
	CGRect rect;
	float line = HeightThreadFont;
	for( ThreadResData* ro in array ) {
		float height = HeightThreadInfoFont * 2 + 4 + 5;
		for( ThreadLayoutComponent* sr in ro.body ) {
			if( sr.textInfo != kThreadLayoutNewLine ) {
				rect.origin.x = 5;
				rect.origin.y = height;
				rect.size.width = width - 15;
				rect.size = [sr.text sizeWithFont:threadFont constrainedToSize:CGSizeMake(rect.size.width, 1300) lineBreakMode:UILineBreakModeWordWrap];
				height += rect.size.height;
				sr.rect = rect;
			}
			else {
				height += line;
			}
		}
		ro.height = height;
	}
}

- (void)parse:(NSMutableData*)data appendTo:(NSMutableArray*)array {
	DNSLogMethod
	CFAbsoluteTime start_time, end_time;
	int i = 0,currentHead = 0;
	char*p = (char*)[data bytes];
	int length = [data length];
	currentCode_ = 0;
	
	if( stack_ == NULL )
		stack_ = (char*)malloc( sizeof( unsigned char)*length );
	
	array_ = array;
	
	while( i < length ) {
		if( *( p + i ) == 0x0A ) {
			currentEntryHead_ = p+currentHead;
			currentEntryLength_ = i-currentHead;
			[self parseAnEntry:p+currentHead length:(i-currentHead)];
			currentHead = i + 1;
			i++;
		}
		else {
			i++;
		}
	}
//	start_time = CFAbsoluteTimeGetCurrent();
	layout( array, 300 );
//	end_time = CFAbsoluteTimeGetCurrent();
//	DNSLog(@"New %f seconds", end_time - start_time );
	free( stack_ );
	stack_ = NULL;
	array_ = nil;
}

@end
