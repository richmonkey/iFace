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

//获取指定分钟的接近值。0 15 30 45
+(int)getApproximationMinute:(int)minute
{
    int zero  = abs(minute - 0);
    int fifth = abs(minute -15);
    int thirty = abs(minute - 30);
    int foutyfive = abs(minute- 45);
    
    int temp = zero;
    minute = 0;
    if(temp > fifth)
    {
        temp = fifth;
        minute = 15;
    }
    if (temp > thirty) {
        temp = thirty;
        minute = 30;
    }
    if (temp > foutyfive) {
        temp = foutyfive;
        minute = 45;
    }
    
    return minute;
}

+(NSString *) getDocumentDirectory {
	NSString *homeDirectory = NSHomeDirectory();
	return [homeDirectory stringByAppendingPathComponent:@"Documents"];
}

// 获取本地唯一串
+(NSString *) getLocalUniqueID {
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: 16];
    
    for (int i = 0; i<16; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
	return randomString;
}

// 从数字获取对应的周时间字符串
+(NSString *) getWeekDayString:(int)iDay {
	switch (iDay) {
		case 1:
			return @"周日";
			break;
		case 2:
			return @"周一";
			break;
		case 3:
			return @"周二";
			break;
		case 4:
			return @"周三";
			break;
		case 5:
			return @"周四";
			break;
		case 6:
			return @"周五";
			break;
		case 7:
			return @"周六";
			break;
		default:
			return nil;
	}
	return nil;
}

// 获取当前时间的字符串
+(NSString *) getCurrentTime {
	NSDate *date = [NSDate date];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	return [formatter stringFromDate:date];
}
+(NSString *) getCurrentTimeWithFormat:(NSString *)strFormat {
	NSString *format = strFormat;
	if (nil == format) {
		format =   @"yyyy-MM-dd HH:mm:SS";
	}
	
	NSDate *date = [NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	return [formatter stringFromDate:date];
}
+(NSString *) getEndTimeInTheDayWithFormat:(NSString *)strFormat {
	NSString *format = strFormat;
	if (nil == format) {
		format =   @"yyyy-MM-dd HH:mm:SS";
	}
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init] ;
	comps = [calendar components:\
			 NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	date = [calendar dateFromComponents:comps];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	return [formatter stringFromDate:date];
}
+(NSString *) getTimeString:(NSDate *)date format:(NSString *)strFormat {
	NSString *format = strFormat;
	if (nil == format) {
		format =   @"yyyy-MM-dd HH:mm:SS";
	}
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	return [formatter stringFromDate:date];
}

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

+(NSString *) getShowTimeString:(NSDate *)date format:(NSString *)strFormat {
	NSString *format = strFormat;
	if (nil == format) {
		format =   @"yyyy-MM-dd eee HH:mm:SS";
	}
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSString *strResult =  [formatter stringFromDate:date];
    
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Sun" withString:@"周日"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Mon" withString:@"周一"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Tue" withString:@"周二"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Wed" withString:@"周三"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Thu" withString:@"周四"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Fri" withString:@"周五"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Sat" withString:@"周六"];
    
	return strResult;
}

// 获取zero时间对象
+(NSDate *)getZeroDate {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:1];
	[comps setMonth:1];
	[comps setDay:1];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	return [calendar dateFromComponents:comps];
}
+(NSDate *)get1970Date {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:1970];
	[comps setMonth:1];
	[comps setDay:1];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	return [calendar dateFromComponents:comps];
}
// 获取调用当前的起始时间对象
+(NSTimeInterval)getStartDateInTheDayIntervalFromZero {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps = [calendar components:\
			 NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:00];
	[comps setMinute:00];
	[comps setSecond:00];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	// 获取零点的起始时间
	NSDate *dateLeft = [PublicFunc getZeroDate];
	// 计算并返回两者的差额
	return [dateRight timeIntervalSinceDate:dateLeft];
}
// 获取调用当前的终止时间对象
+(NSTimeInterval)getEndDateInTheDayIntervalFromZero {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init] ;
	comps = [calendar components:\
			 NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	// 获取零点的起始时间
	NSDate *dateLeft = [PublicFunc getZeroDate];
	// 计算并返回两者的差额
	return [dateRight timeIntervalSinceDate:dateLeft];
}

