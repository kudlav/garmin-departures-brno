import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Math;
import Toybox.System;

class DeparturesApp extends Application.AppBase {

    private var _view as DeparturesView?;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function onPosition(info as Position.Info) as Void {
        if (info.accuracy >= Position.QUALITY_USABLE && info.position != null) {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
            var latDeg = info.position.toDegrees()[0] as Double;
            var lonDeg = info.position.toDegrees()[1] as Double;
            findNearestStops(latDeg, lonDeg);
        }
    }

    function findNearestStops(lat as Double, lon as Double) as Void {
        var stops = WatchUi.loadResource(Rez.JsonData.stops_data) as Array<Array>;

        var count = stops.size();
        var minLat = lat - 0.01;
        var maxLat = lat + 0.01;

        // Binary search for the index of currentLat - 0.01
        var low = 0;
        var high = count - 1;
        var startIndex = 0;

        while (low <= high) {
            var mid = (low + high) / 2;
            var stopLat = stops[mid][2].toDouble();
            if (stopLat < minLat) {
                low = mid + 1;
                startIndex = low;
            } else {
                high = mid - 1;
                startIndex = mid;
            }
        }

        var cosLat = Math.cos(lat * 3.14159265358979 / 180.0);
        var nearbyStops = [] as Array<Dictionary>;
        for (var i = startIndex; i < count; i++) {
            var stop = stops[i];
            var stopLat = stop[2].toDouble();
            if (stopLat > maxLat) {
                break;
            }

            var stopLon = stop[3].toDouble();
            var dLat = lat - stopLat;
            var dLon = (lon - stopLon) * cosLat;
            var distSq = dLat * dLat + dLon * dLon;

            nearbyStops.add({
                "id" => stop[0],
                "name" => stop[1],
                "distSq" => distSq
            });
        }

        // Sort by distance and pick top 4
        for (var i = 0; i < nearbyStops.size(); i++) {
            for (var j = i + 1; j < nearbyStops.size(); j++) {
                if (nearbyStops[j]["distSq"] < nearbyStops[i]["distSq"]) {
                    var temp = nearbyStops[i];
                    nearbyStops[i] = nearbyStops[j];
                    nearbyStops[j] = temp;
                }
            }
        }

        var results = [] as Array<Dictionary>;
        var limit = nearbyStops.size() > 4 ? 4 : nearbyStops.size();
        for (var i = 0; i < limit; i++) {
            results.add(nearbyStops[i]);
        }

        System.println("Found stops: " + results);
        // TODO: Transition to Stop Menu (Phase 4)
    }

    // Return the initial view of your application here
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        _view = new DeparturesView();
        return [ _view as WatchUi.Views, new DeparturesDelegate() ];
    }

}

function getApp() as DeparturesApp {
    return Application.getApp() as DeparturesApp;
}
