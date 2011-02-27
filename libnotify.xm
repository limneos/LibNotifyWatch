#include <notify.h>
#include <substrate.h>
#include <sqlite3.h>
#include <string.h>
#import <CoreFoundation/CFNotificationCenter.h>
#import <CPDistributedMessagingCenter.h>

// init define static variables
static BOOL hookNSNotifCenter=1;
static BOOL hookDarwin=1;
static BOOL hookNotifyPost=1;
static BOOL hookCopyAppValue=0;
static BOOL hookSqlite=0;
static BOOL hookCPDistMess=0;
static BOOL hooksEnabled=1;
static NSString *filter=nil;
// end define static variables



// init notify_post hook
static uint32_t (*original_notify_post)(const char *name);

uint32_t replaced_notify_post(const char *name) {

 if (hookNotifyPost){

	if (nil != filter){
			
			NSString *pSTRING=[[NSString alloc] initWithCString:name];
			NSRange range=[pSTRING rangeOfString:filter options:(NSCaseInsensitiveSearch)];
			[pSTRING release];
			if (range.location!=NSNotFound){
				NSLog(@"LibNotifyWatch: notify_post %s",name);
			}
	}
	else {
		NSLog(@"LibNotifyWatch: notify_post %s",name);
	} 
 }

return original_notify_post(name);
}
// end notify_post hook





// init CFPreferencesCopyAppValue hook
static CFPropertyListRef (*orig_CFPreferencesCopyAppValue)(CFStringRef key,CFStringRef applicationID);
 
CFPropertyListRef replaced_CFPreferencesCopyAppValue(CFStringRef key,CFStringRef applicationID){
	
 if (hookCopyAppValue){
	if (nil != filter){
			CFStringRef searchString=CFStringCreateWithCString(nil, [filter UTF8String], kCFStringEncodingUTF8);
			CFRange range1=CFStringFind(key,searchString,kCFCompareCaseInsensitive);
			CFRange range2=CFStringFind(applicationID,searchString,kCFCompareCaseInsensitive);
			CFRelease(searchString);
			if (range1.length>0 || range2.length>0){
				NSLog(@"LibNotifyWatch: CFPreferencesCopyAppValue key=%@ applicationID=%@",key,applicationID);
			}
	}
	else {
		NSLog(@"LibNotifyWatch: CFPreferencesCopyAppValue key=%@ applicationID=%@",key,applicationID);
	}
 }
 
return orig_CFPreferencesCopyAppValue(key,applicationID);

}
// end CFPreferencesCopyAppValue hook







// init CFNotificationCenterPostNotification hook
void (*orig_CFNotificationCenterPostNotification) (
   CFNotificationCenterRef center,
   CFStringRef name,
   const void *object,
   CFDictionaryRef userInfo,
   Boolean deliverImmediately
);

void replaced_CFNotificationCenterPostNotification (   
CFNotificationCenterRef center,
   CFStringRef name,
   const void *object,
   CFDictionaryRef userInfo,
   Boolean deliverImmediately
){
 if (hookDarwin){
	if (nil != filter){
			CFStringRef searchString=CFStringCreateWithCString(nil, [filter UTF8String], kCFStringEncodingUTF8);
			CFRange range=CFStringFind(name,searchString,kCFCompareCaseInsensitive);
			CFRelease(searchString);
			if (range.length>0){
			
				NSLog(@"LibNotifyWatch: CFNotificationCenterPostNotification center=%@ name=%@ userInfo=%@ deliverImmediately=%d",center,name,(NSDictionary *)userInfo,deliverImmediately);
			}
	}
	else {
		NSLog(@"LibNotifyWatch: CFNotificationCenterPostNotification center=%@ name=%@ userInfo=%@ deliverImmediately=%d",center,name,(NSDictionary *)userInfo,deliverImmediately);
	}
 }

 orig_CFNotificationCenterPostNotification(center,name,object,userInfo,deliverImmediately);

}
// end CFNotificationCenterPostNotification hook








