#import "ContactListTableViewController.h"
#import "pinyin.h"
#import "LevelDB.h"
#import "TAHttpOperation.h"
#import "Config.h"
#import "UserDB.h"
#import "Token.h"
#import "ContactViewController.h"
#import "UserPresent.h"
#import "APIRequest.h"

@interface ContactListTableViewController()
@property (nonatomic) NSArray *contacts;
@property (nonatomic) NSMutableArray *filteredArray;
@property (nonatomic) NSMutableArray *sectionArray;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UISearchDisplayController *searchDC;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UINavigationController *aBPersonNav;

@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) UITableView *selectedTableView;

@property (nonatomic) NSTimer *updateStateTimer;

@end

@implementation ContactListTableViewController
- (id)init{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.navigationItem.title = @"所有联系人";
	
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f,kStatusBarHeight + KNavigationBarHeight, self.view.frame.size.width, kSearchBarHeight)];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
	
    self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] ;
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.scrollEnabled = YES;
	self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.separatorColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0];
    
    self.tableView.frame = CGRectMake(0, KNavigationBarHeight + kStatusBarHeight + kSearchBarHeight, self.view.frame.size.width, self.view.frame.size.height - (KNavigationBarHeight + kStatusBarHeight + kSearchBarHeight + kTabBarHeight));
    NSLog(@"height:%f", self.view.frame.size.height);
	[self.view addSubview:self.tableView];

    UILabel *head = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    PhoneNumber *phoneNumber = [UserPresent instance].phoneNumber;
    NSString *s = [NSString stringWithFormat:@"   我的电话号码: +%@ %@", phoneNumber.zone, phoneNumber.number];
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString: s];
    [attrTitle addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x35bc6e) range:NSMakeRange(10, [s length]-10)];
 
    [head setAttributedText:attrTitle];
    
    self.tableView.tableHeaderView = head;
    
    [[ContactDB instance] addObserver:self];
    [self loadData];
    [self requestUsers];
    self.updateStateTimer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(updateUserState:) userInfo:nil repeats:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.selectedTableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    self.selectedIndexPath = nil;
    self.selectedTableView = nil;
}

-(NSString*)getSectionName:(NSString*)string {
    NSString *sectionName;
    if([self searchResult:string searchText:@"曾"]){
        sectionName = @"Z";
    }else if([self searchResult:string searchText:@"解"]){
        sectionName = @"X";
    }else if([self searchResult:string searchText:@"仇"]){
        sectionName = @"Q";
    }else if([self searchResult:string searchText:@"朴"]){
        sectionName = @"P";
    }else if([self searchResult:string searchText:@"查"]){
        sectionName = @"Z";
    }else if([self searchResult:string searchText:@"能"]){
        sectionName = @"N";
    }else if([self searchResult:string searchText:@"乐"]){
        sectionName = @"Y";
    }else if([self searchResult:string searchText:@"单"]){
        sectionName = @"S";
    }else{
        NSString *first = [NSString stringWithFormat:@"%c",pinyinFirstLetter([string characterAtIndex:0])];
        sectionName = [first uppercaseString];
    }
    return sectionName;
}

-(void)updateUserState:(NSTimer*)timer {
    [self requestUsers];
}

-(void)requestUsers {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = @"request_timestamp";
    int t = (int)[db intForKey:key];
    if (time(NULL) - t < 24*3600) {
      //  return;
    }
    IMLog(@"request users.....");
    [APIRequest requestUsers:self.contacts
                     success:^(NSArray *resp) {
                         for (NSDictionary *dict in resp) {
                             User *user = [[User alloc] init];
                             PhoneNumber *number = [[PhoneNumber alloc] init];
                             number.zone = [dict objectForKey:@"zone"];
                             number.number = [dict objectForKey:@"number"];
                             user.uid = [[dict objectForKey:@"uid"] longLongValue];
                             user.avatarURL = [dict objectForKey:@"avatar"];
                             user.state = [dict objectForKey:@"state"];
                             user.lastUpTimestamp = [[dict objectForKey:@"up_timestamp"] longLongValue];
                             user.phoneNumber = number;
                             if (user.uid > 0) {
                                 [[UserDB instance] addUser:user];
                             }
                         }
                         LevelDB *db = [LevelDB defaultLevelDB];
                         [db setInt:time(NULL) forKey:key];
                         [self loadData];
                         [self.tableView reloadData];
                         
                     }
                        fail:^{
                            IMLog(@"request users fail");
                        }];
}

-(void)loadData{
    self.contacts = [[ContactDB instance] contactsArray];

    self.filteredArray =  [NSMutableArray array];
    self.sectionArray = [NSMutableArray arrayWithCapacity:27];
  
    for (int i = 0; i < 27; i++){
        [self.sectionArray addObject:[NSMutableArray array]];
    }
    
	if([self.contacts count] == 0) {
        return;
	}
    
	for (IMContact *contact in self.contacts) {
        NSString *string = contact.contactName;
        if ([contact.users count] > 0) {
            User *user = [contact.users objectAtIndex:0];
            NSLog(@"name:%@ state:%@", string, user.state);
        }
        
        NSString *sectionName;
        if ([string length] > 0) {
            sectionName = [self getSectionName:string];
            NSUInteger firstLetter = [ALPHA rangeOfString:sectionName].location;
            if (firstLetter != NSNotFound){
                [[self.sectionArray objectAtIndex:firstLetter] addObject:contact];
            } else {
                firstLetter = [ALPHA rangeOfString:@"#"].location;
                [[self.sectionArray objectAtIndex:firstLetter] addObject:contact];
            }
        } else {
            NSUInteger firstLetter = [ALPHA rangeOfString:@"#"].location;
            [[self.sectionArray objectAtIndex:firstLetter] addObject:contact];
        }
	}
}

