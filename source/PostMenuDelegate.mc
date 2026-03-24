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

        var view = new DeparturesView(_apiData, selectedPost);
        WatchUi.pushView(view, new DeparturesDelegate(view), WatchUi.SLIDE_LEFT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