// 获取3天前的起始时间对象
+(NSTimeInterval)getStartDateInLast3DaysIntervalFromZero {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps = [calendar components:\
			 NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:00];
	[comps setMinute:00];
	[comps setSecond:00];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	dateRight = [dateRight dateByAddingTimeInterval:-259200];
	NSDate *dateLeft = [PublicFunc getZeroDate];
	return [dateRight timeIntervalSinceDate:dateLeft];
}
// 获取3天前的截止时间对象
+(NSTimeInterval)getEndDateInLast3DaysIntervalFromZero {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init] ;
	comps = [calendar components:\
			 NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	dateRight = [dateRight dateByAddingTimeInterval:-86400];
	NSDate *dateLeft = [PublicFunc getZeroDate];
	return [dateRight timeIntervalSinceDate:dateLeft];
}

// 获取未来3天的起始时间到零点时间的时间间隔
+(NSTimeInterval)getStartDateIn3DaysIntervalFromZero {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init] ;
	comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:00];
	[comps setMinute:00];
	[comps setSecond:00];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	dateRight = [dateRight dateByAddingTimeInterval:86400];
	NSDate *dateLeft = [PublicFunc getZeroDate];
	return [dateRight timeIntervalSinceDate:dateLeft];
}
// 获取未来3天的截止时间到零点时间的时间间隔
+(NSTimeInterval)getEndDateIn3DaysIntervalFromZero {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init] ;
	comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	dateRight = [dateRight dateByAddingTimeInterval:345600];
	NSDate *dateLeft = [PublicFunc getZeroDate];
	return [dateRight timeIntervalSinceDate:dateLeft];
}

// 获取当前时间到零点时间的时间间隔
+(NSTimeInterval)getCurrentDateIntervalFromZero {
	NSDate *date = [NSDate date];
	NSDate *dateLeft = [PublicFunc getZeroDate];
	return [date timeIntervalSinceDate:dateLeft];
}
// 获取指定时间到零点时间的时间间隔
+(NSTimeInterval) getDateIntervalFromZero:(NSDate *)date {
	if (nil == date) {
		return 0;
	}
	return [date timeIntervalSinceDate:[PublicFunc getZeroDate]];
}
// 获取调用当前的起始时间对象
+(NSTimeInterval)getStartDateInTheDayIntervalFrom1970 {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init] ;
	comps = [calendar components:\
			 NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:00];
	[comps setMinute:00];
	[comps setSecond:00];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	// 获取零点的起始时间
	NSDate *dateLeft = [PublicFunc get1970Date];
	// 计算并返回两者的差额
	return [dateRight timeIntervalSinceDate:dateLeft];
}
// 获取调用当前的终止时间对象
+(NSTimeInterval)getEndDateInTheDayIntervalFrom1970 {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps = [calendar components:\
			 NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	// 获取零点的起始时间
	NSDate *dateLeft = [PublicFunc get1970Date];
	// 计算并返回两者的差额
	return [dateRight timeIntervalSinceDate:dateLeft];
}
// 获取3天前的起始时间对象
+(NSTimeInterval)getStartDateInLast3DaysIntervalFrom1970 {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps = [calendar components:\
			 NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:00];
	[comps setMinute:00];
	[comps setSecond:00];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	dateRight = [dateRight dateByAddingTimeInterval:-259200];
	NSDate *dateLeft = [PublicFunc get1970Date];
	return [dateRight timeIntervalSinceDate:dateLeft];
}
// 获取3天前的截止时间对象
+(NSTimeInterval)getEndDateInLast3DaysIntervalFrom1970 {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps = [calendar components:\
			 NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	dateRight = [dateRight dateByAddingTimeInterval:-86400];
	NSDate *dateLeft = [PublicFunc get1970Date];
	return [dateRight timeIntervalSinceDate:dateLeft];
}

// 获取未来3天的起始时间到1970的时间间隔
+(NSTimeInterval)getStartDateIn3DaysIntervalFrom1970 {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:00];
	[comps setMinute:00];
	[comps setSecond:00];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	dateRight = [dateRight dateByAddingTimeInterval:86400];
	NSDate *dateLeft = [PublicFunc get1970Date];
	return [dateRight timeIntervalSinceDate:dateLeft];
}
// 获取未来3天的截止时间到1970的时间间隔
+(NSTimeInterval)getEndDateIn3DaysIntervalFrom1970 {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	dateRight = [dateRight dateByAddingTimeInterval:259200];
	NSDate *dateLeft = [PublicFunc get1970Date];
	return [dateRight timeIntervalSinceDate:dateLeft];
}

// 获取当前时间到1970的时间间隔
+(NSTimeInterval)getCurrentDateIntervalFrom1970 {
	NSDate *date = [NSDate date];
	NSDate *dateLeft = [PublicFunc get1970Date];
	return [date timeIntervalSinceDate:dateLeft];
}

// 获取昨天初时间到1970的时间间隔
+(NSTimeInterval)getStartYesterdayDateIntervalFrom1970 {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:00];
	[comps setMinute:00];
	[comps setSecond:00];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	dateRight = [dateRight dateByAddingTimeInterval:-86400];
	NSDate *dateLeft = [PublicFunc get1970Date];
	return [dateRight timeIntervalSinceDate:dateLeft];
}
// 获取明天末时间到1970的时间间隔
+(NSTimeInterval)getEndTomorrowDateIntervalFrom1970 {
	// 获得当前天的起始时间
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit \
						fromDate:date];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	NSDate *dateRight = [calendar dateFromComponents:comps];
	dateRight = [dateRight dateByAddingTimeInterval:86400];
	NSDate *dateLeft = [PublicFunc get1970Date];
	return [dateRight timeIntervalSinceDate:dateLeft];
}

