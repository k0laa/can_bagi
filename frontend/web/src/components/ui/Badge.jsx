const variants = {
  danger:  'bg-mesh-danger/20 text-mesh-danger',
  warning: 'bg-mesh-warning/20 text-mesh-warning',
  success: 'bg-mesh-success/20 text-mesh-success',
  info:    'bg-mesh-info/20 text-mesh-info',
  muted:   'bg-mesh-disabled/40 text-mesh-muted',
};

const Badge = ({ children, variant = 'info', className = '' }) => {
  return (
    <span
      className={`
        font-nunito text-xs font-semibold
        px-2 py-0.5 rounded-full
        ${variants[variant]}
        ${className}
      `}
    >
      {children}
    </span>
  );
};

export default Badge;
