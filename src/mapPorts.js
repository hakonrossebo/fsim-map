const start = app => {
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

      default:
        break;
    }
  });
};

export default { start };
