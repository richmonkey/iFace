//
//  PublicFunc.m
//  Message
//
//  Created by daozhu on 14-7-14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "PublicFunc.h"
#import "stdlib.h"
#import "time.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#include <sys/socket.h> // Per msqr
#include <net/if.h>
#include <net/if_dl.h>

#import <mach/mach.h>


@implementation PublicFunc


+(NSString *) getConversationTimeString:(NSDate *)date{
    
    NSMutableString *outStr;
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSUIntegerMax fromDate:date];
    NSDateComponents *todayComponents = [gregorian components:NSIntegerMax fromDate:[NSDate date]];
    
    
    if (components.year == todayComponents.year && components.day == todayComponents.day && components.month == todayComponents.month) {
        
        NSString *format = @"HH:mm";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:format];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        NSString *timeStr = [formatter stringFromDate:date];
        
        if (components.hour > 11) {
            //下午
            outStr = [NSMutableString stringWithFormat:@"%@ %@",@"下午",timeStr];
        }else{
            //上午
            outStr = [NSMutableString stringWithFormat:@"%@ %@",@"上午",timeStr];
        }
        return outStr;
    }else{
        NSString *format = @"MM-dd HH:mm";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:format];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        return [formatter stringFromDate:date];
    }
}


/**
 *  获取时间字符串
 *
 *  @param seconds 秒
 *
 *  @return 字符串
 */
+(NSString*) getTimeStrFromSeconds:(UInt64)seconds{
    if (seconds >= 3600) {
        return [NSString stringWithFormat:@"%02lld:%02lld:%02lld",seconds/3600,(seconds%3600)/60,seconds%60];
    }else{
        return [NSString stringWithFormat:@"%02lld:%02lld",(seconds%3600)/60,seconds%60];
    }
}



@end



