import { useEffect, useRef } from 'react';
import MapContainer from '../components/map/MapContainer';
import MapFilters from '../components/map/MapFilters';
import useMapStore from '../store/mapStore';
import { mockSOS, mockRequests, mockNodes, mockAssembly } from '../utils/mockData';

const DashboardPage = () => {
  const mapRef = useRef(null);
  const { setSosList, setRequestList, setNodeList, setAssemblyList } = useMapStore();

  useEffect(() => {
    setSosList(mockSOS);
    setRequestList(mockRequests);
    setNodeList(mockNodes);
    setAssemblyList(mockAssembly);
  }, []);

  return (
    <div className="relative w-full" style={{ height: '100%' }}>
      <MapContainer mapRef={mapRef} />
      <MapFilters />
    </div>
  );
};

export default DashboardPage;
