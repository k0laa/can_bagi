const sizes = {
  sm: 'w-4 h-4 border-2',
  md: 'w-8 h-8 border-2',
  lg: 'w-12 h-12 border-3',
};

const Loader = ({ size = 'md', fullscreen = false }) => {
  const spinner = (
    <div
      className={`
        ${sizes[size]}
        border-mesh-disabled border-t-mesh-accent
        rounded-full animate-spin
      `}
    />
  );

  if (fullscreen) {
    return (
      <div className="fixed inset-0 bg-mesh-bg/80 flex items-center justify-center z-50">
        <div className="flex flex-col items-center gap-3">
          <div className="w-12 h-12 border-2 border-mesh-disabled border-t-mesh-accent rounded-full animate-spin" />
          <span className="font-nunito text-mesh-muted text-sm">Yükleniyor...</span>
        </div>
      </div>
    );
  }

  return spinner;
};

export default Loader;
