const Card = ({ children, className = '', accent = false }) => {
  return (
    <div
      className={`
        bg-mesh-card rounded-xl p-4
        ${accent ? 'border-l-4 border-mesh-accent' : ''}
        ${className}
      `}
    >
      {children}
    </div>
  );
};

export default Card;
