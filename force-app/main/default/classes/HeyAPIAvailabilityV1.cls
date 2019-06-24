@RestResource(urlMapping='/hey/api/v1/availability/*')
global without sharing class HeyAPIAvailabilityV1 {

    @HttpGet
    global static HeyAPIAvailabilityV1Ret getAvailableSlots(){
        //get some config
        HeySettings__mdt settings = [SELECT Demo_Duration__c FROM 	HeySettings__mdt LIMIT 1];
        Integer demoDuration = Integer.valueOf(settings.Demo_Duration__c);
        Boolean onlyDemosEvents = true; //TODO Should we consider other Events do count as unavailable ?


        //get all records of events with hey event type == slot where enddate > now
        List<Event> availabilitySlots = [SELECT Id, OwnerId, Owner.Name, Owner.Type, ActivityDate, ActivityDateTime, 
        StartDateTime, EndDateTime, IsAllDayEvent, DurationInMinutes, Hey_Event_Type__c FROM event WHERE Hey_Event_Type__c = 'Available Demo Slots' ORDER BY StartDateTime];

        // get all records of events with hey event type == demo where enddate > now 
        List<Event> bookedEvents = onlyDemosEvents ? 
                                        [SELECT Id, OwnerId, Owner.Name, Owner.Type, ActivityDate, ActivityDateTime, 
                                            StartDateTime, EndDateTime, IsAllDayEvent, DurationInMinutes, Hey_Event_Type__c 
                                            FROM event WHERE Hey_Event_Type__c = 'Prospect Demo'  ORDER BY StartDateTime]
                                        : 
                                        [SELECT Id, OwnerId, Owner.Name, Owner.Type, ActivityDate, ActivityDateTime, 
                                            StartDateTime, EndDateTime, IsAllDayEvent, DurationInMinutes, Hey_Event_Type__c 
                                            FROM event ORDER BY StartDateTime];

        Map<ID, List<Event>> bookedEventsByUser = new Map<ID,List<Event>>();

        for(Event event : bookedEvents){
            if(bookedEventsByUser.get(event.OwnerId) == null){
                bookedEventsByUser.put(event.OwnerId, new List<Event>());
            }
            bookedEventsByUser.get(event.OwnerId).add(event);
        }


        // split this into alloted time from custom metadata info
        HeyAPIAvailabilityV1Ret ret = new HeyAPIAvailabilityV1Ret();

        for(Event event : availabilitySlots){
            System.debug('processing event : '+ event);
            Integer nbPossibleSlots = event.DurationInMinutes / demoDuration;//integer division
            for(Integer i = 0; i < nbPossibleSlots; i++){
                System.debug('processing slot : ' + i);
                
                HeyAPIAvailabilityV1RetSlot slot = new HeyAPIAvailabilityV1RetSlot(event.StartDateTime.addMinutes( demoDuration * i) , event.StartDateTime.addMinutes(  demoDuration * (i+1)), event.OwnerId);
                
                //verify the user isn't already booked on anotehr demo at that time
                if(bookedEventsByUser.get(event.OwnerId) == null){
                    ret.slots.add(slot);
                }else{
                    for(Event e : bookedEventsByUser.get(event.OwnerId)){
                        if(slot.endtime > e.StartDateTime && slot.starttime < e.EndDateTime){ //strict inequality ensures it works fine
                            //conflicts with existing event
                            System.debug('Conclicting slot'+slot);
                        }else{
                            ret.slots.add(slot);
                        }
                    }
                }

            }

        }

        return ret;


   }

    global class HeyAPIAvailabilityV1Ret{
        public String error;
        public List<HeyAPIAvailabilityV1RetSlot> slots;

        public HeyAPIAvailabilityV1Ret(){
            this.slots = new List<HeyAPIAvailabilityV1.HeyAPIAvailabilityV1RetSlot>();
        }
    }

    global class HeyAPIAvailabilityV1RetSlot{
        Datetime starttime;
        Datetime endtime;
        ID userId;

        public HeyAPIAvailabilityV1RetSlot(Datetime starttime, Datetime endtime, ID userId){
            this.starttime = starttime;
            this.endtime = endtime;
            this.userId = userId;
        }
    }
}
