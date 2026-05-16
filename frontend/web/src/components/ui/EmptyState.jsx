const EmptyState = ({ icon = '📭', title, description, action }) => {
  return (
    <div className="flex flex-col items-center justify-center text-center py-12 px-6">
      <span className="text-6xl mb-4 opacity-70">{icon}</span>
      {title && (
        <h3 className="font-bebas text-2xl tracking-widest text-mesh-muted mb-1">
          {title}
        </h3>
      )}
      {description && (
        <p className="font-nunito text-sm text-mesh-disabled max-w-sm">
          {description}
        </p>
      )}
      {action && <div className="mt-4">{action}</div>}
    </div>
  );
};

export default EmptyState;
