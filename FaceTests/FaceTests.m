//
//  FaceTests.m
//  FaceTests
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HistoryDB.h"
@interface FaceTests : XCTestCase

@end

@implementation FaceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHistoryDB
{
    History *h = [[History alloc] init];
    h.beginTimestamp = 1;
    h.endTimestamp = 2;
    h.flag = FLAG_OUT;
    [[HistoryDB instance] addHistory:h];
    
    NSArray *array = [[HistoryDB instance] loadHistoryDB];
    for (History *h in array) {
        NSLog(@"history:%lld %d %ld %ld", h.hid, h.flag, h.beginTimestamp, h.endTimestamp);
    }
}

@end
