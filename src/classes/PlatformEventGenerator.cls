//Event Publisher Microservice
//Bulkified, Generic
public class PlatformEventGenerator {

    //Method to fire platform Events.  Takes the Event Object Name as a string, and a map of fieldName:value pairs
    public static void createEvent(String objectName, List < Map < String, String > > fieldMapList) {

        //First, determine the SObject (Event) Type
        // Call global describe to get the map of string to token. 
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        
        //Get the token for the SObject based on the type. 
        Schema.SObjectType st = gd.get(objectName);
        
        // A list to hold our events to fire
        List < SObject > eventsToFire = new List < SObject >();

        //Loop through and instantiate event objects, filling in field values
        For (Map < String, String > fieldMap : fieldMapList) {
            SObject pEvent = st.newSObject();
            for (String fieldName: fieldMap.keySet()){
                pEvent.put(fieldName, fieldMap.get(fieldName));
            }
            eventsToFire.add(pEvent);
        }
        
        //Fire platform Events
        List<Database.SaveResult> results = EventBus.publish(eventsToFire);

        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                        err.getStatusCode() + ' - ' + err.getMessage());
                }
            }       
        }
    }


}