// 获取指定时间到1970的时间间隔
+(NSTimeInterval) getDateIntervalFrom1970:(NSDate *)date {
	if (nil == date) {
		return 0;
	}
    if ([date respondsToSelector:@selector(timeIntervalSinceDate:)])
    {
        return [date timeIntervalSinceDate:[PublicFunc get1970Date]];
    }
	else {
        return 0;
    }
}

// 从指定的数据中返回NSDate对象
+(NSDate *) dateWithYear:(int)iYear month:(int)iMonth day:(int)iDay hour:(int)iHour minute:(int)iMinute second:(int)iSecond{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:iYear];
	[comps setMonth:iMonth];
	[comps setDay:iDay];
	[comps setHour:iHour];
	[comps setMinute:iMinute];
	[comps setSecond:iSecond];
	return [calendar dateFromComponents:comps];
}
+(NSDate *) dateWithYear:(int)iYear month:(int)iMonth week:(int)iWeek weekday:(int)iWeekDay hour:(int)iHour minute:(int)iMinute second:(int)iSecond {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:iYear];
	[comps setMonth:iMonth];
	[comps setWeek:iWeek];
	[comps setWeekday:iWeekDay];
	[comps setHour:iHour];
	[comps setMinute:iMinute];
	[comps setSecond:iSecond];
	return [calendar dateFromComponents:comps];
}

// 获取当前时间的年
+(int) getYearComponentOfCurrentDate {
	NSDate *date = [NSDate date];
	//date = [date dateByAddingTimeInterval:30404];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps year];
}
// 获取当前时间的月
+(int) getMonthComponentOfCurrentDate {
	NSDate *date = [NSDate date];
	//date = [date dateByAddingTimeInterval:30404];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps month];
}
// 获取当前时间的日
+(int) getDayComponentOfCurrentDate {
	NSDate *date = [NSDate date];
	//date = [date dateByAddingTimeInterval:30404];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps day];
}
// 获取当前时间的时
+(int) getHourComponentOfCurrentDate {
	NSDate *date = [NSDate date];
	//date = [date dateByAddingTimeInterval:30404];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps hour];
}
// 获取当前时间的分
+(int) getMinuteComponentOfCurrentDate {
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps minute];
}

