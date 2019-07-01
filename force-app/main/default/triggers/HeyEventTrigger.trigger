trigger HeyEventTrigger on Event (before insert, before update) {

    for(Event e : Trigger.new){
        // find other events of the same 'hey event type' that may overlap.
        List<Event> conflictingEvents = [SELECT Id, StartDateTime, EndDateTime, Subject FROM event WHERE 
                Hey_Event_Type__c = :e.Hey_Event_Type__c AND Hey_Event_Type__c != null
                AND StartDateTime < :e.EndDateTime AND EndDateTime > :e.StartDateTime
                AND OwnerId = :e.OwnerId];
        
        List<String> conflictingEventsStrings = new List<String>();
        if(conflictingEvents.size() > 0){
            for(Event ce : conflictingEvents){
                conflictingEventsStrings.add(String.format('<a href="/{0}" target="_blank">{1}</a> from {2} to {3}', new String[]{ce.id, ce.Subject, ce.StartDateTime.format(), ce.EndDateTime.format()}));
            }


            e.addError('Hey app related events cannot overlap. \r\n' + String.join(conflictingEventsStrings,'\r\n')); 
            //TODO, we need to print date based on user timezone 
            //TODO, print html link based on record ID so user can have a look Seems like this cannot be done in Lightning, only in classic
        }
    }
    
}