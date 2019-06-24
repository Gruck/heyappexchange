public class DataFactoryUser { // FROM https://www.nimbleams.com/blog/apex-testing-username-creation-best-practice/
    // This method dynamically creates a username prefix that will make ensure username uniqueness.
    public static String getUserNamePrefix(){
        return UserInfo.getOrganizationId() + System.now().millisecond();
    }
    // Other create and insert methods here…
    public static User insertStandardUser(String alias){
        // assert standardProfileId valid
        User standardUser = new User(
          Username = getUserNamePrefix() + 'standarduser@testorg.com',
          Alias = alias,
          email = 'standarduser@testorg.com',
          emailencodingkey = 'UTF-8',
          LastName = 'Testing',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
          TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert standardUser;
        return standardUser;
    }
}