// init sqlite3_prepare_v2 hook
 int (* orig_sqlite3_prepare_v2)(
  sqlite3 *db,            /* Database handle */
  const char *zSql,       /* SQL statement, UTF-8 encoded */
  int nByte,              /* Maximum length of zSql in bytes. */
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
  const char **pzTail     /* OUT: Pointer to unused portion of zSql */
);

 int  replaced_sqlite3_prepare_v2(
  sqlite3 *db,            /* Database handle */
  const char *zSql,       /* SQL statement, UTF-8 encoded */
  int nByte,              /* Maximum length of zSql in bytes. */
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
  const char **pzTail     /* OUT: Pointer to unused portion of zSql */
){

int res=orig_sqlite3_prepare_v2(db,zSql,nByte,ppStmt,pzTail);
if (hookSqlite){
	if (nil != filter){
		NSString *sqString=[[NSString alloc] initWithCString:zSql ];
		NSRange range=[sqString rangeOfString:filter];
		[sqString release];
			if (range.location!=NSNotFound){
				NSLog(@"LibNotifyWatch: SQLITE3_PREPARE_V2 query=%s ",zSql);
			}
	}
	else{
		NSLog(@"LibNotifyWatch: SQLITE3_PREPARE_V2 query=%s",zSql);
	}
}
return res;
}
// end sqlite3_prepare_v2 hook








// init NSNotificationCenter hook
%hook NSNotificationCenter
- (void)postNotification:(NSNotification *)notification{
	
	if (hookNSNotifCenter && ((filter && [[notification name] rangeOfString:filter].location!=NSNotFound) || !filter) ){
			NSLog(@"LibNotifyWatch: %@ postNotification: %@",self,notification);
		}
	
%orig;
}
/*
- (void)postNotificationName:(NSString *)aName object:(id)anObject{
	
	if (hookNSNotifCenter){
		
		if (nil != filter){
		
			NSRange range=[aName rangeOfString:filter];
			if (range.location!=NSNotFound){
				NSLog(@"LibNotifyWatch: %@ postNotificationName: %@ object:%@",self,aName,anObject);
			}
			
		}
		
		else{
		
			NSLog(@"LibNotifyWatch: %@ postNotificationName: %@ object:%@",self,aName,anObject);
			
		}
		
	}
	
%orig;
}
*/
- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo{

	if (hookNSNotifCenter  && ((filter && [aName rangeOfString:filter].location!=NSNotFound) || !filter) ){
	
		NSLog(@"LibNotifyWatch: %@ postNotificationName:%@ object:%@ userInfo:%@",self,aName,anObject,aUserInfo);
		
	}
		
	
%orig;
}

%end
// end NSNotificationCenter hook


%hook CPDistributedMessagingCenter
-(BOOL)sendMessageName:(id)name userInfo:(id)info{
	if (hookCPDistMess && ((filter && [name rangeOfString:filter].location!=NSNotFound) || !filter)){
		 	NSLog(@"LibNotifyWatch: %@ sendMessageName:%@ userInfo:%@",self,name,info);
		}
return %orig;
}

/* 
-(id)sendMessageAndReceiveReplyName:(id)name userInfo:(id)info{
	if (hookCPDistMess){
		NSLog(@"LibNotifyWatch: %@ sendMessageAndReceiveReplyName:%@ userInfo:%@",self,name,info);
	}
return %orig;
}
*/
-(id)sendMessageAndReceiveReplyName:(id)name userInfo:(id)info error:(id*)error{
id result=%orig;
	if (hookCPDistMess  && ((filter && [name rangeOfString:filter].location!=NSNotFound) || !filter)){
		NSLog(@"LibNotifyWatch: %@ sendMessageAndReceiveReplyName:%@ userInfo:%@ error:na",self,name,info);
	}
return result;
}
-(void)sendMessageAndReceiveReplyName:(id)name userInfo:(id)info toTarget:(id)target selector:(SEL)selector context:(void*)context{
	if (hookCPDistMess  && ((filter && [name rangeOfString:filter].location!=NSNotFound) || !filter)){
		NSLog(@"LibNotifyWatch: %@ sendMessageAndReceiveReplyName:%@ userInfo:%@ toTarget:%@ selector:%: context",self,name,info,target,selector);
	}
%orig;
}
-(BOOL)_sendMessage:(id)message userInfo:(id)info receiveReply:(id*)reply error:(id*)error toTarget:(id)target selector:(SEL)selector context:(void*)context{
BOOL result=%orig;
	if (hookCPDistMess && ((filter && [message rangeOfString:filter].location!=NSNotFound) || !filter)){
		NSLog(@"LibNotifyWatch: %@ _sendMessage:%@ userInfo:%@ receiveReply:na error:na toTarget:%@ selector:%: context",self,message,info,target,selector);
	}
return result;
}
-(BOOL)_sendMessage:(id)message userInfoData:(id)data oolKey:(id)key oolData:(id)data4 receiveReply:(id*)reply error:(id*)error{
BOOL result=%orig;
	if (hookCPDistMess && ((filter && [message rangeOfString:filter].location!=NSNotFound) || !filter)){
		NSLog(@"LibNotifyWatch: %@ _sendMessage:%@ userInfoData:na receiveReply:na oolKey:na oolData:na receiveReply:na error:na",self,message);
	}
return result;
}

