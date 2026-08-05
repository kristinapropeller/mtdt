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
 */
@IsTest
private class pp_Moment_Test {
    @IsTest
    static void isBeforeTest() {
        pp_Moment m = new pp_Moment(2018, 1, 1);
        pp_Moment base = new pp_Moment(2019, 1, 1);
        Assert.isTrue(m.isBefore(base));
    }

    @IsTest
    static void diffTest() {
        pp_Moment m = new pp_Moment(2018, 1, 1);
        pp_Moment base = new pp_Moment(2019, 1, 1);
        Assert.areEqual(-1, m.diff(base).years());
        m = new pp_Moment(2024, 7, 1);
        base = new pp_Moment(2024, 8, 1);
        Assert.areEqual(-23, m.diff(base, true).days());
    }

    @IsTest
    static void daysInMonthTest() {
        pp_Moment m = new pp_Moment(2024, 7, 1);
        Assert.areEqual(31, m.daysInMonth());
        Assert.areEqual(23, m.workingDaysInMonth());
    }

    @IsTest
    static void toMomentTest() {
        pp_Moment m = new pp_Moment(2018, 1, 1);
        pp_Moment base = new pp_Moment(2019, 1, 1);
        Assert.areEqual('in a year', m.toMoment(base));
    }

    @IsTest
    static void fromMomentTest() {
        pp_Moment m = new pp_Moment(2018, 1, 1);
        pp_Moment base = new pp_Moment(2019, 1, 1);
        Assert.areEqual('a year ago', m.fromMoment(base));
    }

    @IsTest
    static void durationSubtractTest() {
        pp_Moment.Duration dur = pp_Moment.duration(3, 'hour');
        pp_Moment.Duration dur1 = pp_Moment.duration(1, 'hour');
        Assert.areEqual(2, dur.subtract(dur1).hours());
    }

    @IsTest
    static void durationAddTest() {
        pp_Moment.Duration dur = pp_Moment.duration(3, 'hour');
        pp_Moment.Duration dur1 = pp_Moment.duration(3, 'hour');
        Assert.areEqual(6, dur.add(dur1).hours());
    }

    @IsTest
    static void durationFieldTest() {
        pp_Moment.Duration dur = pp_Moment.duration(3, 'hour');
        Assert.areEqual(3, dur.field('hour'));
    }

    @IsTest
    static void durationHumanizeTest() {
        pp_Moment.Duration dur = pp_Moment.duration(3, 'hour');
        Assert.areEqual('in 3 hours', dur.humanize(true));

        dur = pp_Moment.duration(60000);
        Assert.areEqual('a minute', dur.humanize());
    }

    @IsTest
    static void formatTest() {
        pp_Moment m = new pp_Moment(2018, 1, 7);
        Assert.areEqual('2018/01/07', m.format('yyyy/MM/dd'));
    }

    @IsTest
    static void endOfTest() {
        pp_Moment m = new pp_Moment(2018, 1, 7)
                .endOf('year');
        Assert.areEqual(31, m.day());
        Assert.areEqual(999, m.millisecond());
    }

    @IsTest
    static void startOfTest() {
        pp_Moment m = new pp_Moment(2018, 1, 7)
                .startOf('year');
        Assert.areEqual(1, m.day());
    }

    @IsTest
    static void subtractTest() {
        pp_Moment m = new pp_Moment(2018, 2, 2, 2, 2, 2);

        Assert.areEqual(2017, m.subtract(1, 'year').year());
        Assert.areEqual(1, m.subtract(1, 'month').month());
        Assert.areEqual(1, m.subtract(1, 'day').day());
        Assert.areEqual(1, m.subtract(1, 'hour').hour());
        Assert.areEqual(1, m.subtract(1, 'minute').minute());
        Assert.areEqual(1, m.subtract(1, 'second').second());
    }

    @IsTest
    static void addTest() {
        pp_Moment m = new pp_Moment(2018, 1, 1, 1, 1, 1);

        Assert.areEqual(2019, m.add(1, 'year').year());
        Assert.areEqual(2, m.add(1, 'month').month());
        Assert.areEqual(2, m.add(1, 'day').day());
        Assert.areEqual(2, m.add(1, 'hour').hour());
        Assert.areEqual(2, m.add(1, 'minute').minute());
        Assert.areEqual(2, m.add(1, 'second').second());
    }

    @IsTest
    static void setAndSetFieldTest() {
        pp_Moment m = new pp_Moment()
                .field('year', 2018)
                .field('month', 10)
                .field('day', 10)
                .field('hour', 10)
                .field('minute', 10)
                .field('second', 10);
        Assert.areEqual(2018, m.field('year'));
        Assert.areEqual(10, m.field('month'));
        Assert.areEqual(10, m.field('day'));
        Assert.areEqual(10, m.field('hour'));
        Assert.areEqual(10, m.field('minute'));
        Assert.areEqual(10, m.field('second'));
    }

    @IsTest
    static void weeksInYear() {
        pp_Moment m = new pp_Moment().year(2018).month(1).day(3).hour(10).minute(0).second(0).millisecond(0);
        Assert.areEqual(52, m.weeksInYear());
    }

    @IsTest
    static void quarterTest() {
        pp_Moment m = new pp_Moment().year(2018).month(1).day(3).hour(10).minute(0).second(0).millisecond(0);
        m = m.quarter(2);
        m = m.quarters(2);

        Assert.areEqual(4, m.month());
    }

