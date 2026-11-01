import React, { useEffect, useState } from 'react';
import { X, BookOpen, Volume2, Copy, Check, Share2 } from 'lucide-react';
import { getAyahTafseer } from '../services/quranService';
import { SURAH_LIST } from '../data/surahList';

interface TafseerModalProps {
  surahNumber: number;
  ayahNumber: number;
  ayahText: string;
  translationEn?: string;
  onClose: () => void;
  onPlayAyah: (surah: number, ayah: number) => void;
  onShareAyah: (surah: number, ayah: number, text: string) => void;
}

export const TafseerModal: React.FC<TafseerModalProps> = ({
  surahNumber,
  ayahNumber,
  ayahText,
  translationEn,
  onClose,
  onPlayAyah,
  onShareAyah,
}) => {
  const [tafseerText, setTafseerText] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [copied, setCopied] = useState<boolean>(false);

  const surahMeta = SURAH_LIST.find((s) => s.number === surahNumber) || SURAH_LIST[0];

  useEffect(() => {
    let active = true;
    setIsLoading(true);
    getAyahTafseer(surahNumber, ayahNumber)
      .then((t) => {
        if (active) {
          setTafseerText(t);
          setIsLoading(false);
        }
      })
      .catch(() => {
        if (active) {
          setTafseerText('تعذر تحميل التفسير حالياً.');
          setIsLoading(false);
        }
      });

    return () => {
      active = false;
    };
  }, [surahNumber, ayahNumber]);

  const handleCopy = () => {
    const textToCopy = `﴿${ayahText}﴾ [${surahMeta.nameAr}: ${ayahNumber}]\n\nالتفسير الميسر:\n${tafseerText}`;
    navigator.clipboard.writeText(textToCopy);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-end sm:items-center justify-center p-0 sm:p-4">
      <div className="bg-[#FAF7F2] dark:bg-[#1A221E] w-full sm:max-w-2xl sm:rounded-3xl rounded-t-3xl max-h-[90vh] flex flex-col border border-[#E8E2D7] dark:border-[#2D3A32] shadow-2xl overflow-hidden animate-in slide-in-from-bottom duration-200">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#E8E2D7] dark:border-[#2D3A32] bg-[#F2EDE4]/70 dark:bg-[#141A17]/70">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-[#5D7263]/15 flex items-center justify-center text-[#5D7263]">
              <BookOpen className="w-4 h-4" />
            </div>
            <div>
              <h3 className="font-bold text-base text-[#2D3748] dark:text-[#E2E8F0]">
                تفسير السعدي والبيان
              </h3>
              <p className="text-xs text-[#718096] dark:text-[#94A3B8]">
                سورة {surahMeta.nameAr} • الآية {ayahNumber}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-1">
            <button
              onClick={() => onPlayAyah(surahNumber, ayahNumber)}
              className="p-2 rounded-lg text-[#5D7263] hover:bg-[#E8E2D7] dark:hover:bg-[#28342D] transition"
              title="استماع للآية"
            >
              <Volume2 className="w-4 h-4" />
            </button>
            <button
              onClick={() => onShareAyah(surahNumber, ayahNumber, ayahText)}
              className="p-2 rounded-lg text-[#5D7263] hover:bg-[#E8E2D7] dark:hover:bg-[#28342D] transition"
              title="مشاركة كبطاقة"
            >
              <Share2 className="w-4 h-4" />
            </button>
            <button
              onClick={handleCopy}
              className="p-2 rounded-lg text-[#5D7263] hover:bg-[#E8E2D7] dark:hover:bg-[#28342D] transition"
              title="نسخ الآية مع التفسير"
            >
              {copied ? <Check className="w-4 h-4 text-emerald-600" /> : <Copy className="w-4 h-4" />}
            </button>
            <button
              onClick={onClose}
              className="p-2 rounded-lg text-[#718096] hover:bg-[#E8E2D7] dark:hover:bg-[#28342D] transition"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Content Body */}
        <div className="overflow-y-auto p-6 space-y-5 text-right">
          {/* Ayah Arabic Box */}
          <div className="p-5 rounded-2xl bg-[#EFE9DF]/60 dark:bg-[#222C26] border border-[#E2DAD0] dark:border-[#2C3831] space-y-3">
            <p className="font-quran text-2xl sm:text-3xl leading-loose text-[#1A202C] dark:text-[#F7FAFC]">
              {ayahText}
            </p>
            {translationEn && (
              <p className="text-xs sm:text-sm text-[#4A5568] dark:text-[#A0AEC0] italic border-t border-[#E2DAD0] dark:border-[#2C3831] pt-2 text-left" dir="ltr">
                {translationEn}
              </p>
            )}
          </div>

          {/* Tafseer text */}
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-xs font-bold text-[#5D7263] dark:text-[#A7BFAC]">
              <span className="w-2 h-2 rounded-full bg-[#5D7263]" />
              <span>تيسير الكريم الرحمن في تفسير كلام المنان (ابن سعدي)</span>
            </div>

            {isLoading ? (
              <div className="py-8 flex flex-col items-center justify-center gap-3">
                <div className="w-7 h-7 border-2 border-[#5D7263] border-t-transparent rounded-full animate-spin" />
                <span className="text-xs text-[#718096] dark:text-[#94A3B8]">جاري تحميل التفسير...</span>
              </div>
            ) : (
              <div className="text-sm sm:text-base leading-relaxed text-[#2D3748] dark:text-[#E2E8F0] whitespace-pre-line p-4 rounded-xl bg-white/60 dark:bg-[#1E2722] border border-[#E8E2D7] dark:border-[#2A362F]">
                {tafseerText}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
