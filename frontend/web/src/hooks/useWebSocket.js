import { useEffect, useState } from 'react';
import wsService from '../services/wsService';
import useAuthStore from '../store/authStore';
import useMapStore from '../store/mapStore';
import useTaskStore from '../store/taskStore';
import useToastStore from '../store/toastStore';
import { playSound } from '../utils/soundUtils';
import { categoryLabels } from '../utils/mapIcons';
import { startDemoSimulator, stopDemoSimulator } from '../utils/demoSimulator';

export const useWebSocket = () => {
  const token = useAuthStore((s) => s.token);
  const { addSOS, removeSOS, addRequest, updateNode } = useMapStore();
  const upsertTask = useTaskStore((s) => s.upsertTask);
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

    const onSosResolved = (data) => {
      if (!data?.id) return;
      removeSOS(data.id);
      addToast({
        type: 'success',
        title: '✅ SOS Çözüldü',
        message: `SOS #${data.id} kapatıldı`,
      });
    };

    const onTaskAssigned = (data) => {
      if (!data) return;
      upsertTask(data);
      addToast({
        type: 'info',
        title: '📋 Görev Atandı',
        message: `${data.title || 'Görev'} → ${data.assigned_to || 'kullanıcı'}`,
      });
    };

    const onTaskUpdated = (data) => {
      if (!data) return;
      upsertTask(data);
      if (data.status === 'completed') {
        addToast({
          type: 'success',
          title: '✅ Görev Tamamlandı',
          message: data.title || `Görev #${data.id}`,
        });
      }
    };

    wsService.on('connected', onConnected);
    wsService.on('disconnected', onDisconnected);
    wsService.on('NEW_SOS', onNewSos);
    wsService.on('NEW_REQUEST', onNewRequest);
    wsService.on('NODE_STATUS', onNodeStatus);
    wsService.on('SOS_RESOLVED', onSosResolved);
    wsService.on('TASK_ASSIGNED', onTaskAssigned);
    wsService.on('TASK_UPDATED', onTaskUpdated);

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
      wsService.off('SOS_RESOLVED', onSosResolved);
      wsService.off('TASK_ASSIGNED', onTaskAssigned);
      wsService.off('TASK_UPDATED', onTaskUpdated);
      if (isDemoMode) {
        stopDemoSimulator();
      } else {
        wsService.disconnect();
      }
    };
  }, [token, addSOS, removeSOS, addRequest, updateNode, upsertTask, addToast]);

  return { status };
};

export default useWebSocket;
