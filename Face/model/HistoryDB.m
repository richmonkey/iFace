//
//  HistoryDB.m
//  Face
//
//  Created by houxh on 14-10-14.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "HistoryDB.h"

@implementation HistoryDB
+(HistoryDB*)instance {
    static HistoryDB *db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!db) {
            db = [[HistoryDB alloc] init];
        }
    });
    return db;
}

-(BOOL)addHistory:(History*)h {
    return NO;
}
-(BOOL)updateHistoryFlag:(History*)h {
    return NO;
}

-(NSArray*)loadHistoryDB {
    return nil;
}

@end
