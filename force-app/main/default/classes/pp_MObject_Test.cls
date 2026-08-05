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
private class pp_MObject_Test {
    static {
        Pricebook2 pb = new Pricebook2(Name = 'test price book');
        insert pb;

        Opportunity op = new Opportunity(Name = 'test opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(30));
        op.Pricebook2Id = pb.Id;
        insert op;
    }

    @IsTest
    static void testCreate() {
        pp_MObject mo1 = pp_MObject.create(Pricebook2.SObjectType, new Map<String, Object>{
                'Name' => 'test price book'
        });
        Assert.isNotNull(mo1);

        Pricebook2 pb = [SELECT Id, (SELECT Id, Name FROM Opportunities) FROM Pricebook2 WHERE Name = 'test price book'];
        pp_MObject mo2 = pp_MObject.create(pb);
        Assert.isNotNull(mo2);

        pp_MObject mo3 = pp_MObject.create(mo2);
        Assert.isNotNull(mo3);
    }

    @IsTest
    static void testToMap() {
        Pricebook2 pb = [SELECT Id, (SELECT Id, Name FROM Opportunities) FROM Pricebook2 WHERE Name = 'test price book'];
        pp_MObject mo = pp_MObject.create(pb);
        Map<String, Object> result = mo.toMap(true);
        Assert.isNotNull(result.get('Opportunities'));
    }

    @IsTest
    static void testReference() {
        Opportunity op = [SELECT Id, Name, Pricebook2.Id, Pricebook2.Name FROM Opportunity WHERE Name = 'test opportunity'];
        pp_MObject mo = pp_MObject.create(op);
        Assert.areEqual(mo.get('Name'), 'test opportunity');
        Assert.areEqual(mo.get('Pricebook2.Name'), 'test price book');
    }

    @IsTest
    static void testUpdateReference() {
        Opportunity op = [SELECT Id, Name, Pricebook2.Id, Pricebook2.Name FROM Opportunity WHERE Name = 'test opportunity'];
        pp_MObject mo = pp_MObject.create(op);
        mo.put('Pricebook2.Name', 'New price book');
        mo.persist();

        op = [SELECT Id, Name, Pricebook2.Id, Pricebook2.Name FROM Opportunity WHERE Name = 'test opportunity'];
        mo = pp_MObject.create(op);
        Assert.areEqual(mo.get('Pricebook2.Name'), 'New price book');

        pp_MObject mo1 = pp_MObject.create('Pricebook2', new Map<String, Object>{
                'Name' => 'Mock Pricebook'
        });
        mo.put('Pricebook2', mo1);
        mo.put('Name', 'New Name');
        mo.persist();

        op = [SELECT Id, Name, Pricebook2.Id, Pricebook2.Name FROM Opportunity WHERE Name = 'New Name'];
        mo = pp_MObject.create(op);
        Assert.areEqual(mo.get('Pricebook2.Name'), 'Mock Pricebook');
    }

    @IsTest
    static void testInsertReference() {
        pp_MObject mo1 = pp_MObject.create('Pricebook2', new Map<String, Object>{
                'Name' => 'Mock Pricebook'
        });
        pp_MObject mo = pp_MObject.create(Opportunity.SObjectType, new Map<String, Object>{
                'Name' => 'Mock Opportunity',
                'StageName' => 'Prospecting',
                'CloseDate' => Date.today().addDays(30)
        });
        mo.put('Pricebook2', mo1);
        mo.persist();

        Opportunity op = [SELECT Id, Name, Pricebook2.Id, Pricebook2.Name FROM Opportunity WHERE Name = 'Mock Opportunity'];
        mo = pp_MObject.create(op);
        Assert.areEqual(mo.get('Name'), 'Mock Opportunity');
        Assert.areEqual(mo.get('Pricebook2.Name'), 'Mock Pricebook');
    }

    @IsTest
    static void testIdentity() {
        Opportunity op = [SELECT Id, Name, Pricebook2.Id, Pricebook2.Name FROM Opportunity WHERE Name = 'test opportunity'];
        pp_MObject mo1 = pp_MObject.create(op);
        pp_MObject mo2 = pp_MObject.create(op);
        Assert.areEqual(mo1.toString(), mo2.toString());
    }

    @IsTest
    static void testGet() {
        Pricebook2 pb = [SELECT Id, (SELECT Id, Name FROM Opportunities) FROM Pricebook2 WHERE Name = 'test price book'];
        pp_MObject mo = pp_MObject.create(pb);
        Assert.areEqual(mo.get('Opportunities.0.Name'), 'test opportunity');
    }

    @IsTest
    static void testPut() {
        Pricebook2 pb = [SELECT Id, (SELECT Id, Name FROM Opportunities) FROM Pricebook2 WHERE Name = 'test price book'];
        pp_MObject mo = pp_MObject.create(pb);
        mo.put('Opportunities.0.Name', 'new name');
        Assert.areEqual(mo.get('Opportunities.0.Name'), 'new name');
    }

    @IsTest
    static void testMarkDelete() {
        Pricebook2 pb = [SELECT Id, (SELECT Id, Name FROM Opportunities) FROM Pricebook2 WHERE Name = 'test price book'];
        pp_MObject mo = pp_MObject.create(pb);
        mo.markDeleted(true);

        pp_MObject child = (pp_MObject) mo.get('Opportunities.0');
        Assert.isTrue(child.isDeleted());
    }

    @IsTest
    static void testPersist() {
        pp_MObject mo = pp_MObject.create('Pricebook2', new Map<String, Object>{
                'Name' => 'Mock Pricebook'
        });
        pp_MObject mo1 = pp_MObject.create(Opportunity.SObjectType, new Map<String, Object>{
                'Name' => 'Mock Opportunity',
                'StageName' => 'Prospecting',
                'CloseDate' => Date.today().addDays(30)
        });
        mo.put('Opportunities', new List<pp_MObject>{
                mo1
        });
        mo.persist();

        Pricebook2 pb = [SELECT Id, Name, (SELECT Id, Name FROM Opportunities) FROM Pricebook2 WHERE Name = 'Mock Pricebook'];
        mo = pp_MObject.create(pb);
        Assert.isNotNull(mo);
        Assert.isNotNull(mo.get('Opportunities'));

        mo.put('Name', 'New Pricebook');
        mo.put('Opportunities.0.Name', 'New Opportunity');
        mo.persist();

        pb = [SELECT Id, Name, (SELECT Id, Name FROM Opportunities) FROM Pricebook2 WHERE Name = 'New Pricebook'];
        mo = pp_MObject.create(pb);
        Assert.isNotNull(mo);
        Assert.areEqual(mo.get('Opportunities.0.Name'), 'New Opportunity');

        mo.markDeleted(true);
        mo.persist();

        List<Pricebook2> pbs = [SELECT Id, Name, (SELECT Id, Name FROM Opportunities) FROM Pricebook2 WHERE Name = 'New Pricebook'];
        Assert.isTrue(pbs.isEmpty());
    }
}