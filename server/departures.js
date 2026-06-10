export default {
  async fetch(request) {
    const { searchParams } = new URL(request.url);
    const stopid = searchParams.get("stopid");
    const key = searchParams.get("key");

    if (!stopid || !key) {
      return new Response("Missing stopid or key", { status: 400 });
    }

    const apiUrl = `https://transit.land/api/v2/rest/stops/f-u2e-idsjmk:${stopid}/departures?apikey=${key}&limit=5`;

    let data;
    try {
      const resp = await fetch(apiUrl);
      if (!resp.ok) {
        return new Response(`Upstream error: ${resp.status}`, { status: 500 });
      }
      data = await resp.json();
    } catch (err) {
      return new Response(`Upstream error: ${err.message}`, { status: 500 });
    }

    const parent = data?.stops?.[0]?.parent;

    const timeNow = new Date();
    const postList = [];

    for (const post of parent?.children ?? []) {
      const departures = [];

      for (const dep of post.departures ?? []) {
        const timeDep = new Date(dep.departure.scheduled_local);
        const diffMs = timeDep - timeNow;
        const diffMins = Math.floor(diffMs / 60_000);

        let timeMark;
        if (diffMins >= 30) {
          // Format as H:MM (no leading zero on hour, always two-digit minutes)
          timeMark = timeDep.toLocaleTimeString("cs-CZ", {
            hour: "numeric",
            minute: "2-digit",
            hour12: false,
            timeZone: "Europe/Prague",
          });
        } else if (diffMins > 0) {
          timeMark = `${diffMins} min`;
        } else {
          timeMark = "**";
        }

        departures.push({
          LineName: dep.trip.route.route_short_name,
          FinalStop: dep.trip.trip_headsign,
          TimeMark: timeMark,
        });
      }

      if (departures.length) {
        postList.push({
          PostID: post.stop_id,
          Name: post.platform_code ? `Nástupiště ${post.platform_code}` : "",
          Departures: departures,
        });
      }
    }

    const body = JSON.stringify({
      StopID: parent?.stop_id ?? null,
      PostList: postList,
    });

    return new Response(body, {
      headers: { "Content-Type": "application/json; charset=utf-8" },
    });
  },
};
