# Garmin Departures Brno

Find live departures around you, within IDS JMK. Location never leaves your Garmin device.

## Features Overview

The app finds nearest stops using watches integrated GPS and shows live departures:

- Live Data: Fetches scheduled departure data from the <https://www.transit.land/>.
- Optimized UX for Garmin Watches with touch screens
- Uses local database of stops preserving your privacy and internet bandwidth.
- 🚧 Currently only scheduled departures are shown. IDS JMK does not provide reliable and valid GTFS Real-time. Discussions are underway about the possibility of using the IDS JMK API.
- 🚧 Live reload is currently disabled.

## Supported devices

- Venu® 4 41mm
- Venu® 4 45mm / D2™ Air X15
- vívoactive® 5
- vívoactive® 6

## Permissions

- Communications: App fetches departures using your smartphone connected via Bluetooth
- Positioning: To find nearest stops. Your position is never shared.

## Technical Architecture & Design

The application is built using Garmin Connect IQ (Monkey C) and addresses memory limitations inherent to wearable technology.

Folder Structure Design:

- `resources/drawables/`: App icon
- `resources/data/`: Optimized preprocessed JSON data (registered in `resources/resources.xml`)
- `resources/strings/`: Text translations (currently only English).
- `scripts/` Python data Pre-processor
- `server/` PHP server preprocessing responses from Transitland
- `source/`: Contains logic and UI controllers

### Data Resources (Memory Optimization)

Due to the limited memory of the watch device, large datasets are processed by `prepare_data.py` and stored in a highly compact, optimized format:

- `stop_positions.json`: This dataset contains the coordinates and names of all stations, sorted by latitude. This structure allows for fast, efficient binary search to find nearby stops without parsing thousands of entries
  - _Format:_ `[[stopIdPt1: int, stopIdPt2: int, stopName: str, lat: float, lon: float], ...]`
  - _Example:_ `[1146,175,"Hlavn\u00ed n\u00e1dra\u017e\u00ed",49.1915,16.6128]`
- `line_colors.json`: A lightweight lookup table used for consistent branding, mapping specific train lines to required display colors.
  - _Format:_ `{ lineName: [ backgroundColor: int, textColor?: int ], ...}`
  - _Example:_ `{"N99":[0,14797617]}`
  - _Fallback:_ If a line is missing, use background `#008033` and text `#FFFFFF`. Use the text `#FFFFFF` when is the second item omitted.
