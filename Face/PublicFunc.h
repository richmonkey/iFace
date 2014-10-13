//
//  PublicFunc.h
//  Message
//
//  Created by daozhu on 14-7-14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicFunc : NSObject

//获取指定分钟的接近值。0 15 30 45
+(int)getApproximationMinute:(int)minute;

// 获取Document路径
+(NSString *) getDocumentDirectory;

// 获取本地唯一串
+(NSString *) getLocalUniqueID;

// 从数字获取对应的周时间字符串
+(NSString *) getWeekDayString:(int)iDay;

// 获取当前时间的字符串
+(NSString *) getCurrentTime;
+(NSString *) getCurrentTimeWithFormat:(NSString *)strFormat;
+(NSString *) getEndTimeInTheDayWithFormat:(NSString *)strFormat;
+(NSString *) getTimeString:(NSDate *)date format:(NSString *)strFormat;
+(NSString *) getConversationTimeString:(NSDate *)dat;
+(NSString *) getShowTimeString:(NSDate *)date format:(NSString *)strFormat;
+(NSDate *)getZeroDate;
+(NSDate *)get1970Date;

// 获取调用当前的起始时间到零点时间的时间间隔
+(NSTimeInterval)getStartDateInTheDayIntervalFromZero;
// 获取调用当前的终止时间到零点时间的时间间隔
+(NSTimeInterval)getEndDateInTheDayIntervalFromZero;
// 获取3天前的起始时间到零点时间的时间间隔
+(NSTimeInterval)getStartDateInLast3DaysIntervalFromZero;
// 获取3天前的截止时间到零点时间的时间间隔
+(NSTimeInterval)getEndDateInLast3DaysIntervalFromZero;
// 获取未来3天的起始时间到零点时间的时间间隔
+(NSTimeInterval)getStartDateIn3DaysIntervalFromZero;
// 获取未来3天的截止时间到零点时间的时间间隔
+(NSTimeInterval)getEndDateIn3DaysIntervalFromZero;
// 获取当前时间到零点时间的时间间隔
+(NSTimeInterval)getCurrentDateIntervalFromZero;
// 获取指定时间到零点时间的时间间隔
+(NSTimeInterval) getDateIntervalFromZero:(NSDate *)date;

// 获取调用当前的起始时间到1970的时间间隔
+(NSTimeInterval)getStartDateInTheDayIntervalFrom1970;
// 获取3天前的截止时间到1970的时间间隔
+(NSTimeInterval)getEndDateInTheDayIntervalFrom1970;
// 获取3天前的截止时间到1970的时间间隔
+(NSTimeInterval)getStartDateInLast3DaysIntervalFrom1970;
// 获取3天后的截止时间到1970时间的时间间隔
+(NSTimeInterval)getEndDateInLast3DaysIntervalFrom1970;
// 获取未来3天的起始时间到1970的时间间隔
+(NSTimeInterval)getStartDateIn3DaysIntervalFrom1970;
// 获取未来3天的截止时间到1970的时间间隔
+(NSTimeInterval)getEndDateIn3DaysIntervalFrom1970;
// 获取当前时间到1970的时间间隔
+(NSTimeInterval)getCurrentDateIntervalFrom1970;
// 获取昨天初时间到1970的时间间隔
+(NSTimeInterval)getStartYesterdayDateIntervalFrom1970;
// 获取明天末时间到1970的时间间隔
+(NSTimeInterval)getEndTomorrowDateIntervalFrom1970;
// 获取指定时间到1970的时间间隔
+(NSTimeInterval) getDateIntervalFrom1970:(NSDate *)date;

// 从指定日期中得到星期的信息,包括时间，格式: “2011年9月10日，星期六”
+(NSString *) stringWithWeekDayFromYear:(int)year month:(int)month day:(int)day;

// 从指定的数据中返回NSDate对象
+(NSDate *) dateWithYear:(int)iYear month:(int)iMonth day:(int)iDay hour:(int)iHour minute:(int)iMinute second:(int)iSecond;
+(NSDate *) dateWithYear:(int)iYear month:(int)iMonth week:(int)iWeek weekday:(int)iWeekDay hour:(int)iHour minute:(int)iMinute second:(int)iSecond;

