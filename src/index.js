// import '../node_modules/@webcomponents/webcomponentsjs/webcomponents-bundle'
import './document-register-element'
import { Elm } from './Main.elm';
import {register, unregister} from './registerServiceWorker';
import customMapElement from './customLeaflet';
import './main.css';
import mapPorts from './mapPorts';
import './images/fsim_bg.jpg';


customMapElement.start();

var app = Elm.Main.init({
  node: document.getElementById('root')
});
mapPorts.start(app);

unregister();
