import React, { useState, useRef } from 'react';
import { X, Copy, Check, Sparkles } from 'lucide-react';
import { SURAH_LIST } from '../data/surahList';

interface AyahShareModalProps {
  surahNumber: number;
  ayahNumber: number;
  ayahText: string;
  onClose: () => void;
}

export const AyahShareModal: React.FC<AyahShareModalProps> = ({
  surahNumber,
  ayahNumber,
  ayahText,
  onClose,
}) => {
  const [theme, setTheme] = useState<'emerald' | 'beige' | 'slate' | 'gold'>('emerald');
  const [copied, setCopied] = useState<boolean>(false);
  const cardRef = useRef<HTMLDivElement | null>(null);

  const surahMeta = SURAH_LIST.find((s) => s.number === surahNumber) || SURAH_LIST[0];

  const themeStyles = {
    emerald: {
      bg: 'bg-gradient-to-br from-[#2D4536] via-[#1E3025] to-[#142219]',
      text: 'text-[#F4EBD9]',
      meta: 'text-[#A8C7B2]',
      border: 'border-[#4D6A58]/50',
      badge: 'bg-[#4D6A58]/30 text-[#E0EFE5]',
    },
    beige: {
      bg: 'bg-gradient-to-br from-[#F5EFE6] via-[#EAE1D2] to-[#DFD4C2]',
      text: 'text-[#2D2A26]',
      meta: 'text-[#7D6F5D]',
      border: 'border-[#C8B8A2]/60',
      badge: 'bg-[#C8B8A2]/30 text-[#4D4436]',
    },
    slate: {
      bg: 'bg-gradient-to-br from-[#1E252B] via-[#151A1E] to-[#0D1013]',
      text: 'text-[#F1F5F9]',
      meta: 'text-[#94A3B8]',
      border: 'border-[#334155]/60',
      badge: 'bg-[#334155]/40 text-[#E2E8F0]',
    },
    gold: {
      bg: 'bg-gradient-to-br from-[#3A2D16] via-[#2B210F] to-[#1C150A]',
      text: 'text-[#FDF6E2]',
      meta: 'text-[#E2C37A]',
      border: 'border-[#D4AF37]/40',
      badge: 'bg-[#D4AF37]/20 text-[#F5E6B3]',
    },
  };

  const currentTheme = themeStyles[theme];

  const handleCopyText = () => {
    const formatted = `﴿ ${ayahText} ﴾\n[سورة ${surahMeta.nameAr} - الآية ${ayahNumber}]\n\n— تطبيق الفُرقان`;
    navigator.clipboard.writeText(formatted);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-[#FAF7F2] dark:bg-[#1A221E] w-full max-w-lg rounded-3xl p-6 border border-[#E8E2D7] dark:border-[#2D3A32] shadow-2xl space-y-5">
        <div className="flex items-center justify-between pb-2 border-b border-[#E8E2D7] dark:border-[#2D3A32]">
          <div className="flex items-center gap-2">
            <Sparkles className="w-5 h-5 text-[#5D7263]" />
            <h3 className="font-bold text-base text-[#2D3748] dark:text-[#E2E8F0]">
              بطاقة مشاركة الآية
            </h3>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-[#718096] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28]"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Theme Picker */}
        <div className="flex items-center justify-center gap-2">
          <button
            onClick={() => setTheme('emerald')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition ${
              theme === 'emerald' ? 'bg-[#2D4536] text-white shadow' : 'bg-[#EFE9DF] dark:bg-[#242E28] text-[#4A5568] dark:text-[#CBD5E1]'
            }`}
          >
            الأخضر الزمردي
          </button>
          <button
            onClick={() => setTheme('beige')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition ${
              theme === 'beige' ? 'bg-[#D2C5B4] text-[#2D2A26] shadow font-bold' : 'bg-[#EFE9DF] dark:bg-[#242E28] text-[#4A5568] dark:text-[#CBD5E1]'
            }`}
          >
            البيج التراثي
          </button>
          <button
            onClick={() => setTheme('slate')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition ${
              theme === 'slate' ? 'bg-[#1E252B] text-white shadow' : 'bg-[#EFE9DF] dark:bg-[#242E28] text-[#4A5568] dark:text-[#CBD5E1]'
            }`}
          >
            الليل الهادئ
          </button>
          <button
            onClick={() => setTheme('gold')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition ${
              theme === 'gold' ? 'bg-[#B89230] text-white shadow' : 'bg-[#EFE9DF] dark:bg-[#242E28] text-[#4A5568] dark:text-[#CBD5E1]'
            }`}
          >
            الذهب الملكي
          </button>
        </div>

        {/* The Card Preview */}
        <div
          ref={cardRef}
          className={`p-7 rounded-2xl border ${currentTheme.border} ${currentTheme.bg} shadow-lg space-y-6 text-center transition-all duration-300 relative overflow-hidden`}
        >
          {/* Subtle Islamic corner decoration */}
          <div className="absolute top-2 right-2 text-xs opacity-20 select-none">۞</div>
          <div className="absolute bottom-2 left-2 text-xs opacity-20 select-none">۞</div>

          <div className="flex items-center justify-between">
            <span className={`text-xs px-2.5 py-1 rounded-full font-medium ${currentTheme.badge}`}>
              سورة {surahMeta.nameAr}
            </span>
            <span className={`text-xs ${currentTheme.meta}`}>
              الآية {ayahNumber}
            </span>
          </div>

          <p className={`font-quran text-2xl sm:text-3xl leading-loose px-2 ${currentTheme.text}`}>
            {ayahText}
          </p>

          <div className={`pt-4 border-t ${currentTheme.border} flex items-center justify-between text-[11px] ${currentTheme.meta}`}>
            <span>الفُرقان — Al-Furkan</span>
            <span>بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ</span>
          </div>
        </div>

        {/* Copy / Actions */}
        <div className="flex gap-2">
          <button
            onClick={handleCopyText}
            className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl bg-[#5D7263] hover:bg-[#4E6153] text-white font-semibold text-sm transition shadow-sm"
          >
            {copied ? <Check className="w-4 h-4 text-white" /> : <Copy className="w-4 h-4" />}
            <span>{copied ? 'تم النسخ بنجاح!' : 'نسخ النص للمشاركة'}</span>
          </button>
        </div>
      </div>
    </div>
  );
};
