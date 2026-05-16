export const SkeletonCard = ({ lines = 2 }) => (
  <div className="bg-mesh-card rounded-lg p-4 border-l-4 border-mesh-disabled animate-pulse">
    <div className="h-4 bg-mesh-disabled rounded w-3/4 mb-3" />
    {Array.from({ length: lines }).map((_, i) => (
      <div
        key={i}
        className="h-3 bg-mesh-disabled rounded mb-2"
        style={{ width: `${60 + Math.random() * 30}%` }}
      />
    ))}
  </div>
);

export const SkeletonList = ({ count = 4 }) => (
  <div className="flex flex-col gap-3">
    {Array.from({ length: count }).map((_, i) => (
      <SkeletonCard key={i} />
    ))}
  </div>
);

export default SkeletonList;
