import useToastStore from '../../store/toastStore';

const typeStyles = {
  success: 'border-l-4 border-mesh-success text-mesh-success',
  error: 'border-l-4 border-mesh-danger text-mesh-danger',
  warning: 'border-l-4 border-mesh-warning text-mesh-warning',
  info: 'border-l-4 border-mesh-info text-mesh-info',
  danger: 'border-l-4 border-mesh-danger text-mesh-danger',
};

const typeIcons = {
  success: '✅',
  error: '❌',
  warning: '⚠️',
  info: 'ℹ️',
  danger: '🔴',
};

const Toast = ({ id, title, message, type = 'info' }) => {
  const removeToast = useToastStore((s) => s.removeToast);

  return (
    <div
      className={`
        bg-mesh-card rounded-lg px-4 py-3 shadow-lg
        flex items-start gap-3 min-w-72 max-w-sm
        animate-slide-in
        ${typeStyles[type] || typeStyles.info}
      `}
    >
      <span className="text-lg leading-none mt-0.5">{typeIcons[type] || 'ℹ️'}</span>
      <div className="flex-1 min-w-0">
        {title && (
          <p className="font-bebas tracking-wider text-sm text-mesh-text">{title}</p>
        )}
        <p className="font-nunito text-sm text-mesh-muted break-words">{message}</p>
      </div>
      <button
        onClick={() => removeToast(id)}
        className="text-mesh-muted hover:text-white text-sm leading-none"
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
