@RestResource(urlMapping='/twilioEvent/*')
global class TwilioWebHook {

    @HttpPost
    global static void postMethod() {
        //Twilio posts to this endpoint with Status changes for all messages

        RestRequest req = RestContext.request;

        // read parameters
        Map < String, String > params = new Map < String, String > ();
        params = req.params;
       
        //get main parameters
        String body = params.get('Body');
        String to = params.get('To');
        String messageSid = params.get('MessageSid');
        String fromNumber = params.get('From');

        String postType = '';
        String status = params.get('SmsStatus');
        //this param is based on the callback url we provide twilio
        if (params.containsKey('post_type')) {
            postType = params.get('post_type');
        }
        String direction = 'Inbound';

        //Process Event updates on previously send messages
        if (posttype == 'outbound_event') {

            //Check outbound event and handle here
     
        } else if (postType == 'inbound_sms') {

            //Parse the body for FirstName/Last Name
            String firstName;
            String lastName;

            if (body != null) {
                List < String > splitBody = body.split(' ', 2);

                if (splitBody.size() > 0 && String.isNotBlank(splitBody[0])) {
                    firstName = splitBody[0];
                } else  {
                    firstName = 'Unknown';
                }
                if (splitBody.size() > 1 && String.isNotBlank(splitBody[1])) {
                    lastName = splitBody[1];
                } else {
                    lastName = 'Unknown';
                }

                //Create a map of fieldName:value
                Map < String, String > fieldMap = new Map < String, String >();
                fieldMap.put('First_Name__c', firstName);
                fieldMap.put('Last_Name__c', lastName);
                fieldMap.put('Mobile__c', fromNumber);
                fieldMap.put('Twilio_Lead_Id__c', messageSid);

                //Add field map to a list
                List < Map < String, String > > fieldMapList = new List < Map < String, String > >();
                fieldMapList.add(fieldMap);

                //Pass off to the Platform Event Generator to fire the event
                PlatformEventGenerator.createEvent('Text_to_Lead__e', fieldMapList);
            }
        } 
    }
}