import { useEffect, useRef } from 'react';
import { MapContainer as LeafletMap, TileLayer, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

import useMapStore from '../../store/mapStore';
import SosMarker from './SosMarker';
import RequestMarker from './RequestMarker';
import AssemblyMarker from './AssemblyMarker';
import NodeMarker from './NodeMarker';

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

const MapRefSetter = ({ mapRef }) => {
  const map = useMap();
  const setMapInstance = useMapStore((s) => s.setMapInstance);
  useEffect(() => {
    if (mapRef) mapRef.current = map;
    setMapInstance(map);
  }, [map, mapRef, setMapInstance]);
  return null;
};

const MapContainer = ({ mapRef, onCreateTask }) => {
  const { sosList, requestList, nodeList, assemblyList, activeFilter } = useMapStore();

  const showSos = activeFilter === 'all' || activeFilter === 'sos';
  const showRequest = activeFilter === 'all' || activeFilter === 'request';
  const showAssembly = activeFilter === 'all' || activeFilter === 'assembly';
  const showNode = activeFilter === 'all' || activeFilter === 'node';

  return (
    <LeafletMap
      center={[39.6484, 27.8826]}
      zoom={14}
      style={{ width: '100%', height: '100%' }}
      zoomControl={false}
    >
      <MapRefSetter mapRef={mapRef} />

      <TileLayer
        url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
        maxZoom={19}
      />

      {showSos && sosList.map((sos) => (
        <SosMarker key={sos.id} data={sos} onCreateTask={onCreateTask} />
      ))}

      {showRequest && requestList.map((req) => (
        <RequestMarker key={req.id} data={req} onCreateTask={onCreateTask} />
      ))}

      {showAssembly && assemblyList.map((ap) => (
        <AssemblyMarker key={ap.id} data={ap} />
      ))}

      {showNode && nodeList.map((node) => (
        <NodeMarker key={node.node_id} data={node} />
      ))}
    </LeafletMap>
  );
};

export default MapContainer;