    @IsTest
    static void monthNameTest() {
        pp_Moment m = new pp_Moment().year(2018).month('January').day(3).hour(10).minute(0).second(0).millisecond(0);
        Assert.areEqual(1, m.month());
    }

    @IsTest
    static void weekTest() {
        pp_Moment m = new pp_Moment().year(2018).month(1).day(3).hour(10).minute(0).second(0).millisecond(0);
        Assert.areEqual(1, m.week());

        m = m.week(2);
        Assert.areEqual(10, m.day());
    }

    @IsTest
    static void dayOfYearTest() {
        pp_Moment m = new pp_Moment().year(2018).month(1).day(3).hour(10).minute(0).second(0).millisecond(0);
        Assert.areEqual(3, m.dayOfYear());

        m = m.dayOfYear(5);
        Assert.areEqual(5, m.dayOfYear());
    }

    @IsTest
    static void dayOfWeekTest() {
        pp_Moment m = new pp_Moment().year(2018).month(5).day(3).hour(10).minute(0).second(0).millisecond(0);
        Assert.areEqual(4, m.dayOfWeek());

        m = m.dayOfWeek(5);
        Assert.areEqual(5, m.dayOfWeek());
    }

    @IsTest
    static void getAndSetFieldsTest() {
        pp_Moment m = new pp_Moment().year(2018).month(5).day(1).hour(10).minute(0).second(0).millisecond(0);
        Assert.areEqual(2018, m.year());
        Assert.areEqual(5, m.month());
        Assert.areEqual(1, m.day());
        Assert.areEqual(10, m.hour());
        Assert.areEqual(0, m.minute());
        Assert.areEqual(0, m.second());
        Assert.areEqual(0, m.millisecond());

        m = new pp_Moment().years(2018).months(5).days(1).hours(10).minutes(0).seconds(0).milliseconds(0);
        Assert.areEqual(2018, m.years());
        Assert.areEqual(5, m.months());
        Assert.areEqual(1, m.days());
        Assert.areEqual(10, m.hours());
        Assert.areEqual(0, m.minutes());
        Assert.areEqual(0, m.seconds());
        Assert.areEqual(0, m.milliseconds());
    }

    @IsTest
    static void parseDayOfWeekInMonthTest() {
        Datetime dt = Datetime.newInstance(2018, 1, 1, 0, 0, 0);

        validateBySteps(dt, 'yyyy MM F E');
    }

    @IsTest
    static void parseDayInYearTest() {
        Datetime dt = Datetime.newInstance(2018, 1, 1, 0, 0, 0);

        validateBySteps(dt, 'yyyy MM D');
    }

    @IsTest
    static void parseWeekOfMonthTest() {
        Datetime dt = Datetime.newInstance(2018, 1, 1, 0, 0, 0);

        validateBySteps(dt, 'yyyy MM W E u');
    }

    @IsTest
    static void parseWeekOfYearTest() {
        Datetime dt = Datetime.newInstance(2018, 1, 1, 0, 0, 0);

        validateBySteps(dt, 'YYYY w E u');
    }

    static void validateBySteps(Datetime dt, String ptn) {
        String str;
        pp_Moment m;
        Integer step = 1;

        while (step < 1500) {
            str = dt.format(ptn);
            m = new pp_Moment(str, ptn);
            Assert.areEqual(dt.date(), m.toDate());
            dt = dt.addDays(1);

            step += 1;
        }
    }

    @IsTest
    static void parseSimpleTest() {
        pp_Moment m = new pp_Moment('2018/1/1 12:05:30', 'yyyy/MM/dd HH:mm:ss');
        Assert.areEqual(
                Datetime.newInstance(2018, 1, 1, 12, 5, 30),
                m.toDatetime()
        );
    }

    @IsTest
    static void instanceTest() {
        pp_Moment m = new pp_Moment(Datetime.newInstance(2000, 1, 1));
        Assert.areEqual(
                Datetime.newInstance(2000, 1, 1),
                m.toDatetime()
        );

        Assert.isNotNull(new pp_Moment(Datetime.now().date()));
        Assert.isNotNull(new pp_Moment(Datetime.now().time()));
        Assert.isNotNull(new pp_Moment(Datetime.now().getTime()));
        Assert.isNotNull(new pp_Moment('2018/01/01', new List<String>{
                'yyyy/MM/dd'
        }));
        Assert.isNotNull(new pp_Moment('2018/01/01', pp_Moment.FORMAT_DATE));
        Assert.isNotNull(new pp_Moment(Datetime.now().date(), Datetime.now().time()));
        Assert.isNotNull(new pp_Moment(new Map<String, Integer>{
                'year' => 2018,
                'month' => 10,
                'day' => 1
        }));
        Assert.isNotNull(new pp_Moment(new List<Integer>{
                2018, 10, 1
        }));
        Assert.isNotNull(new pp_Moment(new pp_Moment()));
    }

    @IsTest
    static void getValueTest() {
        pp_Moment m = new pp_Moment();
        Assert.isNotNull(m.toTime());

        Assert.isTrue(m.valueOf() > 0);

        Assert.areEqual(7, m.toList().size());

        Assert.areEqual(7, m.toMap().size());

        Assert.areEqual(0, m.compareTo(m));
    }
}