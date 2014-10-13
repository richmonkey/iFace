//
//  LevelDB.h
//  leveldb_ios
//
//  Created by houxh on 14-7-4.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelDBIterator : NSObject
-(void)seekToLast;
-(void)seekToFirst;
-(BOOL)isValid;
-(void)next;
-(void)prev;
-(NSString*)key;
-(NSString*)value;
-(void)seek:(NSString*)target;
@end



@interface LevelDB : NSObject
+(LevelDB*)levelDBWithPath:(NSString*)path;

+(LevelDB*)defaultLevelDB;

-(LevelDB*)initWithPath:(NSString*)path;



-(NSString*)stringForKey:(NSString*)key;
-(int64_t)intForKey:(NSString*)key;

-(void)setString:(NSString*)value forKey:(NSString*)key;
-(void)setInt:(int64_t)value forKey:(NSString*)key;

-(void)removeValueForKey:(NSString*)key;



-(LevelDBIterator*)newIterator;
@end
