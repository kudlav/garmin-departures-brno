import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class StopMenuLoadingView extends WatchUi.View {
    private var _stopName as String;

    function initialize(stopName as String) {
        View.initialize();
        _stopName = stopName;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 20, Graphics.FONT_SMALL, _stopName, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 + 20, Graphics.FONT_TINY, "Loading departures...", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
