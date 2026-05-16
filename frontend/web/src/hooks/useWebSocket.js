import { useEffect, useState } from 'react';
import wsService from '../services/wsService';
import useAuthStore from '../store/authStore';
import useMapStore from '../store/mapStore';
import useToastStore from '../store/toastStore';
import { playSound } from '../utils/soundUtils';
import { categoryLabels } from '../utils/mapIcons';
import { startDemoSimulator, stopDemoSimulator } from '../utils/demoSimulator';

export const useWebSocket = () => {
  const token = useAuthStore((s) => s.token);
  const { addSOS, addRequest, updateNode } = useMapStore();
  const addToast = useToastStore((s) => s.addToast);
  const [status, setStatus] = useState('disconnected');

  useEffect(() => {
    if (!token) return undefined;

    const onConnected = () => setStatus('connected');
    const onDisconnected = () => setStatus('disconnected');

    const onNewSos = (data) => {
      if (!data) return;
      addSOS(data);
      playSound('sos');
      addToast({
        type: 'danger',
        title: '🔴 ACİL SOS',
        message: `Node ${data.node_id} acil yardım istedi`,
      });
    };

    const onNewRequest = (data) => {
      if (!data) return;
      addRequest(data);
      playSound('request');
      const label = categoryLabels[data.category] || data.category || 'Talep';
      addToast({
        type: 'warning',
        title: '🟠 Yeni Talep',
        message: `${label} · ${data.people_count || 1} kişi`,
      });
    };

    const onNodeStatus = (data) => {
      if (!data) return;
      updateNode(data);
      if (data.status === 'inactive') {
        playSound('nodeDown');
        addToast({
          type: 'warning',
          title: '⚠️ Node Çevrimdışı',
          message: `${data.node_id} bağlantısı kesildi`,
        });
      }
    };

    wsService.on('connected', onConnected);
    wsService.on('disconnected', onDisconnected);
    wsService.on('NEW_SOS', onNewSos);
    wsService.on('NEW_REQUEST', onNewRequest);
    wsService.on('NODE_STATUS', onNodeStatus);

    const isDemoMode = token === 'dev-test-token';
    if (isDemoMode) {
      startDemoSimulator();
    } else {
      wsService.connect(token);
    }

    return () => {
      wsService.off('connected', onConnected);
      wsService.off('disconnected', onDisconnected);
      wsService.off('NEW_SOS', onNewSos);
      wsService.off('NEW_REQUEST', onNewRequest);
      wsService.off('NODE_STATUS', onNodeStatus);
      if (isDemoMode) {
        stopDemoSimulator();
      } else {
        wsService.disconnect();
      }
    };
  }, [token, addSOS, addRequest, updateNode, addToast]);

  return { status };
};

export default useWebSocket;
