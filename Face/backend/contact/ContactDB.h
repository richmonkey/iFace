//
//  ContactDB.h
//  Message
//
//  Created by daozhu on 14-7-5.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABContact.h"
#import "IMContact.h"
#import "PhoneNumber.h"

@protocol ContactDBObserver<NSObject>
-(void)onExternalChange;
@end


@interface ContactDB : NSObject {
    
}

+(ContactDB*)instance;

-(void)addObserver:(id<ContactDBObserver>)ob;
-(void)removeObserver:(id<ContactDBObserver>)ob;

-(NSArray *)contactsArray;

-(ABRecordRef)recordRefWithRecordID:(ABRecordID)recordID;
-(int64_t)uidFromPhoneNumber:(NSString*)phone;

-(IMContact*)loadIMContact:(ABRecordID)recordID;
-(ABContact*)loadContactWithNumber:(PhoneNumber*)number;
@end
