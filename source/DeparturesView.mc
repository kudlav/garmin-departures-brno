import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Communications;
import Toybox.System;

class DeparturesView extends WatchUi.View {
    private var _apiData as Dictionary;
    private var _lineColors as Dictionary?;
    private var _scrollY as Number = 0;
    private var _totalHeight as Number = 0;
    private var _items as Array<Dictionary> = [];
    // private var _refreshTimer as Timer.Timer;
    // private var _stopId as String;

    function initialize(apiData as Dictionary) {
        View.initialize();
        _apiData = apiData;
        
        // _stopId = apiData.get("StopID") as String;
        // _refreshTimer = new Timer.Timer();
        
        _lineColors = WatchUi.loadResource(Rez.JsonData.line_colors) as Dictionary;
        
        prepareItems();
    }

    function prepareItems() as Void {
        _items = [];
        var postList = _apiData.get("PostList") as Array;
        var currentY = getScreenPadding(); // Padding at the top for readability
        var scrollToY = -1;

        for (var i = 0; i < postList.size(); i++) {
            var post = postList[i] as Dictionary;
            var departures = post.get("Departures") as Array;
            
            if (departures.size() == 0) {
                continue;
            }

            // Platform Header
            _items.add({
                "type" => :header,
                "label" => post.get("Name") as String,
                "y" => currentY
            });
            currentY += 45;

            for (var j = 0; j < departures.size(); j++) {
                var dep = departures[j] as Dictionary;
                _items.add({
                    "type" => :departure,
                    "line" => dep.get("LineName") as String,
                    "dest" => dep.get("FinalStop") as String,
                    "time" => dep.get("TimeMark") as String,
                    "y" => currentY
                });
                currentY += 45;
            }
        }
        _totalHeight = currentY + getScreenPadding(); // Padding at the bottom for readability

        if (scrollToY != -1) {
            _scrollY = -scrollToY + 40; // Center or top with some margin
            checkScrollBounds();
        }
    }

    function getScreenPadding() as Integer {
        System.println("System.getDeviceSettings().screenShape: " + System.getDeviceSettings().screenShape);
        switch (System.getDeviceSettings().screenShape) {
            case System.SCREEN_SHAPE_RECTANGLE:
                return 10;
            default:
                return 75;
        }
    }

    function checkScrollBounds() as Void {
        var screenHeight = System.getDeviceSettings().screenHeight;
        if (_scrollY > 0) {
            _scrollY = 0;
        }
        if (_totalHeight > screenHeight) {
            if (_scrollY < -( _totalHeight - screenHeight + 40)) {
                _scrollY = -( _totalHeight - screenHeight + 40);
            }
        } else {
            _scrollY = 0;
        }
    }

    function scroll(delta as Number) as Void {
        _scrollY += delta;
        checkScrollBounds();
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        // _refreshTimer.start(method(:onRefresh), 60000, true);
    }

    function onHide() as Void {
        // _refreshTimer.stop();
    }

    function onRefresh() as Void {
        // DataService.fetchDepartures(_stopId, method(:onReceiveRefresh));
    }

    function onReceiveRefresh(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 && data != null) {
            _apiData = data;
            prepareItems();
            WatchUi.requestUpdate();
        } else {
            WatchUi.showToast(DataService.getFetchErrorMessage(responseCode), null);
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();

        if (_items.size() == 0) {
            WatchUi.showToast("No departures found", null);
            // Back to list of stops
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        for (var i = 0; i < _items.size(); i++) {
            var item = _items[i];
            var y = item.get("y") as Number + _scrollY;

            if (y > screenHeight || y < -50) {
                continue;
            }

            if (item.get("type") == :header) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(screenWidth / 2, y, Graphics.FONT_TINY, item.get("label") as String, Graphics.TEXT_JUSTIFY_CENTER);
                dc.setPenWidth(1);
                dc.drawLine(20, y + 40, screenWidth - 20, y + 40);
            } else {
                var line = item.get("line") as String;
                var dest = item.get("dest") as String;
                var time = " " + item.get("time") as String;

                // Get colors
                var bgColor = 0x008033;
                var textColor = 0xFFFFFF;
                if (_lineColors != null && _lineColors.hasKey(line)) {
                    var entry = _lineColors.get(line) as Array;
                    bgColor = entry[0] as Number;
                    if (entry.size() > 1) {
                        textColor = entry[1] as Number;
                    }
                }

                // Draw line badge
                dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(10, y + 5, 55, 30, 5);

                dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(37, y + 5 + 14, Graphics.FONT_TINY, line, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

                // Draw destination
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(75, y + 5 + 15, Graphics.FONT_TINY, dest, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

                // Fill rightmost 10px padding with black to hide overflowing destination text
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.fillRectangle(screenWidth - 10, y, 10, 45);

                // Draw time
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
                dc.drawText(screenWidth - 10, y + 5 + 15, Graphics.FONT_TINY, time, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }
    }
}
