<?php
declare(strict_types = 1);

if (!isset($_GET["stopid"], $_GET["key"])) {
    return http_response_code(400);
}

$stopid = $_GET["stopid"];
$key = $_GET["key"];

$resp = file_get_contents("https://transit.land/api/v2/rest/stops/f-u2e-idsjmk:$stopid/departures?apikey=$key&limit=5");
if (!$resp) {
    return http_response_code(500);
}

$stops = json_decode($resp);

$postList = [];
$timeNow = new DateTime();
foreach($stops->stops[0]->parent->children as $post) {
    $departures = [];
    foreach($post->departures as $dep) {
        $timeDep = new DateTime($dep->departure->scheduled_local);
        $timeDiff = $timeNow->diff($timeDep);
        if ($timeDiff->y || $timeDiff->m || $timeDiff->d || $timeDiff->h || $timeDiff->i >= 30) {
            $timeMark = $timeDep->format("G:i");
        } elseif ($timeDiff->i > 0) {
            $timeMark = $timeDiff->i . " min";
        } else {
            $timeMark = "**";
        }
        $departures[] = [
            "LineName" => $dep->trip->route->route_short_name,
            "FinalStop" => $dep->trip->trip_headsign,
            "TimeMark" => $timeMark,
        ];
    }
    if (sizeOf($departures)) {
        $postList[] = [
            "PostID" => $post->stop_id,
            "Name" => "",
            "Departures" => $departures
        ];
    }
}

$json = json_encode([
    "StopID" => $stops->stops[0]->parent->stop_id,
    "PostList" => $postList
], JSON_UNESCAPED_UNICODE);

echo $json;
