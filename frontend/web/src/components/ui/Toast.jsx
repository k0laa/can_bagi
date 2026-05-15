import useToastStore from '../../store/toastStore';

const typeStyles = {
  success: 'border-l-4 border-mesh-success text-mesh-success',
  error:   'border-l-4 border-mesh-danger text-mesh-danger',
  warning: 'border-l-4 border-mesh-warning text-mesh-warning',
  info:    'border-l-4 border-mesh-info text-mesh-info',
  danger:  'border-l-4 border-mesh-danger text-mesh-danger',
};

const typeIcons = {
  success: '✅',
  error:   '❌',
  warning: '⚠️',
  info:    'ℹ️',
  danger:  '🔴',
};

const Toast = ({ id, message, type = 'info' }) => {
  const removeToast = useToastStore((s) => s.removeToast);

  return (
    <div
      className={`
        bg-mesh-card rounded-lg px-4 py-3 shadow-lg
        flex items-center gap-3 min-w-72 max-w-sm
        animate-slide-in
        ${typeStyles[type] || typeStyles.info}
      `}
    >
      <span className="text-lg">{typeIcons[type] || 'ℹ️'}</span>
      <span className="font-nunito text-sm text-mesh-text flex-1">{message}</span>
      <button
        onClick={() => removeToast(id)}
        className="text-mesh-muted hover:text-white ml-2 text-sm"
      >
        ✕
      </button>
    </div>
  );
};

const ToastContainer = () => {
  const toasts = useToastStore((s) => s.toasts);

  return (
    <div className="fixed top-4 right-4 z-[9999] flex flex-col gap-2">
      {toasts.map((toast) => (
        <Toast key={toast.id} {...toast} />
      ))}
    </div>
  );
};

export { Toast, ToastContainer };
export default ToastContainer;
