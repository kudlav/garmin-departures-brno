import Toybox.Lang;
import Toybox.WatchUi;

class DeparturesDelegate extends WatchUi.BehaviorDelegate {
    private var _view as DeparturesView?;
    private var _lastY as Number? = null;

    function initialize(view as DeparturesView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onDrag(dragEvent as WatchUi.DragEvent) as Boolean {
        if (_view != null) {
            var y = dragEvent.getCoordinates()[1];
            if (dragEvent.getType() == WatchUi.DRAG_TYPE_START) {
                _lastY = y;
                return true;
            } else {
                if (_lastY != null) {
                    _view.scroll(y - _lastY);
                    _lastY = y;
                }
                if (dragEvent.getType() == WatchUi.DRAG_TYPE_STOP) {
                    _lastY = null;
                }
                return true;
            }
        }
        return false;
    }
}
