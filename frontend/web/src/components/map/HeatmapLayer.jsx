import { useEffect } from "react";
import { useMap } from "react-leaflet";
import L from "leaflet";
import "leaflet.heat";

const WEIGHTS = {
  SOS: 1.0,
  RESCUE: 0.9,
  MEDICAL: 0.8,
  VULNERABLE: 0.7,
  SHELTER: 0.6,
  FOOD: 0.5,
  CLOTHES: 0.3,
};

const HeatmapLayer = ({ sosList, requestList, visible }) => {
  const map = useMap();

  useEffect(() => {
    if (!visible) return;

    // Verileri birleştir ve ağırlıklandır
    const points = [
      // SOS noktaları
      ...sosList
        .filter((s) => s.lat && s.lon)
        .map((s) => [s.lat, s.lon, WEIGHTS.SOS]),

      // Talep noktaları
      ...requestList
        .filter((r) => r.lat && r.lon)
        .map((r) => [r.lat, r.lon, WEIGHTS[r.category] ?? 0.5]),
    ];

    if (points.length === 0) return;

    // Isı haritası katmanını oluştur
    const heat = L.heatLayer(points, {
      radius: 35,
      blur: 25,
      maxZoom: 17,
      max: 1.0,
      gradient: {
        0.2: "#2DC653", // yeşil - düşük
        0.5: "#FFB703", // sarı - orta
        0.8: "#FF6B35", // turuncu - yüksek
        1.0: "#E63946", // kırmızı - kritik
      },
    });

    heat.addTo(map);

    // Cleanup (Bileşen unmount olduğunda veya görünürlük kapandığında temizlik)
    return () => {
      map.removeLayer(heat);
    };
  }, [map, sosList, requestList, visible]);

  return null;
};

export default HeatmapLayer;
