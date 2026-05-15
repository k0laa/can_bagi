import { NavLink } from 'react-router-dom';

const navItems = [
  { to: '/', icon: '🗺️', label: 'Harita' },
  { to: '/tasks', icon: '✅', label: 'Görevler' },
  { to: '/nodes', icon: '📡', label: 'Node Durumu' },
  { to: '/assembly', icon: '📍', label: 'Toplanma Noktaları' },
];

const SidebarNav = () => {
  return (
    <div className="w-56 shrink-0 h-full bg-mesh-card border-r border-mesh-disabled flex flex-col">
      <div className="p-4 border-b border-mesh-disabled">
        <span className="font-bebas text-2xl text-mesh-accent tracking-wider">
          MeshAid
        </span>
        <p className="font-nunito text-xs text-mesh-muted mt-0.5">Komuta Merkezi</p>
      </div>

      <nav className="flex-1 p-2 flex flex-col gap-1 mt-2">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === '/'}
            className={({ isActive }) => `
              flex items-center gap-3 px-3 py-2.5 rounded-lg
              font-nunito text-sm font-semibold transition-all
              ${isActive
                ? 'bg-mesh-accent/20 text-mesh-accent border border-mesh-accent/30'
                : 'text-mesh-muted hover:text-white hover:bg-mesh-bg'
              }
            `}
          >
            <span className="text-lg">{item.icon}</span>
            <span className="whitespace-nowrap">{item.label}</span>
          </NavLink>
        ))}
      </nav>
    </div>
  );
};

export default SidebarNav;
