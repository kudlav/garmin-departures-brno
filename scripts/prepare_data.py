import csv
import json
import os

def process_stops():
    stops = []
    # CSVs are in root, script is in scripts/
    csv_path = os.path.join(os.path.dirname(__file__), '..', 'stops.csv')
    output_path = os.path.join(os.path.dirname(__file__), '..', 'resources', 'data', 'stops_data.json')

    with open(csv_path, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            stops.append([
                int(row['stop_id']),
                row['stop_name'],
                round(float(row['stop_lat']), 5),
                round(float(row['stop_lon']), 5)
            ])

    # Sort by Latitude (index 2) for faster window searching
    stops.sort(key=lambda x: x[2])

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(stops, f, separators=(',', ':'))

    print(f"Processed {len(stops)} stops. File size: {len(json.dumps(stops))/1024:.2f} KB")

def process_routes():
    routes = {}
    csv_path = os.path.join(os.path.dirname(__file__), '..', 'routes.csv')
    output_path = os.path.join(os.path.dirname(__file__), '..', 'resources', 'data', 'line_colors.json')

    with open(csv_path, mode='r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row['route_short_name']
            color = row['route_color'] or "008033"
            text_color = row['route_text_color'] or "FFFFFF"
            if color == "008033" and text_color == "FFFFFF":
                continue
            if text_color == "FFFFFF":
                routes[name] = [int(color, 16)]
            else:
                routes[name] = [int(color, 16), int(text_color, 16)]

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(routes, f, ensure_ascii=False, separators=(',', ':'))

    print(f"Processed {len(routes)} routes. File size: {len(json.dumps(routes))/1024:.2f} KB")

if __name__ == "__main__":
    process_stops()
    process_routes()
