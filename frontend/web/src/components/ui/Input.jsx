const Input = ({
  label,
  error,
  type = 'text',
  placeholder,
  value,
  onChange,
  className = '',
  ...props
}) => {
  return (
    <div className={`flex flex-col gap-1 ${className}`}>
      {label && (
        <label className="font-nunito text-sm text-mesh-muted font-semibold">
          {label}
        </label>
      )}
      <input
        type={type}
        placeholder={placeholder}
        value={value}
        onChange={onChange}
        className={`
          w-full px-4 py-2.5 rounded-lg
          bg-mesh-bg border font-nunito text-base text-mesh-text
          placeholder:text-mesh-disabled
          outline-none transition-all
          ${error
            ? 'border-mesh-danger focus:border-mesh-danger'
            : 'border-mesh-disabled focus:border-mesh-accent'
          }
        `}
        {...props}
      />
      {error && (
        <span className="font-nunito text-xs text-mesh-danger">{error}</span>
      )}
    </div>
  );
};

export default Input;