// 获取两个时间点的月间隔数
+(int) getMonthDistanceCountBetween:(double)from To:(double)to {
	NSDate *dateFrom = [PublicFunc dateFromIntervalSince1970:from];
	NSDate *dateTo = [PublicFunc dateFromIntervalSince1970:to];
	
	int iYearFrom = [PublicFunc getYearComponentOfDate:dateFrom];
	int iYearTo = [PublicFunc getYearComponentOfDate:dateTo];
	int iMonthFrom = [PublicFunc getMonthComponentOfDate:dateFrom];
	int iMonthTo = [PublicFunc getMonthComponentOfDate:dateTo];
	
	return (12 * (iYearTo - iYearFrom) - iMonthFrom + iMonthTo);
}

// 获取指定时间的年
+(int) getYearComponentOfDate:(NSDate *)date {
	if (nil == date) {
		return 0;
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps year];
}
// 获取指定时间的月
+(int) getMonthComponentOfDate:(NSDate *)date {
	if (nil == date) {
		return 0;
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps month];
}
// 获取指定时间的天
+(int) getDayComponentOfDate:(NSDate *)date {
	if (nil == date) {
		return 0;
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps day];
}
// 获取指定时间的时
+(int) getHourComponentOfDate:(NSDate *)date {
	if (nil == date) {
		return 0;
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps hour];
}
// 获取指定时间的分
+(int) getMinuteComponentOfDate:(NSDate *)date {
	if (nil == date) {
		return 0;
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps minute];
}
// 获取指定时间的秒
+(int) getSecondeComponentOfDate:(NSDate *)date {
	if (nil == date) {
		return 0;
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | \
	NSSecondCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps second];
}

