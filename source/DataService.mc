import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;

module DataService {
    function fetchDepartures(stopId as String, callback as Method(responseCode as Number, data as Dictionary?) as Void) as Void {
        if (DEBUG) { System.println("stopId: " + stopId); }
        var params = {
            "stopid" => stopId,
            "key" => API_KEY
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Communications.makeWebRequest(API_URL, params, options, callback);
    }

    function getFetchErrorMessage(responseCode as Number) as String {
        if (responseCode == Communications.BLE_CONNECTION_UNAVAILABLE) {
            return "Phone disconnected";
        } else {
            return "Error " + responseCode;
        }
    }
}
