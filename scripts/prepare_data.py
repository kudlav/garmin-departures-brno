'''
Prepare offline data resources from GTFS
'''

from argparse import ArgumentParser
from csv import DictReader
from io import TextIOWrapper
from json import dump, dumps
from os import path
from urllib.request import urlretrieve
from zipfile import ZipFile
from re import compile

GTFS_URL = 'https://kordis-jmk.cz/gtfs/gtfs.zip'


def process_stops(gtfs_file: ZipFile) -> None:
    output_path = path.join(path.dirname(__file__), '..',
                            'resources', 'data', 'stop_positions.json')
    stop_id_regex = compile(r"U(\d+)N(\d+)")
    stops = []

    prefix_counts = {}
    stop_names_set = set()

    with gtfs_file.open('stops.txt', mode='r') as f:
        text = TextIOWrapper(f, encoding='utf-8-sig')
        reader = DictReader(text)
        for row in reader:
            match = stop_id_regex.match(row['stop_id'])
            if not match:
                continue
            name = row['stop_name']
            stop_names_set.add(name)
            stops.append([
                int(match[1]),
                int(match[2]),
                name,
                round(float(row['stop_lat']), 4),
                round(float(row['stop_lon']), 4)
            ])
            if ',' in name:
                prefix = name.split(',', 1)[0].strip()
                prefix_counts[prefix] = prefix_counts.get(prefix, 0) + 1

    prefixes_to_omit = {p for p, count in prefix_counts.items(
    ) if count > 10 and p not in stop_names_set}
    print(f"Prefixes ({len(prefixes_to_omit)}): {sorted(prefixes_to_omit)}")

    # Remove town prefixes from stop names, e.g. Blansko
    for s in stops:
        name = s[2]
        if ',' in name:
            prefix, suffix = name.split(',', 1)
            prefix = prefix.strip()
            if prefix in prefixes_to_omit:
                s[2] = suffix.strip()

    # Sort by Latitude (index 3) for faster window searching
    stops.sort(key=lambda x: x[3])

    with open(output_path, 'w', encoding='utf-8') as f:
        dump(stops, f, separators=(',', ':'))

    print(f"{len(stops)} stops, file size: {len(dumps(stops))/1024:.2f} KB")


def process_routes(gtfs_file: ZipFile) -> None:
    output_path = path.join(path.dirname(__file__), '..',
                            'resources', 'data', 'line_colors.json')
    routes = {}

    with gtfs_file.open('routes.txt', mode='r') as f:
        text = TextIOWrapper(f, encoding='utf-8-sig')
        reader = DictReader(text)
        for row in reader:
            name = row['route_short_name']
            color = row['route_color'] or '008033'
            text_color = row['route_text_color'] or 'FFFFFF'
            if color == '008033' and text_color == 'FFFFFF':
                continue
            if text_color == 'FFFFFF':
                routes[name] = [int(color, 16)]
            else:
                routes[name] = [int(color, 16), int(text_color, 16)]

    with open(output_path, 'w', encoding='utf-8') as f:
        dump(routes, f, ensure_ascii=False, separators=(',', ':'))

    print(f"{len(routes)} routes, file size: {len(dumps(routes))/1024:.2f} KB")


def process_gtfs(fresh: bool) -> None:
    if fresh:
        urlretrieve(GTFS_URL, 'gtfs.zip')
    with ZipFile('gtfs.zip') as gtfs_file:
        process_stops(gtfs_file)
        process_routes(gtfs_file)


if __name__ == "__main__":
    parser = ArgumentParser(
        prog='prepare_data.py',
        description='Prepare offline data resources from GTFS'
    )
    parser.add_argument('-f', '--fresh', action='store_true')
    args = parser.parse_args()
    process_gtfs(args.fresh)