+(int) getWeekDayComponentOfDate:(NSDate *)date {
	if (nil == date) {
		return 0;
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSWeekdayCalendarUnit | NSWeekCalendarUnit;
	comps = [calendar components:unitFlags fromDate:date];
	return [comps weekday];
}


// 当前时间是否是闰年
+(bool) isLeapYearAtCurrentDate {
	int iYear = [PublicFunc getYearComponentOfCurrentDate];
	if (iYear % 100 == 0) {
		return !(iYear % 400);
	}
	else {
		return !(iYear % 4);
	}
}
+(bool) isLeapYear:(int)iYear {
	if (iYear % 100 == 0) {
		return !(iYear % 400);
	}
	else {
		return !(iYear % 4);
	}
}
+(bool) isTheDay:(NSDate*)aDay sameToThatDay:(NSDate*)thatDay{
    if (([PublicFunc getYearComponentOfDate:aDay] == [PublicFunc getYearComponentOfDate:thatDay])
        &&([PublicFunc getMonthComponentOfDate:aDay] == [PublicFunc getMonthComponentOfDate:thatDay])
        &&([PublicFunc getDayComponentOfDate:aDay] == [PublicFunc getDayComponentOfDate:thatDay])
        ) {
        return YES;
    }else{
        return  NO;
    }
}


// 从interval得到当前日期文本
+(NSString *)intervalToDateString:(NSTimeInterval)interval withToday:(bool)b {
	NSDate *zeroDate = [PublicFunc getZeroDate];
	NSDate *dstDate = [zeroDate dateByAddingTimeInterval:interval];
	NSDate *curDate = [NSDate date];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy.MM.dd"];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	NSString *strRetDate = [formatter stringFromDate:dstDate];
	NSString *strResult =   @"";
	if (b) {
		if ([PublicFunc getYearComponentOfDate:dstDate] == [PublicFunc getYearComponentOfDate:curDate] && \
			[PublicFunc getMonthComponentOfDate:dstDate] == [PublicFunc getMonthComponentOfDate:curDate] && \
			[PublicFunc getDayComponentOfDate:dstDate] == [PublicFunc getDayComponentOfDate:curDate]\
			) {
			strResult = [strResult stringByAppendingString:@"今天 "];
		}
	}
	return [strResult stringByAppendingString:strRetDate];
}
// 从interval得到当前日期文本
+(NSString *)intervalToDateString:(NSTimeInterval)interval format:(NSString *)strFormat withToday:(bool)b {
	NSString *format = strFormat;
	if (nil == format) {
		format = @"yyyy.MM.dd";
	}
	NSDate *zeroDate = [PublicFunc getZeroDate];
	NSDate *dstDate = [zeroDate dateByAddingTimeInterval:interval];
	NSDate *curDate = [NSDate date];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	NSString *strRetDate = [formatter stringFromDate:dstDate];
	NSString *strResult =     @"";
	if (b) {
		if ([PublicFunc getYearComponentOfDate:dstDate] == [PublicFunc getYearComponentOfDate:curDate] && \
			[PublicFunc getMonthComponentOfDate:dstDate] == [PublicFunc getMonthComponentOfDate:curDate] && \
			[PublicFunc getDayComponentOfDate:dstDate] == [PublicFunc getDayComponentOfDate:curDate]\
			) {
			strResult = [strResult stringByAppendingString:@"今天 "];
		}
	}
	return [strResult stringByAppendingString:strRetDate];
}
+(NSString *)intervalToDateStringFrom1970:(NSTimeInterval)interval withToday:(bool)b {
	NSDate *date1970 = [PublicFunc get1970Date];
	NSDate *dstDate = [date1970 dateByAddingTimeInterval:interval];
	NSDate *curDate = [NSDate date];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy.MM.dd HH:mm"];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	NSString *strRetDate = [formatter stringFromDate:dstDate];
	NSString *strResult =     @"";
	if (b) {
		if ([PublicFunc getYearComponentOfDate:dstDate] == [PublicFunc getYearComponentOfDate:curDate] && \
			[PublicFunc getMonthComponentOfDate:dstDate] == [PublicFunc getMonthComponentOfDate:curDate] && \
			[PublicFunc getDayComponentOfDate:dstDate] == [PublicFunc getDayComponentOfDate:curDate]\
			) {
			strResult = [strResult stringByAppendingString:@"今天 "];
		}
	}
	return [strResult stringByAppendingString:strRetDate];
}
+(NSString *)intervalToDateStringFrom1970:(NSTimeInterval)interval format:(NSString *)strFormat withToday:(bool)b {
	NSString *format = strFormat;
	if (nil == format) {
		format = @"yyyy.MM.dd";
	}
	NSDate *date1970 = [PublicFunc get1970Date];
	NSDate *dstDate = [date1970 dateByAddingTimeInterval:interval];
	NSDate *curDate = [NSDate date];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	NSString *strRetDate = [formatter stringFromDate:dstDate];
	NSString *strResult =   @"";
	if (b) {
		if ([PublicFunc getYearComponentOfDate:dstDate] == [PublicFunc getYearComponentOfDate:curDate] && \
			[PublicFunc getMonthComponentOfDate:dstDate] == [PublicFunc getMonthComponentOfDate:curDate] && \
			[PublicFunc getDayComponentOfDate:dstDate] == [PublicFunc getDayComponentOfDate:curDate]\
			) {
			strResult = [strResult stringByAppendingString:@"今天 "];
		}
	}
	return [strResult stringByAppendingString:strRetDate];
}

+(NSString *)intervalToDateShowingStringFrom1970:(NSTimeInterval)interval format:(NSString *)strFormat withToday:(bool)b {
	NSString *format = strFormat;
	if (nil == format) {
		format = @"yyyy.MM.dd eee HH:mm";
	}
	NSDate *date1970 = [PublicFunc get1970Date];
	NSDate *dstDate = [date1970 dateByAddingTimeInterval:interval];
	NSDate *curDate = [NSDate date];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	NSString *strRetDate = [formatter stringFromDate:dstDate];
	NSString *strResult =     @"";
	if (b) {
		if ([PublicFunc getYearComponentOfDate:dstDate] == [PublicFunc getYearComponentOfDate:curDate] && \
			[PublicFunc getMonthComponentOfDate:dstDate] == [PublicFunc getMonthComponentOfDate:curDate] && \
			[PublicFunc getDayComponentOfDate:dstDate] == [PublicFunc getDayComponentOfDate:curDate]\
			) {
			strResult = [strResult stringByAppendingString:@"今天 "];
		}
	}
    strResult =  [strResult stringByAppendingString:strRetDate];
    
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Sun" withString:@"周日"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Mon" withString:@"周一"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Tue" withString:@"周二"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Wed" withString:@"周三"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Thu" withString:@"周四"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Fri" withString:@"周五"];
    strResult =  [strResult stringByReplacingOccurrencesOfString: @"Sat" withString:@"周六"];
    
	return strResult;
}