%end



// Obtain Preferences
static void getPreferences(){

NSDictionary *Prefs=[NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/libnotify.plist"];

 filter=Prefs!=nil ? ([Prefs objectForKey:@"filter"]!=nil ? (NSString *)[Prefs objectForKey:@"filter"] : nil) : nil;
 if ([filter isEqualToString:@""]){
 filter=nil;
 }
 if (filter){
 [filter retain];
 }
 
 hooksEnabled=Prefs!=nil ? ([Prefs objectForKey:@"enabled"]!=nil ? [[Prefs objectForKey:@"enabled"] boolValue] : 1) : 1;
 if (!hooksEnabled){
 hookNSNotifCenter=0;
 hookSqlite=0;
 hookDarwin=0;
 hookNotifyPost=0;
 hookCopyAppValue=0;
 hookCPDistMess=0;
 return ;
 }
 
 NSMutableArray *functionsArray=(NSMutableArray *)[Prefs objectForKey:@"functions"];
 NSMutableArray *enabledArray=[NSMutableArray array];
 
	for (NSDictionary *dict in functionsArray){
		if ([[dict valueForKey:@"Enabled"] boolValue]==YES){
			[enabledArray addObject:[dict valueForKey:@"functionName"]];
		}
	}
	
 hookNSNotifCenter=[enabledArray containsObject:@"NSNotificationCenter"];
 hookSqlite=[enabledArray containsObject:@"Sqlite3 Queries"];
 hookDarwin=[enabledArray containsObject:@"CFNotificationCenter(Darwin)"];
 hookNotifyPost=[enabledArray containsObject:@"notify_post"];
 hookCopyAppValue=[enabledArray containsObject:@"CFPreferencesCopyAppValue"];
 hookCPDistMess=[enabledArray containsObject:@"CPDistributedMessagingCenter"];
}



// init function to update Preferences on-the-fly
static void updatePrefs(CFNotificationCenterRef center,
					void *observer,
					CFStringRef name,
					const void *object,
					CFDictionaryRef userInfo) {
getPreferences();
}
// end function to update Preferences on-the-fly



// Constructor
__attribute__((constructor)) void libnotifywatchInit() {

 %init;
 
 NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
 
 CFNotificationCenterRef notifCenter = CFNotificationCenterGetDarwinNotifyCenter();
 CFNotificationCenterAddObserver(notifCenter, NULL, &updatePrefs, CFSTR("libnotify.prefsChanged"), NULL, 0);

 getPreferences();

		// replace original functions behavior
		MSHookFunction(sqlite3_prepare_v2, replaced_sqlite3_prepare_v2, &orig_sqlite3_prepare_v2);
		MSHookFunction((uint32_t *)notify_post, (uint32_t *)replaced_notify_post, (uint32_t **)&original_notify_post);
		MSHookFunction(CFPreferencesCopyAppValue, replaced_CFPreferencesCopyAppValue, &orig_CFPreferencesCopyAppValue);
		MSHookFunction(CFNotificationCenterPostNotification, replaced_CFNotificationCenterPostNotification, &orig_CFNotificationCenterPostNotification);
	
 [p drain];

}