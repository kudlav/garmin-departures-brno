import Toybox.Lang;
import Toybox.WatchUi;

class DeparturesDelegate extends WatchUi.BehaviorDelegate {
    private var _view as DeparturesView?;

    function initialize(view as DeparturesView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        if (_view != null) {
            if (swipeEvent.getDirection() == WatchUi.SWIPE_UP) {
                _view.scroll(-120);
                return true;
            } else if (swipeEvent.getDirection() == WatchUi.SWIPE_DOWN) {
                _view.scroll(120);
                return true;
            }
        }
        return false;
    }
}
