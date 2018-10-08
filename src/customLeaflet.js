
import '../node_modules/leaflet/dist/leaflet.css'
import '../node_modules/leaflet/dist/leaflet.js'
import 'tilelayer-kartverket'

const start = () => {

customElements.define('customleaflet-map', class LeafletMap extends HTMLElement{
  constructor() {
    super()
    this._longitude = 51.505
    this._latitude = -0.09
    this._zoom = 13

  }
  get longitude () {
    return this._longitude;
  }
  set longitude (value) {
    if (this._longitude === value) return
    this._longitude = value;
    if (!this._map) return
    this._map.longitude = value;
    // this._map.setView([this._latitude, value], this._zoom)
  }

  get latitude () {
    return this._latitude;
  }
  set latitude (value) {
    if (this.latitude === value) return
    this._latitude = value;
    if (!this._map) return
    this._map.latitude = value;
    // this._map.setView([value, this._longitude], this._zoom)
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
 connectedCallback() {	// create the tile layer with correct attribution
    // this._map = L.map('fmap').setView([51.505, -0.09], 13);
    // this._map = L.map(this.id).setView([51.505, -0.09], 13);
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

  }

})
}
export default {start}