// 从零点开始计时的空隔时间得到的NSDate对象
+(NSDate *)dateFromIntervalSinceZero:(NSTimeInterval)interval {
	NSDate *zeroDate = [PublicFunc getZeroDate];
	return [zeroDate dateByAddingTimeInterval:interval];
}// 从1970开始计时的空隔时间得到的NSDate对象
+(NSDate *)dateFromIntervalSince1970:(NSTimeInterval)interval {
	NSDate *date1970 = [PublicFunc get1970Date];
	return [date1970 dateByAddingTimeInterval:interval];
}

+(NSString *) stringWithWeekDayFromYear:(int)year month:(int)month day:(int)day {
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:day];
	[comps setMonth:month];
	[comps setYear:year];
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[cal setTimeZone:[NSTimeZone systemTimeZone]];
	NSDate *date = [cal dateFromComponents:comps];
	NSDateComponents *weekdayComponents =[cal components:NSWeekdayCalendarUnit fromDate:date];
	int weekday = [weekdayComponents weekday];
	
	NSString *strWeekDay = nil;
	switch (weekday) {
		case 1:
			strWeekDay =   @"周日";
			break;
		case 2:
			strWeekDay =   @"周一";
			break;
		case 3:
			strWeekDay =   @"周二";
			break;
		case 4:
			strWeekDay =   @"周三";
			break;
		case 5:
			strWeekDay =   @"周四";
			break;
		case 6:
			strWeekDay =   @"周五";
			break;
		case 7:
			strWeekDay =   @"周六";
			break;
		default:
			strWeekDay =   @"周日";
			break;
	}
	
	NSString *strMonth = nil;
	if (month / 10 != 0) {
		strMonth = [NSString stringWithFormat:@"%d", month];
	}
	else {
		strMonth = [NSString stringWithFormat:@"0%d", month];
	}
	
	NSString *strDay = nil;
	if (day / 10 != 0) {
		strDay = [NSString stringWithFormat:@"%d", day];
	}
	else {
		strDay = [NSString stringWithFormat:@"0%d", day];
	}
	
	return [NSString stringWithFormat:@"%d年%@月%@日，%@", year, strMonth, strDay, strWeekDay];
}


// 提取字符串的组成部分
+(char *) getComponentOfString:(const char *)szString splite:(const char)cSplite index:(unsigned int)nIndex {
	if (NULL == szString)
		return NULL;
	
	int istrlen = strlen(szString);
	const char *szStringEnd = szString + istrlen;
	
	int ilen = 0;
	
	// 根据传入的分割字符开始查找
	int i = 0;
	const char *szSearchHead = szString;
	const char *szSearchEnd = szString;
	while (szSearchHead < szStringEnd) {
		szSearchEnd = strchr(szSearchHead, cSplite);
		if (i < nIndex) {
			if (szSearchEnd) {
				szSearchHead = szSearchEnd + 1;
				i ++;
			}
			else {
				return NULL;
			}
		}
		else {
			if (szSearchEnd) {
				ilen = szSearchEnd - szSearchHead;
				char *szResult = (char *)malloc(ilen + 1);
				memset(szResult, 0, ilen + 1);
				memcpy(szResult, szSearchHead, ilen);
				return szResult;
			}
			else {
				ilen = strlen(szSearchHead);
				char *szResult = (char *)malloc(ilen + 1);
				memset(szResult, 0, ilen + 1);
				memcpy(szResult, szSearchHead, ilen);
				return szResult;
			}
		}
	}
	return NULL;
}
+(void) freeComponentOfString:(char *)szString {
	if (szString) {
		free(szString);
	}
}

