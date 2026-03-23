import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class PostMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _apiData as Dictionary;

    function initialize(apiData as Dictionary) {
        Menu2InputDelegate.initialize();
        _apiData = apiData;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var selectedPost = item.getId() as Dictionary;
        
        // Phase 5: Show Live Board
        // For now, just show a placeholder
        System.println("Selected platform: " + selectedPost.get("Name"));
        
        // TODO: Pass apiData and selectedPost to the Live Board View
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
