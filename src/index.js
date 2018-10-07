import './main.css';
// import './CustomElmements.js'
// import '../node_modules/@polymer/polymer/polymer-element'
// import '../node_modules/@ggcity/leaflet-map/leaflet-map'
// import '../node_modules/@webcomponents/webcomponentsjs/webcomponents-loader'
import '../node_modules/@webcomponents/webcomponentsjs/webcomponents-bundle'
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import customMapElement from './customLeaflet'

// function loadScript(src) {
//   return new Promise(function(resolve, reject) {
//     const script = document.createElement('script');
//     script.src = src;
//     script.onload = resolve;
//     script.onerror = reject;
//     document.head.appendChild(script);
//   });
// }


// WebComponents.waitFor(() => {
//   // return loadScript('./customLeaflet.js');
//   customMapElement.start();
// });
customMapElement.start();

Elm.Main.init({
  node: document.getElementById('root')
});
registerServiceWorker();
