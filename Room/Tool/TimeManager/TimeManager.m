//
//  TimeManager.m
//  Room
//
//  Created by zjq on 15/12/10.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "TimeManager.h"

@implementation TimeManager

static TimeManager *timeManger = nil;

+(TimeManager*)shead
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeManger = [[TimeManager alloc] init];
    });
    return timeManger;
}

//智能时间处理 传入时间戳
-(NSString *)friendTimeWithTimesTamp:(long)timestamp
{
    NSString *time;
    if (timestamp<10) {
        return @"";
    }
    long bb=  timestamp/1000;
    
    NSCalendar* calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateFormatter* dateFormatter = [self dateFormatter];
//    double dd = [time doubleValue];
    NSDate* createdAt = [NSDate dateWithTimeIntervalSince1970:bb];
    NSDateComponents *nowComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *createdAtComponents = [calendar components:unitFlags fromDate:createdAt];
    if([nowComponents year] == [createdAtComponents year] &&
       [nowComponents month] == [createdAtComponents month] &&
       [nowComponents day] == [createdAtComponents day])
    {//今天
        
        int time_long = [createdAt timeIntervalSinceNow];
        
        if (time_long <= 0 && time_long >-60*60) {//一小时之内
            int min = -time_long/60;
            if (min == 0) {
                min = 1;
            }
            //            time = [[NSString alloc]initWithFormat:loadMuLanguage(@"%d分钟前",@""),min];
            if (min <= 1) {
                time = [NSString stringWithFormat:@" %d秒前",abs(time_long)];
            } else {
                time = [NSString stringWithFormat:@" %d分钟前",min];
            }
        }else if (time_long > 0) {
            time = [NSString stringWithFormat:@" %d分钟前",1];
            
        } else {
            [dateFormatter setDateFormat:@"'今天 'HH:mm"];
            
            time = [dateFormatter stringFromDate:createdAt];
        }
    }else if([self isDateThisWeek:createdAt]){
        NSLog(@"在本周，如果昨天就不按照周几来");
        NSDateComponents *_comps = [[NSDateComponents alloc] init];
        [_comps setDay:[createdAtComponents day]];
        [_comps setMonth:[createdAtComponents month]];
        [_comps setYear:[createdAtComponents year]];
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *_date = [gregorian dateFromComponents:_comps];
        NSDateComponents *weekdayComponents =
        [gregorian components:NSWeekdayCalendarUnit fromDate:_date];
        int _weekday = (int)[weekdayComponents weekday];
        if ([nowComponents day] - [nowComponents day] == 1) {
            // 昨天
            [dateFormatter setDateFormat:@"'昨天 'HH:mm"];
            
            time = [dateFormatter stringFromDate:createdAt];
        }else if ([nowComponents day] - [nowComponents day] == 2){
            // 前天
            [dateFormatter setDateFormat:@"'前天 'HH:mm"];
            
            time = [dateFormatter stringFromDate:createdAt];
        }else{
            switch (_weekday) {
                case 1:
                {
                    [dateFormatter setDateFormat:@"'星期二 'HH:mm"];
                    
                    time = [dateFormatter stringFromDate:createdAt];
                }
                    break;
                case 2:
                {
                    [dateFormatter setDateFormat:@"'星期三 'HH:mm"];
                    
                    time = [dateFormatter stringFromDate:createdAt];
                }
                    break;
                case 3:
                {
                    [dateFormatter setDateFormat:@"'星期四 'HH:mm"];
                    
                    time = [dateFormatter stringFromDate:createdAt];
                }
                    break;
                case 4:
                {
                    [dateFormatter setDateFormat:@"'星期五 'HH:mm"];
                    
                    time = [dateFormatter stringFromDate:createdAt];
                }
                    break;
                case 5:
                {
                    [dateFormatter setDateFormat:@"'星期六 'HH:mm"];
                    
                    time = [dateFormatter stringFromDate:createdAt];
                }
                    break;
                case 6:
                {
                    [dateFormatter setDateFormat:@"'星期日 'HH:mm"];
                    
                    time = [dateFormatter stringFromDate:createdAt];
                }
                    break;
                case 7:
                {
                    [dateFormatter setDateFormat:@"'星期一 'HH:mm"];
                    
                    time = [dateFormatter stringFromDate:createdAt];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    else if ([nowComponents year] == [createdAtComponents year]) {
        // 设置区域
        NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [dateFormatter setLocale:cnLocale];
        [dateFormatter setDateFormat:@"YY/MM/dd' 'HH:mm"];
        time = [dateFormatter stringFromDate:createdAt];
    } else {//去年
        NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [dateFormatter setLocale:cnLocale];
        [dateFormatter setDateFormat:@"YY-MM-dd' 'HH:mm"];
        time = [dateFormatter stringFromDate:createdAt];
    }
    
    return time;
}
// 得到时间戳
- (long)timeTransformationTimestamp
{
    NSDateFormatter *formatter = [self dateFormatter];
    NSString* stringData = [formatter stringFromDate:[NSDate date]];
    NSDate* date = [formatter dateFromString:stringData];
    return (long)[date timeIntervalSince1970]*1000;
}

-(NSDateFormatter *)dateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    //例如你在国内发布信息,用户在国外的另一个时区,你想让用户看到正确的发布时间就得注意时区设置,时间的换算.
    //例如你发布的时间为2010-01-26 17:40:50,那么在英国爱尔兰那边用户看到的时间应该是多少呢?
    //他们与我们有7个小时的时差,所以他们那还没到这个时间呢...那就是把未来的事做了
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    return formatter;
}

//判断date_是否在当前星期
- (BOOL)isDateThisWeek:(NSDate *)date_
{
    NSDate *start;
    NSTimeInterval extends;
    NSCalendar *cal=[NSCalendar autoupdatingCurrentCalendar];
    NSDate *today=[NSDate date];
    // 用于返回日期date(参数)所在的那个日历单元unit(参数)的开始时间(sDate)。其中参数unit指定了日历单元，参数sDate用于返回日历单元的第一天，参数unitSecs用于返回日历单元的长度(以秒为单位)，参数date指定了一个特定的日期。
    BOOL success= [cal rangeOfUnit:NSWeekCalendarUnit startDate:&start interval:&extends forDate:today];
    if(!success)return NO;
    NSTimeInterval dateInSecs = [date_ timeIntervalSinceReferenceDate];
    NSTimeInterval dayStartInSecs= [start timeIntervalSinceReferenceDate];
    if(dateInSecs > dayStartInSecs && dateInSecs < (dayStartInSecs+extends))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