-(void)onExternalChange {
    [self loadData];
    [self requestUsers];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    if (aTableView == self.tableView){
        return 27;
    } else {
        return 1;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView {
	if (aTableView == self.tableView) {
		NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
		for (int i = 0; i < 27; i++){
			if ([[self.sectionArray objectAtIndex:i] count]){
                NSRange range = NSMakeRange(i, 1);
				[indices addObject:[ALPHA substringWithRange:range]];
            }
        }
		return indices;
	} else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [ALPHA rangeOfString:title].location;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (aTableView == self.tableView) {
		if ([[self.sectionArray objectAtIndex:section] count] == 0) {
            return nil;
        }
        NSRange range = NSMakeRange(section, 1);
        return [ALPHA substringWithRange:range];
	} else {
        return nil;
    }
}

//获取每一个字符的拼音的首字符
-(NSString*)getPinYin:(NSString*)string {
    NSString *name = @"";
    for (int i = 0; i < [string length]; i++)
    {
        if([name length] < 1) {
            name = [self getSectionName:string];
        } else {
            name = [NSString stringWithFormat:@"%@%c",name,pinyinFirstLetter([string characterAtIndex:i])];
        }
    }
    return name;
}

-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
	NSComparisonResult result = [contactName compare:searchT options:NSCaseInsensitiveSearch
                                               range:NSMakeRange(0, searchT.length)];
	if (result == NSOrderedSame)
		return YES;
	else
		return NO;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if (aTableView == self.tableView){
        return [[self.sectionArray objectAtIndex:section] count];
	} else {
        return self.filteredArray.count;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.filteredArray removeAllObjects];

    for(IMContact *contact in self.contacts) {
        NSString *string = contact.contactName;
        if (string.length == 0) {
            continue;
        }
        
        NSString *name = [self getPinYin:string];
        
        if ([self searchResult:name searchText:self.searchBar.text]) {
            [self.filteredArray addObject:contact];
        } else if ([self searchResult:string searchText:self.searchBar.text]) {
            [self.filteredArray addObject:contact];
        }
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)asearchBar {
    //move the search bar up to the correct location eg
    [UIView animateWithDuration:.1
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                                           kStatusBarHeight+KNavigationBarHeight,
                                                           self.tableView.frame.size.width,
                                                           self.tableView.frame.size.height + kStatusBarHeight+KNavigationBarHeight);
                         self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                                      kStatusBarHeight,
                                                      self.searchBar.frame.size.width,
                                                      self.searchBar.frame.size.height);

                     }
                     completion:^(BOOL finished){
                         
                     }];
    [self.searchDisplayController setActive:YES animated:YES];
}

- (void) resetSearchBarPosition{
    [UIView animateWithDuration:.1
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                                           KNavigationBarHeight + kStatusBarHeight + kSearchBarHeight,
                                                           self.tableView.frame.size.width,
                                                           self.tableView.frame.size.height - kStatusBarHeight - KNavigationBarHeight);
                         self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                                           KNavigationBarHeight + kStatusBarHeight,
                                                           self.searchBar.frame.size.width,
                                                           self.searchBar.frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //move the search bar down to the correct location eg
    if (searchBar.text.length > 0) {
        return;
    }
    
    [self resetSearchBarPosition];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
	[self.searchBar setText:@""];
    
    if (![searchBar isFirstResponder]) {
        [self resetSearchBarPosition];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView == tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
        }
        
        NSArray *section = [self.sectionArray objectAtIndex:indexPath.section];
        IMContact *contact = [section objectAtIndex:indexPath.row];
        [cell.textLabel setText:contact.contactName];
        if ([contact.users count]) {
            if ([contact.users count] > 1) {
                [cell.detailTextLabel setText:@"多重自定义状态"];
            } else {
                User *u = [contact.users objectAtIndex:0];
                if (u.state.length > 0) {
                    [cell.detailTextLabel setText:u.state];
                }else{
                    [cell.detailTextLabel setText:@"~没有状态~"];
                }
                NSLog(@"name:%@ state:%@", contact.contactName, u.state);
            }
        } else {
            [cell.detailTextLabel setText:@""];
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
        }

        IMContact *contact = [self.filteredArray objectAtIndex:indexPath.row];
        [cell.textLabel setText:contact.contactName];
        return cell;
    }
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	IMContact *contact;
	if (aTableView == self.tableView){
		contact = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	}else{
		contact = [self.filteredArray objectAtIndex:indexPath.row];
    }
  
    ContactViewController *ctl = [[ContactViewController alloc] init];
    ctl.hidesBottomBarWhenPushed = YES;
    ctl.contact = [[ContactDB instance] loadIMContact:contact.recordID];
    [self.navigationController pushViewController:ctl animated:YES];
    self.selectedTableView = aTableView;
    self.selectedIndexPath = indexPath;
}



#pragma mark - Action

- (void)cancelBtnAction:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark NEW PERSON DELEGATE METHODS
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
