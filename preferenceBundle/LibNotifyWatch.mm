#import <Preferences/PSRootController.h>
#import <Preferences/PSViewController.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <substrate.h>
#import <notify.h>


@interface LibNotifyViewController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *tblView;
	NSMutableArray *functions;
	NSMutableDictionary *dict;
	NSString *dictPath;
		
}
@property (nonatomic, retain) UITableView *tblView;
@property (nonatomic, retain) NSMutableArray *functions;
@property (nonatomic, retain) NSMutableDictionary *dict;
@property (nonatomic, retain) NSString *dictPath;


- (id) initForContentSize:(CGSize)size ;

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section;
- (void) dealloc;
- (id) navigationTitle;
- (id) view;
- (int) numberOfSectionsInTableView:(UITableView *)tableView;
@end



@interface LibNotifyController: PSListController {
}
@end







@implementation LibNotifyViewController
@synthesize functions,tblView,dict,dictPath;
static id shd=nil;
+(id)sharedInstance{
if (!shd){
shd=[[self alloc] initForContentSize:CGSizeMake(320,480)];
}
return shd;
}
- (id) initForContentSize:(CGSize)size {

    if ((self = [super initForContentSize:size]) != nil) {
	    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
		self.dictPath=@"/var/mobile/Library/Preferences/libnotify.plist";
		self.dict=[NSMutableDictionary dictionaryWithContentsOfFile:self.dictPath];
		
				
		if (!self.dict || [self.dict valueForKey:@"functions"]==nil){
		NSMutableDictionary *dictnotifypost=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:1],@"Enabled",@"notify_post",@"functionName",nil];
		NSMutableDictionary *dictDarwin=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:1],@"Enabled",@"CFNotificationCenter(Darwin)",@"functionName",nil];
		NSMutableDictionary *dictNSNotif=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:1],@"Enabled",@"NSNotificationCenter",@"functionName",nil];
		NSMutableDictionary *dictCopyAppValue=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:0],@"Enabled",@"CFPreferencesCopyAppValue",@"functionName",nil];
		NSMutableDictionary *dictSqlite=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:0],@"Enabled",@"Sqlite3 Queries",@"functionName",nil];
		NSMutableDictionary *dictCPDist=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:0],@"Enabled",@"CPDistributedMessagingCenter",@"functionName",nil];
		
		NSMutableArray *functArr=[NSMutableArray arrayWithObjects:dictnotifypost,dictDarwin,dictCPDist,dictNSNotif,dictCopyAppValue,dictSqlite,nil];
		self.dict=[NSMutableDictionary dictionary];
		[self.dict setObject:functArr forKey:@"functions"];
		[self.dict writeToFile:self.dictPath atomically:YES];
		self.functions=[self.dict objectForKey:@"functions"];
		}
		else{
		self.functions=[self.dict objectForKey:@"functions"];
		}
		
		
		
        self.tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStyleGrouped];
        [self.tblView setDataSource:self];
        [self.tblView setDelegate:self];
        [self.tblView setEditing:YES];
        [self.tblView setAllowsSelectionDuringEditing:YES];
        if ([self respondsToSelector:@selector(setView:)])
            [self setView:self.tblView];
			
				[pool drain];
	}
return self;
}



- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    return nil;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
    
	return self.functions.count;
	
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FunctionCell"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:@"FunctionCell"] autorelease];
    }
		NSAutoreleasePool *p=[[NSAutoreleasePool alloc] init];
    
	NSString *function=[self.functions objectAtIndex:indexPath.row];
    cell.text = [function valueForKey:@"functionName"];
    cell.hidesAccessoryWhenEditing = NO;

	
	if ([[function valueForKey:@"Enabled"] boolValue]==1){
	[cell setImage:[UIImage imageWithContentsOfFile: [[NSBundle bundleWithIdentifier:@"libnotify"] pathForResource:@"BlueCheck" ofType:@"png"] ] ];
	
	}
	else{
	[cell setImage:[UIImage imageWithContentsOfFile: [[NSBundle bundleWithIdentifier:@"libnotify"] pathForResource:@"WhiteSpace" ofType:@"png"] ] ];
	
	}
	
	[p drain];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	[cell setSelectedTextColor:[UIColor whiteColor]];
	
	if ([[[self.functions objectAtIndex:indexPath.row] valueForKey:@"Enabled"] boolValue]==0){
	[[self.functions objectAtIndex:indexPath.row] setValue:[NSNumber numberWithBool:1] forKey:@"Enabled"];
	[self.dict setObject:self.functions forKey:@"functions"];
	[self.dict writeToFile:self.dictPath atomically:YES];
	[cell setImage:[UIImage imageWithContentsOfFile: [[NSBundle bundleWithIdentifier:@"libnotify"] pathForResource:@"BlueCheck" ofType:@"png"] ] ];
	}
	
	else{
	[[self.functions objectAtIndex:indexPath.row] setValue:[NSNumber numberWithBool:0] forKey:@"Enabled"];
	[self.dict setObject:self.functions forKey:@"functions"];
	[self.dict writeToFile:self.dictPath atomically:YES];
	[cell setImage:[UIImage imageWithContentsOfFile: [[NSBundle bundleWithIdentifier:@"libnotify"] pathForResource:@"WhiteSpace" ofType:@"png"] ] ];
	}

	[tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:YES];
 	[tableView reloadData];
	notify_post("libnotify.prefsChanged");
}



- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (void) dealloc {
    [self.tblView release];
    [self.functions release];
	[self.dictPath release];
	[self.dict release];
	[super dealloc];
}

- (id) navigationTitle {
    return @"Functions";
}
- (id) title {
    return @"Functions";
}

- (id) view {
    return self.tblView;
}


@end










@implementation LibNotifyController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"LibNotifyWatch" target:self] retain];
	}
	return _specifiers;
}
@end


#define WBSAddMethod(_class, _sel, _imp, _type) \
    if (![[_class class] instancesRespondToSelector:@selector(_sel)]) \
        class_addMethod([_class class], @selector(_sel), (IMP)_imp, _type)
void $PSRootController$popController(PSRootController *self, SEL _cmd) {
    [self popViewControllerAnimated:YES];
}

void $PSViewController$hideNavigationBarButtons(PSRootController *self, SEL _cmd) {
}

id $PSViewController$initForContentSize$(PSRootController *self, SEL _cmd, CGRect contentSize) {
    return [self init];
}

static __attribute__((constructor)) void __dcsInit() {
	NSAutoreleasePool *p=[[NSAutoreleasePool alloc] init];
    WBSAddMethod(PSRootController, popController, $PSRootController$popController, "v@:");
    WBSAddMethod(PSViewController, hideNavigationBarButtons, $PSViewController$hideNavigationBarButtons, "v@:");
    WBSAddMethod(PSViewController, initForContentSize:, $PSViewController$initForContentSize$, "@@:{ff}");
	[p drain];
}
