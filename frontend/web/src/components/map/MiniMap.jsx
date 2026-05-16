import { useEffect } from 'react';
import { MapContainer as LeafletMap, TileLayer, useMap, useMapEvents } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

import useMapStore from '../../store/mapStore';
import AssemblyMarker from './AssemblyMarker';

const ClickHandler = ({ enabled, onPick }) => {
  useMapEvents({
    click: (e) => {
      if (enabled && onPick) onPick({ lat: e.latlng.lat, lon: e.latlng.lng });
    },
  });
  return null;
};

const FlyToHandler = ({ target }) => {
  const map = useMap();
  useEffect(() => {
    if (target) map.flyTo([target.lat, target.lon], 16);
  }, [target, map]);
  return null;
};

const MiniMap = ({ pickEnabled, onPick, flyTarget }) => {
  const assemblyList = useMapStore((s) => s.assemblyList);

  return (
    <LeafletMap
      center={[39.6484, 27.8826]}
      zoom={13}
      style={{
        width: '100%',
        height: '100%',
        cursor: pickEnabled ? 'crosshair' : '',
      }}
      zoomControl={true}
    >
      <TileLayer
        url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        attribution='&copy; OpenStreetMap &copy; CARTO'
        maxZoom={19}
      />
      <ClickHandler enabled={pickEnabled} onPick={onPick} />
      <FlyToHandler target={flyTarget} />
      {assemblyList.map((ap) => (
        <AssemblyMarker key={ap.id} data={ap} />
      ))}
    </LeafletMap>
  );
};

export default MiniMap;
