
//
// Some useful macros
//



#define DEBUG
#ifndef DEBUG

#define NSLog(...) 
#define logit(...) 

#else 

#define logit(str)		NSLog(@"%s: %s:%d\n>> %@ <<", __FILE__, __FUNCTION__, __LINE__, str)

#endif

#define OS_VERSION    ([[[UIDevice currentDevice] systemVersion] doubleValue])

#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 

#define SAFE_RELEASE(obj)			do{if(obj && [obj retainCount]) { [obj release]; obj = nil;}}while(0)

#define alert(msg)					UIAlertView *someAlert = [[UIAlertView alloc] initWithTitle: @"Alert" message:[NSString stringWithFormat:@"%@", msg] delegate:self cancelButtonTitle: @"OK" otherButtonTitles:nil]; \
[someAlert show]; \
[someAlert release]

#define alert_again(msg)			someAlert = [[UIAlertView alloc] initWithTitle: @"Alert" message:[NSString stringWithFormat:@"%@", msg] delegate:self cancelButtonTitle: @"OK" otherButtonTitles:nil]; \
[someAlert show]; \
[someAlert release]

#define RGB(r,g,b)					[UIColor colorWithRed:((r##.0)/255.0) green:((g##.0)/255.0) blue:((b##.0)/255.0) alpha:1.0]

#define SET_KEYVAL(key,val)			[[NSUserDefaults standardUserDefaults] setObject:val forKey:key]
#define GET_KEYVAL(key)				[[NSUserDefaults standardUserDefaults] objectForKey:key]

#define GET_SETTING(key)			[[AppGlobals sharedAppGlobals] getSetting:key]
#define GET_SETTING_INTVAL(key)		[GET_SETTING(key) intValue]



#define streq(str1, str2)           ([str1 compare:str2] == NSOrderedSame)

