//
//  ContactDB.m
//  Message
//
//  Created by daozhu on 14-7-5.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ContactDB.h"
#import <AddressBook/AddressBook.h>
#import "ABContact.h"
#import "UserDB.h"
#import "PhoneNumber.h"

@interface ContactDB()
@property(nonatomic, assign)ABAddressBookRef addressBook;
@property()NSArray *contacts;
@property(nonatomic)NSMutableArray *observers;
-(void)loadContacts;
@end

static void ABChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    ABAddressBookRevert([ContactDB instance].addressBook);
    [[ContactDB instance] loadContacts];
    for (id<ContactDBObserver> ob in [ContactDB instance].observers) {
        [ob onExternalChange];
    }
}

@implementation ContactDB

+(ContactDB*)instance {
    static ContactDB *db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!db) {
            db = [[ContactDB alloc] init];
        }
    });
    return db;
}

-(id)init {
    self = [super init];
    if (self) {
        self.observers = [NSMutableArray array];
        CFErrorRef err = nil;
        self.addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        if (err) {
            NSString *s = (__bridge NSString*)CFErrorCopyDescription(err);
            IMLog(@"address book error:%@", s);
            return nil;
        }
     
        __block BOOL accessGranted = NO;
        
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined) {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
                IMLog(@"grant:%d", granted);
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        } else if (status == kABAuthorizationStatusAuthorized){
            accessGranted = YES;
        } else {
            accessGranted = NO;
        }
        if (accessGranted) {
            ABAddressBookRegisterExternalChangeCallback(self.addressBook, ABChangeCallback, nil);
            [self loadContacts];
        }
        
    }
    return self;
}

-(void)addObserver:(id<ContactDBObserver>)ob {
    if ([self.observers containsObject:ob]) {
        return;
    }
    [self.observers addObject:ob];
}

-(void)removeObserver:(id<ContactDBObserver>)ob {
    [self.observers removeObject:ob];
}

-(void)loadContacts {
    IMLog(@"load contacts");
    NSArray *thePeople = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(self.addressBook);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:thePeople.count];
    for (id person in thePeople) {
        ABContact *contact = [[ABContact alloc] init];
        [self copyRecord:(ABRecordRef)person to:contact];
		[array addObject:contact];
    }
	self.contacts = array;
}

-(NSArray*)contactsArray {
    NSMutableArray *array = [NSMutableArray array];
    for (ABContact *contact in self.contacts) {
        IMContact *c = [[IMContact alloc] init];
        c.firstname = contact.firstname;
        c.middlename = contact.middlename;
        c.lastname = contact.lastname;
        c.recordID = contact.recordID;
        c.phoneDictionaries = contact.phoneDictionaries;
        
        NSMutableArray *users = [NSMutableArray array];
        for (NSDictionary *dict in contact.phoneDictionaries) {
            NSString *phone = [dict objectForKey:@"value"];
            PhoneNumber *phoneNumber = [[PhoneNumber alloc] initWithPhoneNumber:phone];
            User *u = [[UserDB instance] loadUserWithNumber:phoneNumber];
            if (u) {
                [users addObject:u];
            }
        }
        if ([users count] > 0) {
            c.users = users;
        }
        [array addObject:c];
    }
    return array;
}

-(ABRecordRef)recordRefWithRecordID:(ABRecordID) recordID {
	ABRecordRef contactrec = ABAddressBookGetPersonWithRecordID(self.addressBook, recordID);
    return contactrec;
}


-(int64_t)uidFromPhoneNumber:(NSString*)phone {
    char tmp[64] = {0};
    char *dst = tmp;
    const char *src = [phone UTF8String];

    while (*src) {
        if (isnumber(*src)){
            *dst++ = *src;
        }
        src++;
    }
    return [[NSString stringWithUTF8String:tmp] longLongValue];
}
-(ABContact*)loadContactWithNumber:(PhoneNumber*)number {
    for (ABContact *contact in self.contacts) {
        for (NSDictionary *dict in contact.phoneDictionaries) {
            NSString *s = [dict objectForKey:@"value"];
            PhoneNumber *n = [[PhoneNumber alloc] initWithPhoneNumber:s];
            if ([n.zoneNumber isEqualToString:number.zoneNumber]) {
                return contact;
            }
        }
    }
    return nil;
}


