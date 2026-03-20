import Toybox.Lang;
import Toybox.WatchUi;

class DeparturesDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // onBack() is called when the user wants to go back
    function onBack() as Boolean {
        return false;
    }

}
