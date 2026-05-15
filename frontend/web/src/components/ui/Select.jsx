const Select = ({ label, error, value, onChange, children, className = '', ...props }) => {
  return (
    <div className={`flex flex-col gap-1 ${className}`}>
      {label && (
        <label className="font-nunito text-sm text-mesh-muted font-semibold">
          {label}
        </label>
      )}
      <select
        value={value}
        onChange={onChange}
        className={`
          w-full px-4 py-2.5 rounded-lg
          bg-mesh-bg border font-nunito text-base text-mesh-text
          outline-none transition-all cursor-pointer
          ${error
            ? 'border-mesh-danger focus:border-mesh-danger'
            : 'border-mesh-disabled focus:border-mesh-accent'
          }
        `}
        {...props}
      >
        {children}
      </select>
      {error && (
        <span className="font-nunito text-xs text-mesh-danger">{error}</span>
      )}
    </div>
  );
};

export default Select;