// 从interval的数值得到对应的提醒字符串
+(NSString *) getRemindStringFromInterval:(NSTimeInterval)interval {
	NSString *strContent = nil;
	if (interval >= -0.00000001 && interval <= 0.00000001) {
		strContent =     @"";
	}
	else if (interval >= 1439.9999999 && interval <= 1440.000000001) {
		strContent =   @"1天前";
	}
	else if (interval >= 2879.9999999 && interval <= 2880.00000001) {
		strContent =   @"2天前";
	}
	else if (interval >= 119.9999999 && interval <= 120.0000001) {
		strContent =   @"2小时前";
	}
	else if (interval >= 59.9999999 && interval <= 60.0000001) {
		strContent =   @"1小时前";
	}
	else if (interval >= 29.9999999 && interval <= 30.0000001) {
		strContent =   @"30分钟前";
	}
	else if (interval >= 14.9999999 && interval <= 15.0000001) {
		strContent =   @"15分钟前";
	}
	else if (interval >= 4.9999999 && interval <= 5.0000001) {
		strContent =   @"5分钟前";
	}
	return strContent;
}
// 检测第一次提醒的文本
+(bool) checkFirstRemindStringComponent:(const char *)szRemind {
	if (!szRemind)
		return NO;
	if (!strcmp(szRemind, "") || !strcmp(szRemind, "1440") || !strcmp(szRemind, "2880")) {
		return YES;
	}
	return NO;
}
// 检测第二次提醒的文本
+(bool) checkSecondRemindStringComponent:(const char *)szRemind {
	if (!szRemind)
		return NO;
	if (!strcmp(szRemind, "") || \
		!strcmp(szRemind, "60") || \
		!strcmp(szRemind, "120") || \
		!strcmp(szRemind, "30") || \
		!strcmp(szRemind, "15") || \
		!strcmp(szRemind, "5")) {
		return YES;
	}
	return NO;
}
// 检测是否存在第一次提醒的文本
+(bool) checkFirstRemindString:(const char *)szRemind {
	if (!szRemind) {
		return NO;
	}
	if (strstr(szRemind, "1440") || strstr(szRemind, "2880")) {
		return YES;
	}
	return NO;
}
// 检测是否存在第二次提醒的文本
+(bool) checkSecondRemindString:(const char *)szRemind {
	if (!szRemind) {
		return NO;
	}
	if (strstr(szRemind, "1440") || strstr(szRemind, "2880")||strstr(szRemind, "120") || \
		strstr(szRemind, "60") || \
		strstr(szRemind, "30") || \
		strstr(szRemind, "15") || \
		(NULL == strstr(szRemind, "15") && strstr(szRemind, "5"))) {
		return YES;
	}
	return NO;
}
// 去除所有第一次提醒的数据
+(char *) eraseFirstRemindString:(const char *)szRemind {
	if (!szRemind) {
		return NULL;
	}
	int i = 0, iIndex = 0;
	int ilen = 100;
	char *szResult = (char *)malloc(ilen);
	memset(szResult, 0, ilen);
	while (YES) {
		char *szComponent = [PublicFunc getComponentOfString:szRemind splite:',' index:i];
		if (!szComponent) {
			break;
		}
		if (strcmp(szComponent, "1440") && strcmp(szComponent, "2880")) {
			if (0 != iIndex) {
				strcat(szResult, ",");
			}
			strcat(szResult, szComponent);
			iIndex ++;
		}
		[PublicFunc freeComponentOfString:szComponent];
		i ++;
	}
	return szResult;
}
// 去除所有第二次提醒的数据
+(char *) eraseSecondRemindString:(const char *)szRemind {
	if (!szRemind) {
		return NULL;
	}
    
	int i = 0, iIndex = 0;
	int ilen = 100;
	char *szResult = (char *)malloc(ilen);
	memset(szResult, 0, ilen);
	while (YES) {
		char *szComponent = [PublicFunc getComponentOfString:szRemind splite:',' index:i];
		if (!szComponent) {
			break;
		}
        //		if (strcmp(szComponent, "120") && \
        //			strcmp(szComponent, "60") && \
        //			strcmp(szComponent, "30") && \
        //			strcmp(szComponent, "15") && \
        //			strcmp(szComponent, "5")&&strcmp(szComponent, "1440") && strcmp(szComponent, "2880")) {
        if (0 != iIndex) {
            strcat(szResult, ",");
        }
        strcat(szResult, szComponent);
        iIndex ++;
		//}
		[PublicFunc freeComponentOfString:szComponent];
		i ++;
        if(i==2)
            break;
	}
	return szResult;
}

