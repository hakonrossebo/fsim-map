
import '../node_modules/leaflet/dist/leaflet.css'
import '../node_modules/leaflet/dist/leaflet.js'
import 'tilelayer-kartverket'
import 'leaflet.utm'

const start = () => {

customElements.define('customleaflet-map', class LeafletMap extends HTMLElement{
  constructor() {
    super()
    this._longitude = 51.505
    this._latitude = -0.09
    this._zoom = 13
    this._utmN = ''
    this._utmE = ''

  }
  get longitude () {
    return this._longitude;
  }
  set longitude (value) {
    if (this._longitude === value) return
    this._longitude = value;
    if (!this._map) return
    this._map.longitude = value;
  }

  get latitude () {
    return this._latitude;
  }
  set latitude (value) {
    if (this.latitude === value) return
    this._latitude = value;
    if (!this._map) return
    this._map.latitude = value;
  }
  get zoom () {
    return this._zoom;
  }
  set zoom (value) {
    if (this._zoom === value) return
    this._zoom = value;
    if (!this._map) return
    this._map.setZoom = value;
  }

  get utmN () {
    return this._utmN;
  }
  get utmE () {
    return this._utmE;
  }
  setMarker(lat, lon) {
        var popup = L.popup();
        const pos = L.latLng(lat, lon)
        popup
          .setLatLng(pos)
          .setContent("Current position " + pos.utm([33]).toString())
          .openOn(this._map);

  }
 connectedCallback() {	// create the tile layer with correct attribution
    if (this._map) return;
    this._map = new L.Map(this.id, {
      center: [this._latitude, this._longitude],
      zoom: this._zoom

    })
    this._map.setView([this._latitude, this._longitude], this._zoom)

    var osmUrl='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    var osmAttrib='Map data © <a href="https://openstreetmap.org">Kartverket</a> contributors';
    // var osm = new L.TileLayer(osmUrl, {minZoom: 8, maxZoom: 12, attribution: osmAttrib});
    // var osm = new L.TileLayer(osmUrl, {attribution: osmAttrib});
    var layer = new L.TileLayer.Kartverket('matrikkel_bakgrunn', {attribution: osmAttrib});
    this._map.addLayer(layer);

    this._map.on('move', () => {
        const c = this._map.getCenter();
        const utm = c.utm([33]);
        this._utmN = utm.y.toFixed(1).toString();
        this._utmE = utm.x.toFixed(1).toString();
        this._latitude = c.lat.toString();
        this._longitude = c.lng.toString();
        this.dispatchEvent(new CustomEvent('mapMove'))

    });
    // this._map.on('click', (e) => {
    //     const utm = e.latlng.utm([33]);
    //     this._utmN = utm.y.toString();
    //     this._utmE = utm.x.toString();
    //     this._latitude = e.latlng.lat.toString();
    //     this._longitude = e.latlng.lng.toString();
    //     this.dispatchEvent(new CustomEvent('mapClick'))

    // });


  }

})
}
export default {start}