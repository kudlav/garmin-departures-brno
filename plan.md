The plan for the **IDS JMK Departures** app for Garmin Vivoactive 5.

### Project Overview

* **Platform:** Garmin Connect IQ (Monkey C).
* **Target Device:** Garmin Vivoactive 5 (AMOLED, 390x390px, Touch screen).
* **Language:** English.
* **Core Function:** Find nearest 4 stops, select platform (Post), and show live departures.
* **Data Sources:** Local `stops_data.json`, Local `line_colors.json`, Remote IDS JMK API.

### Optimized Data Strategy

The `stops.csv` contains ~3,200 entries, which is too large to parse at runtime on a watch with limited memory.
To minimize the memory footprint on the watch (critical for 128KB-1MB heap limits), use the most compact representation possible.

* **`stops_data.json`**: An array of arrays, sorted by latitude.
  * **Format:** `[[id, "Name", lat, lon], ...]`
  * **Example:** `[1146, "Hlavní nádraží", 49.1916, 16.6128]`
* **`line_colors.json`**: A lookup table for route branding.
  * **Format:** `{"1": ["FF0000", "FAFAFA"], "12": ["0000FF"]}`
  * **Fallback:** If a line is missing, use background `#008033` and text `#FFFFFF`. Use the text `#FFFFFF` when is the second item omitted.

### Application Flow

1. **Splash Screen:** Display "Locating..." and wait for high-accuracy GPS coordinates.
2. **Stop Selection:**
    * Perform a window-based search in the sorted `stops_data.json` around the current latitude.
    * Calculate Euclidean distance for the filtered subset.
    * Show a `WatchUi.Menu2` with the **names** of the 4 nearest stops.
3. **API Fetch:** Call `https://mapa.idsjmk.cz/api/departures?stopid=${selected_id}`.
4. **Platform (Post) Selection:** Show a `WatchUi.Menu2` with the list of `Name` values from the API's `PostList`.
5. **Live Board:** A custom view rendering the departures for the chosen platform.

### Implementation Phases

#### Phase 1: Resource Preparation ✅

1. **Python Pre-processor:** Use `stops.csv` and `routes.csv`. Convert these files into the optimized JSON formats. You can use inspire by prepare_data.py which is a draft version. ✅
2. **Asset Integration:** Place JSONs in the Garmin project's `resources/data/` folder. Place used scripts into `/scripts/` folder. ✅

### Phase 2: Project Scaffold & Base Architecture ✅

This phase establishes the foundation of the Garmin Connect IQ project.

1. **Garmin Project Configuration:** ✅
    * Create `manifest.xml`: Define App ID (UUID), specify permissions (`Communications`, `Positioning`), and target the `vivoactive5`. ✅
    * Create `monkey.jungle`: Configure source and resource paths. ✅
2. **Folder Structure Design:** ✅
    * `source/`: Contains logic and UI controllers. ✅
    * `resources/data/`: Optimized JSON data from the Phase 1. ✅
    * `resources/strings/`: For UI text (English). ✅
    * `resources/resources.xml`: To register JSON data as loadable resources. ✅

#### Phase 3: Location & Proximity Engine

1. **GPS Integration:** Implement `Position.enableLocationEvents` with a callback that filters for quality.
2. **Nearest Search:**
    * Binary search for the index of `currentLat - 0.01`.
    * Iterate through the array until `currentLat + 0.01`.
    * Pick the 4 closest results based on `lat`/`lon` distance.

#### Phase 4: Networking & Dynamic Menus

1. **Stop Menu:** Handle the transition from the splash screen to the stop list.
2. **WebRequest:** Fetch real-time JSON data from the IDS JMK server.
3. **Post Menu:** Dynamically build a menu from the returned `PostList` array.

#### Phase 5: Custom UI (Departure Board)

1. **Visual Elements:**
    * **Line Badge:** Rounded rectangle with `LineName` using colors from `line_colors.json`.
    * **Destination:** Truncated text for the `FinalStop`.
    * **Time:** `TimeMark`.
2. **Interaction:** Support touch-scrolling and a 60-second auto-refresh timer and swipe to go back.

#### Phase 6: Error Handling & Optimization

1. **Fail-safes:** Handle "No Phone Connection", "Timeout", and "No Service" scenarios gracefully.
2. **AMOLED Polish:** Use pure black backgrounds and vibrant badge colors for maximum readability.

### Verification Steps

* **Simulated Location:** Verify proximity logic using various Brno coordinates in the CIQ Simulator.
* **Memory Profiler:** Ensure the large `stops_data.json` is handled efficiently using `WatchUi.loadResource`.
* **Visual Check:** Ensure line colors match the branding in `routes.csv`.
