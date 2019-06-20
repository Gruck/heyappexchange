@RestResource(urlMapping='/hey/api/v1/test/*')
global without sharing class HeyAPITestv1 {//WITHOUT ! Only one useraccount will call this form Hey. We do not want sharing to apply
    public HeyAPITestv1() {

    }

    
    @HttpGet
    global static HeyAPITestv1Ret getConnectivityDetails(){
        NamedCredential nc =  [SELECT DeveloperName,Endpoint,Id,MasterLabel,PrincipalType FROM NamedCredential WHERE DeveloperName = 'HeyServerStgCredentials'];

        if(nc == null){
            //seems like appexchange is not installed
            return new HeyAPITestv1.HeyAPITestv1Ret('APPEXCHANGE_NOT_INSTALLED',null,null);
        }/*else if(nc.size > 1){
            //apiname is not unique ????
            return new HeyAPITestv1.HeyAPITestv1Ret("MULTIPLE_MATCHING_NAMEDCREDENTIALS",null,null);
        }*/else{
            //Test the namedCredential with a callout.
            try{
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:HeyServerStgCredentials/testback');
                req.setMethod('GET');
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug(res.getBody());
                if(res.getStatusCode()== 200 ){
                    return new HeyAPITestv1.HeyAPITestv1Ret(null,nc.id,res.getBody());
                }else{
                    return new HeyAPITestv1.HeyAPITestv1Ret('NAMED_CREDENTIALS_UNAUTHORIZED',nc.id,null);
                }
                
            }catch(Exception e){
                return new HeyAPITestv1.HeyAPITestv1Ret('DUNNO', nc.id, e.getMessage());
            }
           
        }
   }

   global class HeyAPITestv1Ret{
       String error;
       ID namedCredentialID;
       String validateState;

       public HeyAPITestv1Ret(String error, ID namedCredentialID, String validateState){
           this.error = error;
           this.namedCredentialID = namedCredentialID;
           this.validateState = validateState;
       }
   }
}
