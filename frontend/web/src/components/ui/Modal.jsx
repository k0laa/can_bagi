import { useEffect } from 'react';
import Button from './Button';

const Modal = ({ isOpen, onClose, title, children, confirmText = 'Onayla', onConfirm, variant = 'primary' }) => {
  useEffect(() => {
    const handler = (e) => {
      if (e.key === 'Escape') onClose();
    };
    if (isOpen) window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4"
      onClick={onClose}
    >
      <div
        className="bg-mesh-card rounded-xl p-6 w-full max-w-md border border-mesh-disabled"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex justify-between items-center mb-4">
          <h2 className="font-bebas text-2xl text-mesh-text">{title}</h2>
          <button
            onClick={onClose}
            className="text-mesh-muted hover:text-white text-xl leading-none"
          >
            ✕
          </button>
        </div>
        <div className="font-nunito text-mesh-muted text-sm mb-6">{children}</div>
        {onConfirm && (
          <div className="flex gap-3 justify-end">
            <Button variant="ghost" onClick={onClose}>İptal</Button>
            <Button variant={variant} onClick={onConfirm}>{confirmText}</Button>
          </div>
        )}
      </div>
    </div>
  );
};

export default Modal;
