const colorClasses = {
  info:    'border-mesh-info text-mesh-info',
  success: 'border-mesh-success text-mesh-success',
  danger:  'border-mesh-danger text-mesh-danger',
  warning: 'border-mesh-warning text-mesh-warning',
  accent:  'border-mesh-accent text-mesh-accent',
};

const StatCard = ({ label, value, color = 'info', icon }) => {
  const cls = colorClasses[color] || colorClasses.info;

  return (
    <div className={`bg-mesh-card border-l-4 ${cls.split(' ')[0]} rounded-lg px-5 py-4 flex items-center gap-4`}>
      {icon && <div className="text-3xl">{icon}</div>}
      <div className="flex-1">
        <p className="font-nunito text-xs font-semibold text-mesh-muted tracking-wider uppercase">
          {label}
        </p>
        <p className={`font-bebas text-4xl tracking-wider ${cls.split(' ')[1]}`}>
          {value}
        </p>
      </div>
    </div>
  );
};

export default StatCard;
