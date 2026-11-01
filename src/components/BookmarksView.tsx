import React, { useState } from 'react';
import { Bookmark as BookmarkIcon, BookOpen, Trash2, Edit3, ArrowLeft } from 'lucide-react';
import { Bookmark } from '../types/quran';

interface BookmarksViewProps {
  bookmarks: Bookmark[];
  onRemoveBookmark: (id: string) => void;
  onUpdateNote: (id: string, note: string) => void;
  onNavigateToAyah: (surahNumber: number, ayahNumber: number) => void;
}

export const BookmarksView: React.FC<BookmarksViewProps> = ({
  bookmarks,
  onRemoveBookmark,
  onUpdateNote,
  onNavigateToAyah,
}) => {
  const [editingId, setEditingId] = useState<string | null>(null);
  const [noteText, setNoteText] = useState<string>('');

  const startEdit = (b: Bookmark) => {
    setEditingId(b.id);
    setNoteText(b.note || '');
  };

  const saveNote = (id: string) => {
    onUpdateNote(id, noteText);
    setEditingId(null);
  };

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 py-6 space-y-6 pb-28">
      {/* Header */}
      <div className="bg-[#FAF7F2] dark:bg-[#1A221E] p-6 rounded-3xl border border-[#E8E2D7] dark:border-[#27322B] shadow-sm flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-amber-500/15 text-amber-600 dark:text-amber-400 flex items-center justify-center">
            <BookmarkIcon className="w-5 h-5 fill-current" />
          </div>
          <div>
            <h2 className="font-bold text-base text-[#2D3748] dark:text-[#E2E8F0]">
              المحفوظات والملاحظات القرآنيّة
            </h2>
            <p className="text-xs text-[#718096] dark:text-[#94A3B8]">
              الآيات التي تم حفظها للتدبر والمراجعة مع خواطرك الإيمانية
            </p>
          </div>
        </div>

        <span className="text-xs font-bold px-3 py-1 rounded-full bg-[#5D7263]/15 text-[#3B5249] dark:text-[#A7BFAC]">
          {bookmarks.length} آية محفوظة
        </span>
      </div>

      {bookmarks.length === 0 ? (
        <div className="py-20 text-center space-y-3 bg-[#FAF7F2] dark:bg-[#1A221E] rounded-3xl border border-[#E8E2D7] dark:border-[#27322B] p-8">
          <div className="w-12 h-12 rounded-full bg-[#EFE9DF] dark:bg-[#242E28] text-[#718096] flex items-center justify-center mx-auto">
            <BookmarkIcon className="w-6 h-6" />
          </div>
          <p className="text-sm font-semibold text-[#2D3748] dark:text-[#E2E8F0]">
            لم تقم بحفظ أي آية حتى الآن
          </p>
          <p className="text-xs text-[#718096] dark:text-[#94A3B8] max-w-sm mx-auto">
            يمكنك حفظ أي آية أثناء القراءة في المصحف بالضغط على أيقونة الإشارة المرجعية للعودة إليها لاحقاً.
          </p>
        </div>
      ) : (
        <div className="space-y-4">
          {bookmarks.map((b) => (
            <div
              key={b.id}
              className="p-6 rounded-3xl bg-[#FAF7F2] dark:bg-[#1A221E] border border-[#E8E2D7] dark:border-[#27322B] shadow-sm space-y-4"
            >
              <div className="flex items-center justify-between pb-3 border-b border-[#E8E2D7]/60 dark:border-[#27322B]/60 text-xs">
                <span className="font-bold text-sm text-[#3B5249] dark:text-[#A7BFAC]">
                  سورة {b.surahNameAr} • الآية {b.ayahNumber}
                </span>

                <div className="flex items-center gap-1.5">
                  <button
                    onClick={() => onNavigateToAyah(b.surahNumber, b.ayahNumber)}
                    className="flex items-center gap-1 px-3 py-1.5 rounded-xl bg-[#5D7263]/10 text-[#5D7263] dark:text-[#A7BFAC] hover:bg-[#5D7263]/20 font-bold transition"
                  >
                    <BookOpen className="w-3.5 h-3.5" />
                    <span>قراءة في السورة</span>
                  </button>

                  <button
                    onClick={() => startEdit(b)}
                    className="p-1.5 rounded-lg text-[#718096] hover:bg-[#EFE9DF] dark:hover:bg-[#28342D]"
                    title="تعديل الملاحظة"
                  >
                    <Edit3 className="w-3.5 h-3.5" />
                  </button>

                  <button
                    onClick={() => onRemoveBookmark(b.id)}
                    className="p-1.5 rounded-lg text-rose-500 hover:bg-rose-50 dark:hover:bg-rose-950/40"
                    title="إزالة من المحفوظات"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>

              {/* Ayah text */}
              <p className="font-quran text-2xl leading-loose text-right text-[#1A202C] dark:text-[#F7FAFC]">
                {b.textSnippet}
              </p>

              {/* Note or Note Editor */}
              {editingId === b.id ? (
                <div className="space-y-2 pt-2 border-t border-[#E8E2D7]/60 dark:border-[#27322B]/60">
                  <textarea
                    value={noteText}
                    onChange={(e) => setNoteText(e.target.value)}
                    placeholder="اكتب تدبرك أو ملاحظتك حول هذه الآية..."
                    className="w-full p-3 rounded-xl border border-[#E0D7C9] dark:border-[#2D3931] bg-white dark:bg-[#151B17] text-xs leading-relaxed focus:outline-none focus:ring-1 focus:ring-[#5D7263]"
                    rows={3}
                  />
                  <div className="flex justify-end gap-2">
                    <button
                      onClick={() => setEditingId(null)}
                      className="px-3 py-1 rounded-lg text-xs text-[#718096] hover:bg-[#EFE9DF]"
                    >
                      إلغاء
                    </button>
                    <button
                      onClick={() => saveNote(b.id)}
                      className="px-4 py-1 rounded-lg text-xs font-bold bg-[#5D7263] text-white"
                    >
                      حفظ الملاحظة
                    </button>
                  </div>
                </div>
              ) : b.note ? (
                <div className="p-3.5 rounded-2xl bg-amber-50/60 dark:bg-amber-950/20 border border-amber-200/60 dark:border-amber-900/40 text-xs text-[#4A5568] dark:text-[#CBD5E1] space-y-1">
                  <span className="font-bold text-[#8C6D23] dark:text-[#E2C37A] block">
                    خواطر وتدبر:
                  </span>
                  <p className="leading-relaxed">{b.note}</p>
                </div>
              ) : null}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