-(IMContact*)loadIMContact:(ABRecordID)recordID {
    IMContact *contact = [[IMContact alloc] init];
    ABRecordRef ref = [self recordRefWithRecordID:recordID];
    [self copyRecord:ref to:contact];
    
    NSMutableArray *users = [NSMutableArray array];
    for (NSDictionary *dict in contact.phoneDictionaries) {
        NSString *phone = [dict objectForKey:@"value"];
        PhoneNumber *number = [[PhoneNumber alloc] initWithPhoneNumber:phone];
        UserDB *db = [UserDB instance];
        User *u = [db loadUserWithNumber:number];
        if (u) {
            [users addObject:u];
        }
    }
    contact.users = users;
    return contact;
}


-(NSString *)getRecordString:(ABPropertyID)anID record:(ABRecordRef)record {
	return (__bridge NSString *) ABRecordCopyValue(record, anID);
}
#pragma mark Getting MultiValue Elements
- (NSArray *) arrayForProperty: (ABPropertyID) anID record:(ABRecordRef)record
{
	CFTypeRef theProperty = ABRecordCopyValue(record, anID);
	NSArray *items = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
	CFRelease(theProperty);
	return items;
}


- (NSArray *) labelsForProperty:(ABPropertyID)anID record:(ABRecordRef)record{
	CFTypeRef theProperty = ABRecordCopyValue(record, anID);
	NSMutableArray *labels = [NSMutableArray array];
	for (int i = 0; i < ABMultiValueGetCount(theProperty); i++)
	{
		NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(theProperty, i);
        if (label == nil) {
            [labels addObject:@""];
        } else {
            [labels addObject:label];
        }
	}
	CFRelease(theProperty);
	return labels;
}



- (NSArray *) dictionaryArrayForProperty:(ABPropertyID)aProperty record:(ABRecordRef)record
{
	NSArray *valueArray = [self arrayForProperty:aProperty record:record];
	NSArray *labelArray = [self labelsForProperty:aProperty record:record];
	
	int num = MIN(valueArray.count, labelArray.count);
	NSMutableArray *items = [NSMutableArray array];
	for (int i = 0; i < num; i++)
	{
		NSMutableDictionary *md = [NSMutableDictionary dictionary];
        [md setObject:[valueArray objectAtIndex:i] forKey:@"value"];
        NSDictionary *dictChn = @{
                                  @"_$!<Home>!$_" : @"住宅",
                                  @"_$!<Mobile>!$_" : @"移动",
                                  @"_$!<Work>!$_" : @"工作",
                                  @"_$!<WorkFAX>!$_" : @"工作传真",
                                  @"_$!<Main>!$_" : @"主要",
                                  @"_$!<HomeFAX>!$_" : @"住宅传真",
                                  @"_$!<Pager>!$_" : @"传呼",
                                  @"_$!<Other>!$_" : @"其他",
                               };
        
        NSString *originLabel = [labelArray objectAtIndex:i];
        NSString *label = [dictChn objectForKey:originLabel];
        if (!label) {
            label = @"其他";
        }
		[md setObject:label forKey:@"label"];
		[items addObject:md];
	}
	return items;
}


-(void)copyRecord:(ABRecordRef)record to:(ABContact*)contact{
    contact.recordID = ABRecordGetRecordID(record);
    contact.recordType = ABRecordGetRecordType(record);
    contact.firstname = [self getRecordString:kABPersonFirstNameProperty record:record];
    contact.lastname = [self getRecordString:kABPersonLastNameProperty record:record];
    contact.middlename = [self getRecordString:kABPersonMiddleNameProperty record:record];
    contact.prefix = [self getRecordString:kABPersonPrefixProperty record:record];
    contact.suffix = [self getRecordString:kABPersonSuffixProperty record:record];
    contact.nickname = [self getRecordString:kABPersonNicknameProperty record:record];
    
    contact.emailDictionaries = [self dictionaryArrayForProperty:kABPersonEmailProperty record:record];
    contact.phoneDictionaries = [self dictionaryArrayForProperty:kABPersonPhoneProperty record:record];
    contact.relatedNameDictionaries = [self dictionaryArrayForProperty:kABPersonRelatedNamesProperty record:record];
    contact.urlDictionaries =  [self dictionaryArrayForProperty:kABPersonURLProperty record:record];
    contact.dateDictionaries = [self dictionaryArrayForProperty:kABPersonDateProperty record:record];
    contact.addressDictionaries = [self dictionaryArrayForProperty:kABPersonAddressProperty record:record];
    contact.smsDictionaries = [self dictionaryArrayForProperty:kABPersonInstantMessageProperty record:record];
}

@end
