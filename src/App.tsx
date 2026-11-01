import React, { useState, useEffect } from 'react';
import { ZenTabId, ZenTabBar } from './components/ZenTabBar';
import { ZenNavbar } from './components/ZenNavbar';
import { ZenHifzView } from './components/ZenHifzView';
import { HalaqaRoomView } from './components/HalaqaRoomView';
import { ScheduleAlarmsView } from './components/ScheduleAlarmsView';
import { RepetitionSetupSheet } from './components/RepetitionSetupSheet';
import { SurahPickerModal } from './components/SurahPickerModal';
import { HifzSessionConfig, Riwayah } from './types/hifz';
import { SURAH_LIST } from './data/surahList';

export function App() {
  const [activeTab, setActiveTab] = useState<ZenTabId>('hifz');
  const [isFocusModeActive, setIsFocusModeActive] = useState<boolean>(false);
  const [isSetupOpen, setIsSetupOpen] = useState<boolean>(false);
  const [isSurahPickerOpen, setIsSurahPickerOpen] = useState<boolean>(false);

  const [isDarkMode, setIsDarkMode] = useState<boolean>(() => {
    return localStorage.getItem('zen_hifz_theme') === 'dark';
  });

  const [sessionConfig, setSessionConfig] = useState<HifzSessionConfig>(() => {
    const saved = localStorage.getItem('zen_hifz_config');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (_) {}
    }
    return {
      surahNumber: 1, // Al-Fatihah
      startAyah: 1,
      endAyah: 7,
      singleRepeatCount: 10,
      linkGroupSize: 3,
      linkGroupRepeatCount: 3,
      pauseDelaySeconds: 4,
      riwayah: 'hafs',
      reciterId: 'husary_muallim',
      maskingMode: 'visible',
      fontSize: 28,
      playbackRate: 1.0,
    };
  });

  // Sync Dark Mode class with <html>
  useEffect(() => {
    if (isDarkMode) {
      document.documentElement.classList.add('dark');
      localStorage.setItem('zen_hifz_theme', 'dark');
    } else {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('zen_hifz_theme', 'light');
    }
  }, [isDarkMode]);

  // Save session config
  useEffect(() => {
    localStorage.setItem('zen_hifz_config', JSON.stringify(sessionConfig));
  }, [sessionConfig]);

  const currentSurahMeta =
    SURAH_LIST.find((s) => s.number === sessionConfig.surahNumber) || SURAH_LIST[0];

  const handleSelectSurah = (surahNum: number) => {
    const meta = SURAH_LIST.find((s) => s.number === surahNum);
    const versesCount = meta ? meta.versesCount : 7;
    setSessionConfig((prev) => ({
      ...prev,
      surahNumber: surahNum,
      startAyah: 1,
      endAyah: Math.min(5, versesCount),
    }));
    setIsSurahPickerOpen(false);
  };

  const handleStartHifzWithCustomRange = (
    surah: number,
    start: number,
    end: number,
    riwayah: Riwayah
  ) => {
    setSessionConfig((prev) => ({
      ...prev,
      surahNumber: surah,
      startAyah: start,
      endAyah: end,
      riwayah,
    }));
    setActiveTab('hifz');
  };

  const handleStartAlarmHifz = (targetDesc: string) => {
    setActiveTab('hifz');
  };

  return (
    <div
      dir="rtl"
      className="min-h-screen flex flex-col font-cairo transition-colors duration-200 bg-[#FBF8F3] dark:bg-[#121615] text-[#1E201D] dark:text-[#E6D5B8] selection:bg-[#4A6B5D]/20 selection:text-[#1E201D]"
    >
      {/* Top Navbar (Auto-hides in Zen Focus Mode) */}
      {!isFocusModeActive && (
        <ZenNavbar
          surahNameAr={currentSurahMeta.nameAr}
          startAyah={sessionConfig.startAyah}
          endAyah={sessionConfig.endAyah}
          riwayah={sessionConfig.riwayah}
          isDarkMode={isDarkMode}
          onToggleTheme={() => setIsDarkMode((d) => !d)}
          onOpenSetup={() => setIsSetupOpen(true)}
          onOpenSurahPicker={() => setIsSurahPickerOpen(true)}
        />
      )}

      {/* Main Screen Content */}
      <main className="flex-1">
        {activeTab === 'hifz' && (
          <ZenHifzView
            sessionConfig={sessionConfig}
            onUpdateConfig={setSessionConfig}
            onOpenSetup={() => setIsSetupOpen(true)}
            onOpenSurahPicker={() => setIsSurahPickerOpen(true)}
            isFocusModeActive={isFocusModeActive}
            setIsFocusModeActive={setIsFocusModeActive}
          />
        )}

        {activeTab === 'halaqa' && (
          <HalaqaRoomView onStartHifzWithRange={handleStartHifzWithCustomRange} />
        )}

        {activeTab === 'alarms' && (
          <ScheduleAlarmsView onStartHifzForAlarm={handleStartAlarmHifz} />
        )}
      </main>

      {/* 3-Tab Bottom Bar (Auto-hides in Zen Focus Mode) */}
      <ZenTabBar
        activeTab={activeTab}
        onTabChange={(tab) => {
          setActiveTab(tab);
          setIsFocusModeActive(false);
        }}
        isVisible={!isFocusModeActive}
      />

      {/* One-Sheet Repetition Setup Modal */}
      <RepetitionSetupSheet
        isOpen={isSetupOpen}
        onClose={() => setIsSetupOpen(false)}
        currentConfig={sessionConfig}
        onStartSession={(newConfig) => {
          setSessionConfig(newConfig);
          setActiveTab('hifz');
        }}
      />

      {/* Surah Picker Modal */}
      {isSurahPickerOpen && (
        <SurahPickerModal
          currentSurahNumber={sessionConfig.surahNumber}
          onSelectSurah={handleSelectSurah}
          onClose={() => setIsSurahPickerOpen(false)}
        />
      )}
    </div>
  );
}

export default App;
