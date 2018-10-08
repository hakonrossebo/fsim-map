import './main.css';
import '../node_modules/@webcomponents/webcomponentsjs/webcomponents-bundle'
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import customMapElement from './customLeaflet'
import mapPorts from './mapPorts'

customMapElement.start();

var app = Elm.Main.init({
  node: document.getElementById('root')
});
mapPorts.start(app);

registerServiceWorker();
