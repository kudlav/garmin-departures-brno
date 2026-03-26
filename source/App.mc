import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Math;
import Toybox.System;
import Toybox.Attention;

class App extends Application.AppBase {

    private var _view as LocatingView?;

    function initialize() {
        AppBase.initialize();
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function onPosition(info as Position.Info) as Void {
        if (DEBUG) { System.println("Position accuracy: " + info.accuracy); }
        
        var minAccuracy = DEBUG ? Position.QUALITY_LAST_KNOWN : Position.QUALITY_USABLE;
        
        if (info.accuracy >= minAccuracy && info.position != null) {
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
        
        // Optimized Top-4 search
        var bestStops = [] as Array<Dictionary>;
        var bestDistSq = [1.0, 1.0, 1.0, 1.0] as Array<Float>; // Initial large distances

        for (var i = startIndex; i < count; i++) {
            var stop = stops[i];
            var stopLat = stop[2].toDouble();
            if (stopLat > maxLat) {
                break;
            }

            var stopLon = stop[3].toDouble();
            var dLat = lat - stopLat;
            var dLon = (lon - stopLon) * cosLat;
            var distSq = (dLat * dLat + dLon * dLon).toFloat();

            // Insert into top 4 if closer
            if (distSq < bestDistSq[3]) {
                var newStop = {
                    "id" => stop[0],
                    "name" => stop[1]
                };
                
                // Find insertion point
                for (var j = 0; j < 4; j++) {
                    if (distSq < bestDistSq[j]) {
                        // Shift others down
                        for (var k = 3; k > j; k--) {
                            bestDistSq[k] = bestDistSq[k-1];
                        }
                        
                        if (bestStops.size() < 4) {
                            bestStops.add(newStop);
                        }
                        for (var k = bestStops.size() - 1; k > j; k--) {
                            bestStops[k] = bestStops[k-1];
                        }
                        
                        bestDistSq[j] = distSq;
                        bestStops[j] = newStop;
                        break;
                    }
                }
            }
        }

        // Free memory as early as possible
        stops = null;

        if (DEBUG) {
            System.println("Found stops: " + bestStops.size());
            for (var i = 0; i < bestStops.size(); i++) {
                System.println(" - " + bestStops[i]["name"]);
            }
        }

        if (bestStops.size() == 0) {
            // TODO Remove Locating... and replace it with this string
            WatchUi.showToast("No stops nearby", null);
            return;
        }

        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, 100)]);
        }

        var menu = new WatchUi.Menu2({:title=>"Select Stop"});
        for (var i = 0; i < bestStops.size(); i++) {
            menu.addItem(new WatchUi.MenuItem(bestStops[i]["name"], null, bestStops[i]["id"], null));
        }
        
        WatchUi.pushView(menu, new StopMenuDelegate(), WatchUi.SLIDE_UP);
    }

    // Return the initial view of your application here
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        _view = new LocatingView();
        return [ _view as WatchUi.Views, new LocatingDelegate() ];
    }

}

function getApp() as App {
    return Application.getApp() as App;
}
