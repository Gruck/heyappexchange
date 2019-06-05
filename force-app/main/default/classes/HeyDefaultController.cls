public with sharing class HeyDefaultController {
    
    public HeyDefaultController() {

    }

    @AuraEnabled(cacheable=true)
    public static string basicMethod(){
        return 'Some String';  
    }


    @AuraEnabled
    public static string callServerTest(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:heyCustomerCredentials/leads');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        return res.getBody();
    }
}
