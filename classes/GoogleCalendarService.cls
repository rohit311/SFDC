public class GoogleCalendarService {

    public static void fetchUpcomingEvents() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:GoogleCalendarNamed/calendars/primary/events?maxResults=5&orderBy=startTime&singleEvents=true');
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            System.debug('✅ Google Calendar Events: ' + res.getBody());
        } else {
            System.debug('❌ Error: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
    }
}
