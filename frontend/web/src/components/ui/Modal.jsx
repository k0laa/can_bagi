import { useEffect } from 'react';
import Button from './Button';

const sizeClass = {
  sm: 'max-w-sm',
  md: 'max-w-md',
  lg: 'max-w-lg',
  xl: 'max-w-xl',
};

const Modal = ({ isOpen, onClose, title, children, confirmText = 'Onayla', onConfirm, variant = 'primary', size = 'md' }) => {
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
      className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-[9000] p-4"
      onClick={onClose}
    >
      <div
        className={`bg-mesh-card rounded-xl p-6 w-full ${sizeClass[size] || sizeClass.md} border border-mesh-disabled max-h-[90vh] overflow-y-auto`}
        onClick={(e) => e.stopPropagation()}
      >
        {title && (
          <div className="flex justify-between items-center mb-4">
            <h2 className="font-bebas text-2xl text-mesh-text tracking-wider">{title}</h2>
            <button
              onClick={onClose}
              className="text-mesh-muted hover:text-white text-xl leading-none"
            >
              ✕
            </button>
          </div>
        )}
        <div className="mb-4">{children}</div>
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
