//
//  HistoryDB.h
//  Face
//
//  Created by houxh on 14-10-14.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "History.h"

@interface HistoryDB : NSObject
+(HistoryDB*)instance;

-(BOOL)addHistory:(History*)h;

-(NSArray*)loadHistoryDB;

@end
