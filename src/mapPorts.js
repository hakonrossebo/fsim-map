const start = app => {
  if (app.ports) {
      app.ports.outbound.subscribe(([tag, pos]) => {
        switch (tag) {
          case "SetPosition":
            requestAnimationFrame(() => {
              const map = document.querySelector("customleaflet-map");
              if (!map) return;
              const [lat, lon] = pos;
              map.setMarker(lat, lon);
            });
            break;
          case "FlyTo":
            requestAnimationFrame(() => {
              const map = document.querySelector("customleaflet-map");
              // const map = document.querySelector("#fmap");
              if (!map) return;
              const [lat, lon] = pos;
              const flyToPos = L.latLng(lon, lat)
              map._map.flyTo(flyToPos, 7);
            });
            break;

          default:
            break;
        }
      });

  }
};

export default { start };
