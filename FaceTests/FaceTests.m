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
    NSArray *array;
    
    [[HistoryDB instance] clearHistoryDB];
    
    array = [[HistoryDB instance] loadHistoryDB];
    XCTAssertEqual(array.count, 0, @"");
    
    
    History *h = [[History alloc] init];
    h.peerUID = 86013800000000;
    h.createTimestamp = 100;
    h.beginTimestamp = 1;
    h.endTimestamp = 2;
    h.flag = FLAG_OUT;
    [[HistoryDB instance] addHistory:h];
    

    array = [[HistoryDB instance] loadHistoryDB];
     XCTAssertEqual(array.count, 1, @"");
    for (History *h in array) {
        NSLog(@"history:%lld %lld, %d %ld, %ld %ld", h.hid, h.peerUID, h.flag, h.createTimestamp, h.beginTimestamp, h.endTimestamp);
    }
    
    [[HistoryDB instance] removeHistory:h.hid];
    
    array = [[HistoryDB instance] loadHistoryDB];
    XCTAssertEqual(array.count, 0, @"");

    [[HistoryDB instance] addHistory:h];
    
    array = [[HistoryDB instance] loadHistoryDB];
    XCTAssertEqual(array.count, 1, @"");
    
    [[HistoryDB instance] clearHistoryDB];
    
    array = [[HistoryDB instance] loadHistoryDB];
    XCTAssertEqual(array.count, 0, @"");

}

@end
