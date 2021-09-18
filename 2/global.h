
#ifndef _GLOBAL

#import "MyApp.h"
#import <GraphicsServices/GraphicsServices.h>
#import <unistd.h>

#define _DEBUG

#ifdef		_DEBUG
	#define	DNSLog(...);			NSLog(__VA_ARGS__);
	//#define _DECODING_DEBUG
#else
	#define DNSLog(...);			// NSLog(__VA_ARGS__);
#endif

#define		UIApp		(MyApp*)UIApp

//	definition encode/decode
#define		READ_FROM_MENU_HTML			NSShiftJISStringEncoding		// bbsmenu.html is encoded by shift-jis
#define		OUTPUT_ENCODE_TYPE			NSUTF8StringEncoding			// output encode type is utf-8?
#define		READ_FROM_XML				NSUTF8StringEncoding
#define		OUTPUT_INTO_GUI				NSUTF8StringEncoding

// propotion of Japanese font and alphabet one.
#define		RATIO_CHAR_J_AND_A			0.6f

// font setting
#define		NORMAL_FONT_NAME			"applegothic"
#define		FIXEDPITCH_FONT_NAME		"hiragino kaku gothic pron"//"courier new"

// for identifying swipe direction
enum kSwipeDirection {
	kSwipeDirectionUp		= 1,
	kSwipeDirectionDown		= 2,
	kSwipeDirectionRight	= 4,
	kSwipeDirectionLeft		= 8
};

enum {
	kGSFontTraitNormal		= 0
};

typedef enum {
	UITransitionNothing			= 0,	// エフェクトなし
	UITransitionBothShiftLeft	= 1,	// 次のビューと今のビューが左へ移動
	UITransitionBothShiftRight	= 2,	// 次のビューと今のビューが右へ移動
	UITransitionBothShiftUp		= 3,	// 次のビューと今のビューが上へ移動
	UITransitionError4			= 4,	// エラー
	UITransitionCurrentShiftDown= 5,	// 今のビューが下移動し，次のビューがエフェクトなし
	UITransitionError6			= 6,	// エラー
	UITransitionBothShiftDown	= 7,	// 次のビューと今のビューが下へ移動
	UITransitionNextShiftUp		= 8,	// 今のviewは，そのままで，次のviewが下から上へ移動
	UITransitionNextShiftDown	= 9		// 今のviewは，そのままで，次のviewが上から下へ移動
} UITransitionStyle;

// declaration prototype of global functions
NSString* eliminate(NSString* inputStr);
void convertHTMLTag(NSMutableString* str);
void convertSpecialChar(NSMutableString* str);
NSString* getConvertedSpecialChar(NSString* input);
NSString* getThreadNumber (NSString* input);
void eliminateHTMLTag(NSMutableString* str);
void initDictionariesForHTMLDecode();
void releaseDictionariesForHTMLDecode();
NSString* divideStringWithWidthAndFontSize( NSString* str, float width, float fontSize);
NSString* divideStringWithWidthAndFontSizeOnlyLines( NSString* str, float width, float fontSize, int lines );
NSString* decodeNSData(NSData* data);
void releaseDataCode();
void initDataCode();

// protocol?

@interface UIView (_2tch)
- (void) didForwardAndGotFocus:(id) fp;
- (void) didBackAndGotFocus:(id) fp;
- (void) lostFocus:(id) fp;
@end

@interface NSObject (_2tch)
- (void) didFinishLoadging:(id)fp;
- (void) didFailLoadging:(NSString*)str;
@end


#endif