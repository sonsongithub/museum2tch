
#ifndef _GLOBAL

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <GraphicsServices/GraphicsServices.h>
#import "MyApp.h"

//#define		_DEBUG

// like singleton, for access UIApp instance
#define		UIApp						(MyApp*)UIApp

// transition mode
#define		TRANSITION_VIEW_FORWARD		1
#define		TRANSITION_VIEW_BACK		2

//	definition encode/decode
#define		READ_FROM_MENU_HTML			NSShiftJISStringEncoding		// bbsmenu.html is encoded by shift-jis
#define		OUTPUT_ENCODE_TYPE			NSUTF8StringEncoding			// output encode type is utf-8?
#define		READ_FROM_XML				NSUTF8StringEncoding
#define		OUTPUT_INTO_GUI				NSUTF8StringEncoding

// identifier for reading bbsmenu, this must be improved. it has to use NSDictionary.
#define		TITLE_ARRAY_APPEND			0
#define		HREF_ARRAY_APPEND			1
#define		CATEGORY_ARRAY_APPEND		2

// folder name under ~/Library/Preferences/
#define		PREFERENCE_PATH				@"com.sonson.2tch"

// version string, is shown on PreferenceView
#define		VERSION_STRING_2CH_VIEWER	@"2tch version 1.1.1a"
#define		USER_AGENT					@"Monazilla/1.00 (2tch/1.1)"

// bbsmenu.html uri
#define		BOARD_URL_MENU				@"http://menu.2ch.net/bbsmenu.html"
#define		BOARD_URL_TERMINATER		@"http://count.2ch.net/?bbsmenu"

// don't change easy
#define		DAY_OF_THE_WEEK				7
#define		THREAD_INDEX_PAGE			50
#define		THREAD_PAGE					50

// NSLog is canceled when _DEBUG isn't declared.
#ifdef		_DEBUG
	#define	DNSLog(...);				NSLog(__VA_ARGS__);
#else
	#define DNSLog(...);				// NSLog(__VA_ARGS__);
#endif

// propotion of Japanese font and alphabet one.
#define		RATIO_CHAR_J_AND_A			0.6f

// font setting
#define		NORMAL_FONT_NAME			"applegothic"
#define		FIXEDPITCH_FONT_NAME		"courier new"

// for Navigationbar's button
extern NSString *kUIButtonBarButtonAction;
extern NSString *kUIButtonBarButtonInfo;
extern NSString *kUIButtonBarButtonInfoOffset;
extern NSString *kUIButtonBarButtonSelectedInfo;
extern NSString *kUIButtonBarButtonStyle;
extern NSString *kUIButtonBarButtonTag;
extern NSString *kUIButtonBarButtonTarget;
extern NSString *kUIButtonBarButtonTitle;
extern NSString *kUIButtonBarButtonTitleVerticalHeight;
extern NSString *kUIButtonBarButtonTitleWidth;
extern NSString *kUIButtonBarButtonType;

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
void eliminateHTMLTag(NSMutableString* str);
void initDictionariesForHTMLDecode();
void releaseDictionariesForHTMLDecode();
NSString* divideStringWithWidthAndFontSize( NSString* str, float width, float fontSize);
NSString* decodeNSData(NSData* data);
void releaseDataCode();
void initDataCode();

#endif