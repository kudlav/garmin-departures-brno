import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.System;
import Toybox.Lang;

class StopMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var stopId = item.getId() as Number;

        // Push loading view so we can still go back
        WatchUi.pushView(new LoadingDeparturesView(item.getLabel()), new BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);

        // Fetch departures
        DataService.fetchDepartures(stopId, method(:onReceive));
    }

    function onReceive(responseCode as Number, data as Dictionary?) as Void {
        if (DEBUG) { System.println("Response code: " + responseCode); }
        
        if (responseCode == 200 && data != null) {
            var postList = data.get("PostList") as Array?;
            if (postList != null && postList.size() > 0) {
                var menu = new WatchUi.Menu2({:title=>"Select Platform"});
                for (var i = 0; i < postList.size(); i++) {
                    var post = postList[i] as Dictionary;
                    menu.addItem(new WatchUi.MenuItem(post.get("Name") as String, null, post, null));
                }
                // Switch the LoadingView with the PostMenu
                WatchUi.switchToView(menu, new PostMenuDelegate(data), WatchUi.SLIDE_UP);
            } else {
                WatchUi.showToast("No departures found", null);
                // Go back from LoadingView
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            }
        } else {
            WatchUi.showToast(DataService.getFetchErrorMessage(responseCode), null);
            // Go back from LoadingView
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
