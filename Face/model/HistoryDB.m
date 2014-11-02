//
//  HistoryDB.m
//  Face
//
//  Created by houxh on 14-10-14.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "HistoryDB.h"
#import "FMDatabase.h"

@interface HistoryDB()
@property(nonatomic) FMDatabase *db;
@end

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

-(id)init {
    self = [super init];
    if (self) {
        NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *dbPath   = [docsPath stringByAppendingPathComponent:@"voip.db"];
        self.db = [FMDatabase databaseWithPath:dbPath];
        if (self.db == nil) {
            NSLog(@"open db error");
        }
        BOOL r = [self.db open];
        if (!r) {
            NSLog(@"open db error:%@", [self.db lastErrorMessage]);
        }
        NSString *sql = @"CREATE TABLE IF NOT EXISTS history(hid INTEGER PRIMARY KEY AUTOINCREMENT,\
                            peer_uid INT, flag INT, create_timestamp INT, begin_timestamp INT, end_timestamp INT)";
        r = [self.db executeUpdate:sql];
        if (!r) {
            NSLog(@"create table last error:%d %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        }
    }
    return self;
}

-(BOOL)addHistory:(History*)h {
    NSString *sql = @"INSERT INTO history(peer_uid, flag, create_timestamp, begin_timestamp, end_timestamp) \
                        VALUES(:peer_uid, :flag, :create_timestamp, :begin_timestamp, :end_timestamp)";
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithLongLong:h.peerUID] forKey:@"peer_uid"];
    [dict setObject:[NSNumber numberWithInt:h.flag] forKey:@"flag"];
    [dict setObject:[NSNumber numberWithLong:h.createTimestamp] forKey:@"create_timestamp"];
    [dict setObject:[NSNumber numberWithLong:h.beginTimestamp] forKey:@"begin_timestamp"];
    [dict setObject:[NSNumber numberWithLong:h.endTimestamp] forKey:@"end_timestamp"];
     
    BOOL r = [self.db executeUpdate:sql withParameterDictionary:dict];
    if (!r) {
        NSLog(@"insert table error:%@", [self.db lastErrorMessage]);
        return NO;
    }
    h.hid = [self.db lastInsertRowId];
    return YES;
}


-(NSArray*)loadHistoryDB {
    NSString *sql = @"SELECT hid, peer_uid, flag, create_timestamp, begin_timestamp, end_timestamp FROM history ORDER BY hid DESC";
    FMResultSet *rs = [self.db executeQuery:sql];
    if (rs == nil) {
        NSLog(@"select table error:%@", [self.db lastErrorMessage]);
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    while ([rs next]) {
        History *h = [[History alloc] init];
        h.hid = [rs longLongIntForColumn:@"hid"];
        h.peerUID = [rs longLongIntForColumn:@"peer_uid"];
        h.flag = [rs intForColumn:@"flag"];
        h.createTimestamp = [rs longForColumn:@"create_timestamp"];
        h.beginTimestamp = [rs longForColumn:@"begin_timestamp"];
        h.endTimestamp = [rs longForColumn:@"end_timestamp"];
        [array addObject:h];
    }
    return array;
}

-(BOOL)removeHistory:(int64_t)hid {
    NSString *sql = @"DELETE FROM history WHERE hid=:hid";
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithLongLong:hid] forKey:@"hid"];
    return [self.db executeUpdate:sql withParameterDictionary:dict];
}

-(BOOL)clearHistoryDB {
    NSString *sql = @"DELETE  FROM history";
    return [self.db executeUpdate:sql];
}

@end
