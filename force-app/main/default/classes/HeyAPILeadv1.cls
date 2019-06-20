@RestResource(urlMapping='/hey/api/v1/lead/*')
global without sharing class HeyAPILeadv1 {//WITHOUT ! Only one useraccount will call this form Hey. We do not want sharing to apply
    public HeyAPILeadv1() {

    }

    
    @HttpGet
    global static List<Lead> getLeads(){
        return [select Id, Name, Company, Hey_Id__c from Lead];
   }
}
