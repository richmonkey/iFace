//
//  LevelDB.m
//  leveldb_ios
//
//  Created by houxh on 14-7-4.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import "LevelDB.h"
#import "leveldb/db.h"


@interface LevelDBIterator()

@property(nonatomic, assign)leveldb::Iterator *iter;
-(LevelDBIterator*)initWithIterator:(leveldb::Iterator*)iter;

@end

@implementation LevelDBIterator
-(LevelDBIterator*)initWithIterator:(leveldb::Iterator*)iter {
  self = [super init];
  if (self) {
    self.iter = iter;
  }
  return self;
}

-(void)dealloc {
    delete self.iter;
}

-(void)seek:(NSString*)target {
  leveldb::Slice t([target UTF8String]);
  self.iter->Seek(t);
}

-(void)seekToLast {
  self.iter->SeekToLast();
}
-(void)seekToFirst {
  self.iter->SeekToFirst();
}
-(BOOL)isValid {
  return self.iter->Valid();
}
-(void)next {
  self.iter->Next();
}
-(void)prev {
  self.iter->Prev();
}
-(NSString*)key {
  leveldb::Slice k = self.iter->key();
  return [[NSString alloc] initWithBytes:k.data() length:k.size() encoding:NSUTF8StringEncoding];
}

-(NSString*)value {
  leveldb::Slice v = self.iter->value();
  return [[NSString alloc] initWithBytes:v.data() length:v.size() encoding:NSUTF8StringEncoding];
}

@end

@interface LevelDB()
@property(nonatomic, assign)leveldb::DB *db;
@end
@implementation LevelDB

+(LevelDB*)levelDBWithPath:(NSString*)path {
  LevelDB *db = [[LevelDB alloc] initWithPath:path];
  return db;
}

+(NSString*)getDefaultDBPath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingString:@"/leveldb"];
}

+(LevelDB*)defaultLevelDB {
  static LevelDB *db;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (!db) {
      NSString *path = [self getDefaultDBPath];
      db = [[LevelDB alloc] initWithPath:path];
    }
  });
  return db;
}

-(LevelDB*)initWithPath:(NSString*)path {
  self = [super init];
  if (self) {
    leveldb::DB* db;
    leveldb::Options options;
    options.create_if_missing = true;
    leveldb::Status status = leveldb::DB::Open(options, [path UTF8String], &db);
    assert(status.ok());
    self.db = db;
  }
  return self;
}

-(void)dealloc {
    delete self.db;
}

-(NSString*)stringForKey:(NSString*)key {
  std::string value;
  leveldb::Status s;
  leveldb::Slice ks([key UTF8String]);
  s = self.db->Get(leveldb::ReadOptions(), ks, &value);
  if (!s.ok()) {
    return nil;
  }
  return [NSString stringWithUTF8String:value.c_str()];
}

-(int64_t)intForKey:(NSString*)key {
  return [[self stringForKey:key] longLongValue];
}

-(void)setString:(NSString*)value forKey:(NSString*)key {
  leveldb::Status s;
  leveldb::Slice ks([key UTF8String]);
  leveldb::Slice vs([value UTF8String]);
  s = self.db->Put(leveldb::WriteOptions(), ks, vs);
  assert(s.ok());
  if (!s.ok()) {
    NSLog(@"set value fail");
  }
}

-(void)setInt:(int64_t)value forKey:(NSString*)key {
  NSString *v = [NSString stringWithFormat:@"%lld", value];
  [self setString:v forKey:key];
}

-(void)removeValueForKey:(NSString*)key {
  leveldb::Status s;
  leveldb::Slice ks([key UTF8String]);
  s = self.db->Delete(leveldb::WriteOptions(), ks);
  if (!s.ok()) {
    NSLog(@"remote key fail");
  }
  assert(s.ok());
}

-(LevelDBIterator*)newIterator {
  leveldb::Iterator *iter = self.db->NewIterator(leveldb::ReadOptions());
  LevelDBIterator *i = [[LevelDBIterator alloc] initWithIterator:iter];
  return i;
}

@end
