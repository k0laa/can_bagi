import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

const isTyping = (e) => {
  const tag = e.target?.tagName;
  return (
    tag === 'INPUT' ||
    tag === 'TEXTAREA' ||
    tag === 'SELECT' ||
    e.target?.isContentEditable
  );
};

export const useKeyboardShortcuts = () => {
  const navigate = useNavigate();

  useEffect(() => {
    const handler = (e) => {
      if (isTyping(e)) return;
      if (e.ctrlKey || e.metaKey || e.altKey) return;

      switch (e.key) {
        case '1': navigate('/'); break;
        case '2': navigate('/tasks'); break;
        case '3': navigate('/nodes'); break;
        case '4': navigate('/assembly'); break;
        default: return;
      }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [navigate]);
};

export default useKeyboardShortcuts;
