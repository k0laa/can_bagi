import Loader from './Loader';

const variants = {
  primary: 'bg-mesh-accent hover:bg-orange-500 text-white',
  danger:  'bg-mesh-danger hover:bg-red-600 text-white',
  success: 'bg-mesh-success hover:bg-green-600 text-white',
  outline: 'border border-mesh-accent text-mesh-accent hover:bg-mesh-accent hover:text-white',
  ghost:   'text-mesh-muted hover:text-white hover:bg-mesh-card',
};

const sizes = {
  sm: 'px-3 py-1 text-sm',
  md: 'px-5 py-2 text-base',
  lg: 'px-8 py-3 text-lg',
};

const Button = ({
  children,
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled = false,
  className = '',
  onClick,
  type = 'button',
}) => {
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled || loading}
      className={`
        font-bebas tracking-wider rounded-lg transition-all duration-200
        flex items-center justify-center gap-2
        ${variants[variant]}
        ${sizes[size]}
        ${disabled || loading ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}
        ${className}
      `}
    >
      {loading && <Loader size="sm" />}
      {children}
    </button>
  );
};

export default Button;