// 获取当前时间的年
+(int) getYearComponentOfCurrentDate;
// 获取当前时间的月
+(int) getMonthComponentOfCurrentDate;
// 获取当前时间的日
+(int) getDayComponentOfCurrentDate;
// 获取当前时间的时
+(int) getHourComponentOfCurrentDate;
// 获取当前时间的分
+(int) getMinuteComponentOfCurrentDate;


// 获取指定时间的年
+(int) getYearComponentOfDate:(NSDate *)date;
// 获取指定时间的月
+(int) getMonthComponentOfDate:(NSDate *)date;
// 获取指定时间的天
+(int) getDayComponentOfDate:(NSDate *)date;
// 获取指定时间的时
+(int) getHourComponentOfDate:(NSDate *)date;
// 获取指定时间的分
+(int) getMinuteComponentOfDate:(NSDate *)date;
// 获取指定时间的秒
+(int) getSecondeComponentOfDate:(NSDate *)date;

// 获取周几
+(int) getWeekDayComponentOfDate:(NSDate *)date;

// 获取两个时间点的月间隔数
+(int) getMonthDistanceCountBetween:(double)from To:(double)to;

// 当前时间是否是闰年
+(bool) isLeapYearAtCurrentDate;
+(bool) isLeapYear:(int)iYear;
+(bool) isTheDay:(NSDate*)aDay sameToThatDay:(NSDate*)thatDay;

// 从interval得到当前日期文本
+(NSString *)intervalToDateString:(NSTimeInterval)interval withToday:(bool)b;
+(NSString *)intervalToDateStringFrom1970:(NSTimeInterval)interval withToday:(bool)b;
// 从interval得到当前日期文本
+(NSString *)intervalToDateString:(NSTimeInterval)interval format:(NSString *)strFormat withToday:(bool)b;
+(NSString *)intervalToDateStringFrom1970:(NSTimeInterval)interval format:(NSString *)strFormat withToday:(bool)b;
+(NSString *)intervalToDateShowingStringFrom1970:(NSTimeInterval)interval format:(NSString *)strFormat withToday:(bool)b;

// 从零点开始计时的空隔时间得到的NSDate对象
+(NSDate *)dateFromIntervalSinceZero:(NSTimeInterval)interval;
+(NSDate *)dateFromIntervalSince1970:(NSTimeInterval)interval;

// 提取字符串的组成部分
+(char *) getComponentOfString:(const char *)szString splite:(const char)cSplite index:(unsigned int)nIndex;
+(void) freeComponentOfString:(char *)szString;

// 从interval的数值得到对应的提醒字符串
+(NSString *) getRemindStringFromInterval:(NSTimeInterval)interval;
// 检测第一次提醒的文本成员
+(bool) checkFirstRemindStringComponent:(const char *)strRemind;
// 检测第二次提醒的文本成员
+(bool) checkSecondRemindStringComponent:(const char *)strRemind;
// 检测是否存在第一次提醒的文本
+(bool) checkFirstRemindString:(const char *)strRemind;
// 检测是否存在第二次提醒的文本
+(bool) checkSecondRemindString:(const char *)strRemind;
// 去除所有第一次提醒的数据
+(char *) eraseFirstRemindString:(const char *)szRemind;
// 去除所有第二次提醒的数据
+(char *) eraseSecondRemindString:(const char *)szRemind;

// 复制一个字符串
+(char *) copyString:(const char *)string;

// 删除由publicFunc模块得到的字符串
+(void) freeString:(char *)string;

// 从Date字符串中解析出interval数据
+(double) getIntervalFromDateTypeString:(NSString *)strDate;

// 获取本机机型
+ (NSString *)platformString;
// 获取系统版本字符串
+ (NSString *)osVersionString;
// 获取设备唯一标识
+ (NSString *)deviceUniqueIDString;

+ (void)printMemory;

+ (NSString *)get32RandomKey;

+ (BOOL)isJailBreakDevice;

+ (float)getSystemVersion;
+ (UIImage *)resizeImageWithCapInsets:(UIEdgeInsets)edgeinset fromImage:(UIImage *)image;

@end
