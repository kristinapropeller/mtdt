/**
 * MIT License
 *
 * Copyright (c) 2018 Click to Cloud Pty Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 **/
@IsTest
private class pp_Job_Test {
    @IsTest
    static void instanceTest() {
        pp_Job j = new pp_Job('test', pp_R.debug);
        Assert.areEqual('0 0 0 * * ?', j.getCronExpression());
    }

    @IsTest
    static void secondTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).atSecond(30);
        Assert.areEqual('30 0 0 * * ?', j.getCronExpression());
    }

    @IsTest
    static void minuteTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).atMinute(30);
        Assert.areEqual('0 30 0 * * ?', j.getCronExpression());
    }

    @IsTest
    static void hourTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).atHour(10);
        Assert.areEqual('0 0 10 * * ?', j.getCronExpression());
    }

    @IsTest
    static void onDayTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).onDay(10);
        Assert.areEqual('0 0 0 10 * ?', j.getCronExpression());
    }

    @IsTest
    static void onDaysTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).onDays(new List<Integer>{
                10, 20
        });
        Assert.areEqual('0 0 0 10,20 * ?', j.getCronExpression());
    }

    @IsTest
    static void betweenDaysTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).betweenDays(5, 10);
        Assert.areEqual('0 0 0 5-10 * ?', j.getCronExpression());
    }

    @IsTest
    static void everyDayTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).everyDay();
        Assert.areEqual('0 0 0 * * ?', j.getCronExpression());
    }

    @IsTest
    static void everyDaysTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).fromDay(1).everyDays(2);
        Assert.areEqual('0 0 0 1/2 * ?', j.getCronExpression());

        j = new pp_Job('test', pp_R.debug).betweenDays(1, 15).everyDays(2);
        Assert.areEqual('0 0 0 1-15/2 * ?', j.getCronExpression());
    }

    @IsTest
    static void inMonthTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).inMonth('Janu');
        Assert.areEqual('0 0 0 * 1 ?', j.getCronExpression());
    }

    @IsTest
    static void inMonthsTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).inMonths(new List<Object>{
                1, 'Feb'
        });
        Assert.areEqual('0 0 0 * 1,2 ?', j.getCronExpression());
    }

    @IsTest
    static void betweenMonthsTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).betweenMonths(1, 3);
        Assert.areEqual('0 0 0 * 1-3 ?', j.getCronExpression());
    }

    @IsTest
    static void everyMonthTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).everyMonth();
        Assert.areEqual('0 0 0 * * ?', j.getCronExpression());
    }

    @IsTest
    static void everyMonthsTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).fromMonth('March').everyMonths(2);
        Assert.areEqual('0 0 0 * 3/2 ?', j.getCronExpression());

        j = new pp_Job('test', pp_R.debug).betweenMonths('Apr', 12).everyMonths(2);
        Assert.areEqual('0 0 0 * 4-12/2 ?', j.getCronExpression());
    }

    @IsTest
    static void onDayOfWeekTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).onDayOfWeek('Sun');
        Assert.areEqual('0 0 0 ? * 1', j.getCronExpression());
    }

    @IsTest
    static void onDaysOfWeekTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).onDaysOfWeek(new List<Object>{
                2, 3
        });
        Assert.areEqual('0 0 0 ? * 3,4', j.getCronExpression());
    }

    @IsTest
    static void betweenDaysOfWeekTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).betweenDaysOfWeek('Tue', 'Thur');
        Assert.areEqual('0 0 0 ? * 3-5', j.getCronExpression());
    }

    @IsTest
    static void everyDayOfWeekTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).everyDayOfWeek();
        Assert.areEqual('0 0 0 ? * *', j.getCronExpression());
    }

    @IsTest
    static void everyDaysOfWeekTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).fromDayOfWeek('Mon').everyDaysOfWeek(2);
        Assert.areEqual('0 0 0 ? * 2/2', j.getCronExpression());

        j = new pp_Job('test', pp_R.debug).betweenDaysOfWeek(1, 5).everyDaysOfWeek(2);
        Assert.areEqual('0 0 0 ? * 2-6/2', j.getCronExpression());
    }

    @IsTest
    static void inYearTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).inYear(2018);
        Assert.areEqual('0 0 0 * * ? 2018', j.getCronExpression());
    }

    @IsTest
    static void inYearsTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).inYears(new List<Integer>{
                2018, 2019
        });
        Assert.areEqual('0 0 0 * * ? 2018,2019', j.getCronExpression());
    }

    @IsTest
    static void betweenYearsTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).betweenYears(2018, 2020);
        Assert.areEqual('0 0 0 * * ? 2018-2020', j.getCronExpression());
    }

    @IsTest
    static void everyYearTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).everyYear();
        Assert.areEqual('0 0 0 * * ? *', j.getCronExpression());
    }

    @IsTest
    static void everyYearsTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).fromYear(2018).everyYears(2);
        Assert.areEqual('0 0 0 * * ? 2018/2', j.getCronExpression());

        j = new pp_Job('test', pp_R.debug).betweenYears(2018, 2050).everyYears(2);
        Assert.areEqual('0 0 0 * * ? 2018-2050/2', j.getCronExpression());
    }

    @IsTest
    static void afterSecondsTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).startAt(Datetime.newInstance(2018, 3, 1, 0, 0, 0)).afterSeconds(10).repeatOnce();
        Assert.areEqual('10 0 0 1 3 ? 2018', j.getCronExpression());
    }

    @IsTest
    static void afterMinutesTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).startAt(Datetime.newInstance(2018, 3, 1, 0, 0, 0)).afterMinutes(10).repeatOnce();
        Assert.areEqual('0 10 0 1 3 ? 2018', j.getCronExpression());
    }

    @IsTest
    static void afterHoursTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).startAt(Datetime.newInstance(2018, 3, 1, 0, 0, 0)).afterHours(10).repeatOnce();
        Assert.areEqual('0 0 10 1 3 ? 2018', j.getCronExpression());
    }

    @IsTest
    static void afterDaysTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).startAt(Datetime.newInstance(2018, 3, 1, 0, 0, 0)).afterDays(10).repeatOnce();
        Assert.areEqual('0 0 0 11 3 ? 2018', j.getCronExpression());
    }

    @IsTest
    static void afterMonthsTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).startAt(Datetime.newInstance(2018, 3, 1, 0, 0, 0)).afterMonths(4).repeatOnce();
        Assert.areEqual('0 0 0 1 7 ? 2018', j.getCronExpression());
    }

    @IsTest
    static void afterYearsTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).startAt(Datetime.newInstance(2018, 3, 1, 0, 0, 0)).afterYears(5).repeatOnce();
        Assert.areEqual('0 0 0 1 3 ? 2023', j.getCronExpression());
    }

    @IsTest
    static void afterTimeTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).startAt(Datetime.newInstance(2018, 3, 1, 0, 0, 0)).afterTime(1000).repeatOnce();
        Assert.areEqual('1 0 0 1 3 ? 2018', j.getCronExpression());
    }

    @IsTest
    static void onLastDayOfMonthTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).inMonth('Jan').onLastDayOfMonth();
        Assert.areEqual('0 0 0 L 1 ?', j.getCronExpression());
    }

    @IsTest
    static void onLastWeekdayOfMonthTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).inMonth('Jan').onLastWeekdayOfMonth();
        Assert.areEqual('0 0 0 LW 1 ?', j.getCronExpression());
    }

    @IsTest
    static void onNearestWeekdayTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).inMonth('Jan').onNearestWeekday(1);
        Assert.areEqual('0 0 0 1W 1 ?', j.getCronExpression());
    }

    @IsTest
    static void onFirstTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).inMonth('Jan').on1st('Sun');
        Assert.areEqual('0 0 0 ? 1 1#1', j.getCronExpression());
    }

    @IsTest
    static void onLastTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).inMonth('Jan').onLast('Sun');
        Assert.areEqual('0 0 0 ? 1 1L', j.getCronExpression());
    }

    @IsTest
    static void cronTest() {
        pp_Job j = new pp_Job('test', pp_R.debug).cron('0 0 0 1 1 ?');
        Assert.areEqual('0 0 0 1 1 ?', j.getCronExpression());
    }
}