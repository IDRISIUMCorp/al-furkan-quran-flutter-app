import React from 'react';
import { BookOpen, Users, BellRing } from 'lucide-react';

export type ZenTabId = 'hifz' | 'halaqa' | 'alarms';

interface ZenTabBarProps {
  activeTab: ZenTabId;
  onTabChange: (tab: ZenTabId) => void;
  isVisible: boolean; // Auto-hidden in Zen Focus Mode
}

export const ZenTabBar: React.FC<ZenTabBarProps> = ({
  activeTab,
  onTabChange,
  isVisible,
}) => {
  if (!isVisible) return null;

  const tabs: { id: ZenTabId; label: string; icon: React.FC<{ className?: string }> }[] = [
    { id: 'hifz', label: 'الحفظ والمصحف', icon: BookOpen },
    { id: 'halaqa', label: 'حلقة الأصدقاء', icon: Users },
    { id: 'alarms', label: 'الجدول والمنبهات', icon: BellRing },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-30 transition-transform duration-300 backdrop-blur-md bg-[#FBF8F3]/95 dark:bg-[#121615]/95 border-t border-[#E8E2D7] dark:border-[#222B27]">
      <div className="max-w-md mx-auto px-4 h-16 flex items-center justify-around">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className={`flex flex-col items-center justify-center gap-1 w-24 py-1.5 rounded-xl transition-all duration-150 relative ${
                isActive
                  ? 'text-[#4A6B5D] dark:text-[#7FA695]'
                  : 'text-[#85928C] dark:text-[#6C7C75] hover:text-[#4A6B5D] dark:hover:text-[#A7C2B5]'
              }`}
            >
              <Icon className={`w-5 h-5 transition-transform ${isActive ? 'scale-110 stroke-[2.2]' : 'stroke-[1.8]'}`} />
              <span className={`text-[11px] font-medium tracking-tight ${isActive ? 'font-bold' : ''}`}>
                {tab.label}
              </span>
              {isActive && (
                <span className="absolute bottom-1 w-1.5 h-1.5 rounded-full bg-[#4A6B5D] dark:bg-[#7FA695]" />
              )}
            </button>
          );
        })}
      </div>
    </nav>
  );
};
