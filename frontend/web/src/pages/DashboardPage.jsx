import { useRef } from 'react';
import MapContainer from '../components/map/MapContainer';
import MapFilters from '../components/map/MapFilters';

const DashboardPage = () => {
  const mapRef = useRef(null);

  return (
    <div className="relative w-full" style={{ height: '100%' }}>
      <MapContainer mapRef={mapRef} />
      <MapFilters />
    </div>
  );
};

export default DashboardPage;