// 复制一个字符串
+(char *) copyString:(const char *)string {
	if (string) {
		int ilen = strlen(string) + 1;
		char *pResult = (char *)malloc(ilen);
		memset(pResult, 0, ilen);
		strcpy(pResult, string);
		return pResult;
	}
	else {
		return NULL;
	}
}
// 删除由publicFunc模块得到的字符串
+(void) freeString:(char *)string {
	if (string) {
		free(string);
	}
}

// 从Date字符串中解析出interval数据
+(double) getIntervalFromDateTypeString:(NSString *)strDate {
	if (nil == strDate) {
		return 0;
	}
	const char *szDate = [strDate UTF8String];
	if(szDate) {
		const char *szStart = strstr(szDate, "Date(");
		szStart += 4;
		const char *szEnd = strchr(szStart, ')');
		int ilen = szEnd - szStart - 1;
		char *szResult = (char *)malloc(ilen + 1);
		if (szResult) {
			memset(szResult, 0, ilen + 1);
			memcpy(szResult, szStart + 1, ilen);
			double lfResult = atof(szResult);
			free(szResult);
			return lfResult;
		}
	}
	return 0;
}

+ (NSString *) platformString
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = (char *)malloc(size);
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    free(answer);
    return results;
}

// 获取系统版本字符串
+ (NSString *)osVersionString {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)deviceUniqueIDString {
    /*
     return [[UIDevice currentDevice] uniqueIdentifier];
     */
    
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = (char *)malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}

+ (void)printMemory {
    struct task_basic_info info;
    
    mach_msg_type_number_t size = sizeof(info);
    
    kern_return_t kerr = task_info(mach_task_self(),
                                   
                                   TASK_BASIC_INFO,
                                   
                                   (task_info_t)&info,
                                   
                                   &size);
    
    if( kerr == KERN_SUCCESS ) {
        
        NSLog(@"Memory used: %u", info.resident_size); //in bytes
        
    } else {
        
        NSLog(@"Error: %s", mach_error_string(kerr));
        
    }
}

+ (NSString *)get32RandomKey {
    char key[33] = { 0 };
    srand(time(NULL));
    for (int i = 0; i < 32; i ++) {
        key[i] = (rand() % 26) + 65;
    }
    NSString *ret = [NSString stringWithUTF8String:key];
    return ret;
}

+ (BOOL)isJailBreakDevice {
    if (system("ls") == 0) {
        return YES;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"];
}


+ (float)getSystemVersion {
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (UIImage *)resizeImageWithCapInsets:(UIEdgeInsets)edgeinset fromImage:(UIImage *)image {
    if ([PublicFunc getSystemVersion] >= 5.0) {
        return [image resizableImageWithCapInsets:edgeinset];
    }
    else {
        return [image stretchableImageWithLeftCapWidth:edgeinset.left topCapHeight:edgeinset.top];
    }
}

@end



