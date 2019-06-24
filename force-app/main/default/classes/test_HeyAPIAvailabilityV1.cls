@isTest
public class test_HeyAPIAvailabilityV1 {
    public test_HeyAPIAvailabilityV1() {

    }

    //from https://forceadventure.wordpress.com/2013/04/11/creating-test-users/
    public static User createTestUser(String fName, String lName, Id roleId, Id profID ) {
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId,
                                UserRoleId = roleId);
        return tuser;
    }
    @isTest static void verifyOrgId(){
        System.assert(UserInfo.getOrganizationId() == '00D4E0000009OGIUA2');
    }

    @isTest static void emptyCalendar(){
        HeyAPIAvailabilityV1.HeyAPIAvailabilityV1Ret ret = HeyAPIAvailabilityV1.getAvailableSlots();
        System.assert(ret.error == null, 'empty Calendar should result in no error');
        System.assert(ret.slots != null && ret.slots.size() == 0, 'empty Calendar shoyld result in empty available slots');
    }

    @isTest static void singleUser(){
        User user = DataFactoryUser.insertStandardUser('user1');
        Event dispo = new Event();
        dispo.OwnerId=user.id;
        dispo.Subject='test disponibility event';
        dispo.durationInMinutes=120;
        dispo.ActivityDateTime = System.now();
        dispo.Hey_Event_Type__c = 'Available Demo Slots';

        insert dispo;

        HeyAPIAvailabilityV1.HeyAPIAvailabilityV1Ret ret = HeyAPIAvailabilityV1.getAvailableSlots();
        System.assert(ret.error == null, 'simple availability should not cause errors');
        System.assert(ret.slots != null && ret.slots.size() == 4, '2 hours defaults to 4 slots of 30 minutes');

        Event bookedDemo = new Event();
        bookedDemo.OwnerId=user.id;
        bookedDemo.Subject='test des booked demo';
        bookedDemo.durationInMinutes=30;
        bookedDemo.ActivityDateTime = dispo.ActivityDateTime.addHours(1);
        bookedDemo.Hey_Event_Type__c = 'Prospect Demo';

        insert bookedDemo;

        HeyAPIAvailabilityV1.HeyAPIAvailabilityV1Ret ret2 = HeyAPIAvailabilityV1.getAvailableSlots();
        System.assert(ret2.error == null, 'simple availability should not cause errors');
        System.assert(ret2.slots != null && ret2.slots.size() == 3, '2 hours defaults to 4 slots of 30 minutes minus 1 slot');


    }

}   
