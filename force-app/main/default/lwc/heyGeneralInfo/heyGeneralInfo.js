import { LightningElement, track, wire} from 'lwc';
import  basicMethod  from '@salesforce/apex/HeyDefaultController.basicMethod';
import  callServerTest  from '@salesforce/apex/HeyDefaultController.callServerTest';

export default class HeyGeneralInfo extends LightningElement {

    @track 
    greeting = 'World';

    

    changeHandler(event) {
        this.greeting = event.target.value;
        basicMethod().then(result => {
            this.greeting += result;
        }).catch(error => {
            console.log("Something went wrong", error);
        })
        
    }

    buttonClickHandler(event){
        callServerTest().then(result => {
            console.log(result);
        })
    }

}