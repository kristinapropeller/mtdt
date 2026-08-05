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
private class pp_Jobs_Test {
    @IsTest
    static void instanceTest() {
        Assert.isNotNull(pp_Jobs.getInstance());
    }

    @IsTest
    static void scheduleTest() {
        Test.startTest();

        Id id = new pp_Job('test', pp_R.debug)
                .startNow()
                .afterSeconds(60)
                .repeatOnce()
                .schedule();
        CronTrigger ct = pp_Jobs.getInstance().getCronTriggerByName('test');
        Assert.isNotNull(ct);

        ct = pp_Jobs.getInstance().getCronTriggerById(id);
        Assert.isNotNull(ct);

        Assert.isFalse(pp_Jobs.getInstance().getCronTriggers().isEmpty());

        pp_Jobs.getInstance().unscheduleById(id);

        ct = pp_Jobs.getInstance().getCronTriggerById(id);
        Assert.isNull(ct);

        pp_Job newJob = new pp_Job('newJob', pp_R.debug)
                .startNow()
                .afterMinutes(30)
                .repeatOnce();
        pp_Jobs.getInstance().reschedule(newJob);

        pp_Jobs.getInstance().unscheduleByName('newJob');

        Test.stopTest();
    }
}