import React, { useState, useEffect } from 'react';
import {
  Users,
  Mic,
  MicOff,
  Radio,
  Share2,
  CheckCircle2,
  Sparkles,
  Volume2,
  UserCheck,
  LogOut,
  LogIn,
} from 'lucide-react';
import { HalaqaRoomState, Riwayah } from '../types/hifz';
import { halaqaRoomService } from '../services/livekitHelper';
import { SURAH_LIST } from '../data/surahList';

interface HalaqaRoomViewProps {
  onStartHifzWithRange?: (surah: number, start: number, end: number, riwayah: Riwayah) => void;
}

export const HalaqaRoomView: React.FC<HalaqaRoomViewProps> = ({ onStartHifzWithRange }) => {
  const [roomState, setRoomState] = useState<HalaqaRoomState>({
    roomId: '',
    isConnected: false,
    isAudioMuted: false,
    activeSurah: 1,
    activeStartAyah: 1,
    activeEndAyah: 7,
    activeRiwayah: 'hafs',
    currentTurnSpeakerId: 'me',
    participants: [],
  });

  const [inputRoomId, setInputRoomId] = useState<string>('HIFZ-777');
  const [inputName, setInputName] = useState<string>('علي (الحافظ)');
  const [copied, setCopied] = useState<boolean>(false);

  useEffect(() => {
    const unsubscribe = halaqaRoomService.subscribe((state) => {
      setRoomState(state);
    });
    return () => unsubscribe();
  }, []);

  const handleJoin = async () => {
    if (!inputRoomId.trim()) return;
    await halaqaRoomService.joinRoom(
      inputRoomId.trim().toUpperCase(),
      inputName.trim(),
      roomState.activeSurah,
      roomState.activeStartAyah,
      roomState.activeEndAyah,
      roomState.activeRiwayah
    );
  };

  const handleLeave = () => {
    halaqaRoomService.leaveRoom();
  };

  const handleToggleMute = () => {
    halaqaRoomService.toggleMute();
  };

  const handleTakeTurn = (id: string) => {
    halaqaRoomService.setTurn(id);
  };

  const handleCopyLink = () => {
    navigator.clipboard?.writeText(
      `${window.location.origin}?room=${roomState.roomId || inputRoomId}`
    );
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const currentSurah =
    SURAH_LIST.find((s) => s.number === roomState.activeSurah) || SURAH_LIST[0];

  return (
    <div
      dir="rtl"
      className="max-w-2xl mx-auto px-4 py-6 space-y-6 text-[#1E201D] dark:text-[#E6D5B8]"
    >
      {/* Header Banner */}
      <div className="text-center space-y-1">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#4A6B5D]/10 dark:bg-[#7FA695]/15 text-[#4A6B5D] dark:text-[#7FA695] text-xs font-bold mb-1">
          <Radio className="w-3.5 h-3.5 animate-pulse" />
          <span>غرفة التسميع الصوتي المباشر</span>
        </div>
        <h1 className="text-xl font-bold font-cairo">حلقة الأصدقاء للحفظ المتبادل</h1>
        <p className="text-xs text-[#7F8E87] dark:text-[#8D9F96]">
          غرفة صوتية فورية ومشتركة تسمع فيها لأصحابك وتسمعون لبعضكم دون تشتيت
        </p>
      </div>

      {!roomState.isConnected ? (
        /* Join Room Card */
        <div className="p-6 rounded-3xl bg-[#FBF8F3] dark:bg-[#151C18] border border-[#E8E2D7] dark:border-[#222E27] shadow-lg space-y-4">
          <div className="space-y-1">
            <label className="text-xs font-bold text-[#55635C] dark:text-[#9FB1A8]">
              اسمك في الحلقة
            </label>
            <input
              type="text"
              value={inputName}
              onChange={(e) => setInputName(e.target.value)}
              className="w-full px-3 py-2.5 rounded-xl bg-[#F2ECE1] dark:bg-[#1C2520] border border-[#E2D9CC] dark:border-[#28352E] text-sm font-semibold focus:outline-hidden focus:ring-2 focus:ring-[#4A6B5D]"
              placeholder="مثال: عبد الله"
            />
          </div>

          <div className="space-y-1">
            <label className="text-xs font-bold text-[#55635C] dark:text-[#9FB1A8]">
              رمز الغرفة الخاصة (شارك الرمز مع رفاق الحفظ)
            </label>
            <div className="flex gap-2">
              <input
                type="text"
                value={inputRoomId}
                onChange={(e) => setInputRoomId(e.target.value)}
                className="flex-1 px-3 py-2.5 rounded-xl bg-[#F2ECE1] dark:bg-[#1C2520] border border-[#E2D9CC] dark:border-[#28352E] text-sm font-mono font-bold tracking-wider uppercase focus:outline-hidden focus:ring-2 focus:ring-[#4A6B5D]"
                placeholder="HIFZ-123"
              />
              <button
                type="button"
                onClick={() => setInputRoomId(`HIFZ-${Math.floor(100 + Math.random() * 900)}`)}
                className="px-3 py-2 rounded-xl bg-[#E8E1D5] dark:bg-[#202B25] text-xs font-bold hover:bg-[#DDD4C6] dark:hover:bg-[#2A3931] transition-colors"
              >
                توليد رمز
              </button>
            </div>
          </div>

          <button
            type="button"
            onClick={handleJoin}
            className="w-full py-3 rounded-2xl bg-[#4A6B5D] hover:bg-[#3E5C4F] text-white font-bold text-sm shadow-md flex items-center justify-center gap-2 transition-transform active:scale-98"
          >
            <LogIn className="w-4 h-4" />
            <span>دخول الحلقة الآن</span>
          </button>
        </div>
      ) : (
        /* Active Connected Room */
        <div className="space-y-6">
          {/* Room Status Top Bar */}
          <div className="p-4 rounded-2xl bg-[#F2ECE1] dark:bg-[#1A231F] border border-[#E2D9CC] dark:border-[#28352E] flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse" />
              <div>
                <p className="text-xs font-bold font-mono text-[#4A6B5D] dark:text-[#7FA695]">
                  الغرفة: {roomState.roomId}
                </p>
                <p className="text-[11px] text-[#788880] dark:text-[#8D9F96]">
                  {roomState.participants.length} إخوة متصلون
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={handleCopyLink}
                className="p-2 rounded-xl bg-[#E2D9CC] dark:bg-[#24312A] text-xs font-bold hover:bg-[#D7CDBC] transition-colors flex items-center gap-1"
                title="مشاركة رمز الغرفة"
              >
                {copied ? (
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                ) : (
                  <Share2 className="w-4 h-4" />
                )}
                <span className="text-[11px]">مشاركة</span>
              </button>

              <button
                onClick={handleLeave}
                className="p-2 rounded-xl bg-rose-500/10 text-rose-600 hover:bg-rose-500/20 text-xs font-bold transition-colors flex items-center gap-1"
                title="مغادرة الغرفة"
              >
                <LogOut className="w-4 h-4" />
                <span className="text-[11px]">مغادرة</span>
              </button>
            </div>
          </div>

          {/* Active Synced Target Verses */}
          <div className="p-4 rounded-2xl bg-[#FBF8F3] dark:bg-[#151C18] border border-[#E8E2D7] dark:border-[#222E27] space-y-2 text-center">
            <div className="flex items-center justify-center gap-2 text-xs font-bold text-[#4A6B5D] dark:text-[#7FA695]">
              <Sparkles className="w-3.5 h-3.5" />
              <span>المقطع الموحد للحلقة</span>
            </div>
            <h2 className="text-lg font-bold font-cairo">
              سورة {currentSurah.nameAr} • الآيات ({roomState.activeStartAyah} - {roomState.activeEndAyah})
            </h2>

            {onStartHifzWithRange && (
              <button
                onClick={() =>
                  onStartHifzWithRange(
                    roomState.activeSurah,
                    roomState.activeStartAyah,
                    roomState.activeEndAyah,
                    roomState.activeRiwayah
                  )
                }
                className="mt-2 px-4 py-1.5 rounded-xl bg-[#4A6B5D] text-white text-xs font-bold hover:bg-[#3D5A4E] transition-transform active:scale-95 inline-flex items-center gap-1.5"
              >
                <span>فتح المقطع في وضع الحفظ الفردي</span>
              </button>
            )}
          </div>

          {/* Participant Avatar Bubbles with animated green pulse when speaking */}
          <div className="space-y-3">
            <div className="flex items-center justify-between text-xs font-bold text-[#6D7D75] dark:text-[#8D9F96] px-1">
              <span>الحاضرون في الحلقة</span>
              <span>انقر لتعيين دور التلاوة</span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {roomState.participants.map((p) => {
                const isTurn = p.id === roomState.currentTurnSpeakerId;
                return (
                  <div
                    key={p.id}
                    onClick={() => handleTakeTurn(p.id)}
                    className={`p-4 rounded-2xl border transition-all cursor-pointer flex items-center justify-between ${
                      isTurn
                        ? 'bg-[#4A6B5D]/10 dark:bg-[#7FA695]/15 border-[#4A6B5D] dark:border-[#7FA695] shadow-xs'
                        : 'bg-[#FBF8F3] dark:bg-[#151C18] border-[#E8E2D7] dark:border-[#222E27]'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      {/* Avatar with speaking ripple */}
                      <div className="relative">
                        <div
                          className={`w-12 h-12 rounded-full flex items-center justify-center font-bold text-sm transition-all ${
                            isTurn
                              ? 'bg-[#4A6B5D] text-white'
                              : 'bg-[#F2ECE1] dark:bg-[#202B25] text-[#1E201D] dark:text-[#E6D5B8]'
                          } ${
                            p.isSpeaking
                              ? 'ring-4 ring-emerald-500 ring-offset-2 ring-offset-white dark:ring-offset-[#121615] animate-pulse'
                              : ''
                          }`}
                        >
                          {p.name.charAt(0)}
                        </div>
                        {p.isSpeaking && (
                          <span className="absolute -top-1 -right-1 flex h-3 w-3">
                            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
                            <span className="relative inline-flex rounded-full h-3 w-3 bg-emerald-500" />
                          </span>
                        )}
                      </div>

                      <div>
                        <p className="text-sm font-bold flex items-center gap-1.5">
                          <span>{p.name}</span>
                          {p.id === 'me' && (
                            <span className="text-[10px] px-1.5 py-0.5 rounded-md bg-[#E2D9CC] dark:bg-[#26342D] text-[#55635C] dark:text-[#A7BAAE]">
                              أنت
                            </span>
                          )}
                        </p>
                        <p className="text-xs text-[#7F8E87] dark:text-[#8D9F96]">
                          {isTurn ? (
                            <span className="text-[#4A6B5D] dark:text-[#7FA695] font-semibold flex items-center gap-1">
                              <UserCheck className="w-3 h-3" />
                              <span>دوره في التسميع الآن</span>
                            </span>
                          ) : p.isSpeaking ? (
                            <span className="text-emerald-600 font-semibold">يتحدث الآن...</span>
                          ) : p.isMuted ? (
                            <span>مكتوم الصوت</span>
                          ) : (
                            <span>يستمع بخشوع</span>
                          )}
                        </p>
                      </div>
                    </div>

                    <div>
                      {p.isMuted ? (
                        <MicOff className="w-4 h-4 text-rose-500" />
                      ) : (
                        <Mic className="w-4 h-4 text-[#4A6B5D] dark:text-[#7FA695]" />
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Bottom Floating Mic Bar for Current User */}
          <div className="p-4 rounded-2xl bg-[#F2ECE1] dark:bg-[#1A231F] border border-[#E2D9CC] dark:border-[#28352E] flex items-center justify-between">
            <div className="flex items-center gap-2">
              <button
                onClick={handleToggleMute}
                className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold transition-all shadow-xs ${
                  roomState.isAudioMuted
                    ? 'bg-rose-500 text-white hover:bg-rose-600'
                    : 'bg-[#4A6B5D] text-white hover:bg-[#3D5A4E]'
                }`}
              >
                {roomState.isAudioMuted ? (
                  <>
                    <MicOff className="w-4 h-4" />
                    <span>الميكروفون مكتوم (انقر للتحدث)</span>
                  </>
                ) : (
                  <>
                    <Mic className="w-4 h-4 animate-bounce" />
                    <span>الميكروفون مفتوح</span>
                  </>
                )}
              </button>
            </div>

            <button
              onClick={() => handleTakeTurn('me')}
              className="px-3 py-2 rounded-xl bg-[#E2D9CC] dark:bg-[#25332B] hover:bg-[#D7CDBC] dark:hover:bg-[#2E3E34] text-xs font-bold text-[#1E201D] dark:text-[#E6D5B8] transition-colors"
            >
              استلم دور التلاوة
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
