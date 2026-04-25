/// ثوابت الأدمن الرئيسي — IDRISIUM Corp.
class AdminConstants {
  AdminConstants._();

  // ── Identity ──────────────────────────────────────────────
  static const adminEmail = 'idris.ghamid@gmail.com';
  static const adminName = 'إدريس غامد';
  static const adminTitle = 'Founder & Software Architect';
  static const adminId = 'IDRISIUM_ADMIN';
  static const corpName = 'IDRISIUM Corp';

  // ── Social Links ──────────────────────────────────────────
  static const telegram = 'https://t.me/IDRV72';
  static const telegramHandle = '@IDRV72';
  static const tiktok = 'https://www.tiktok.com/@idris.ghamid';
  static const tiktokHandle = '@idris.ghamid';
  static const instagram = 'https://www.instagram.com/idris.ghamid';
  static const instagramHandle = '@idris.ghamid';
  static const linkedin = 'https://www.linkedin.com/in/idris-ghamid';
  static const linkedinHandle = 'Idris Ghamid';
  static const website = 'http://idrisium.linkpc.net/';
  static const github = 'https://github.com/IDRISIUMCorp';
  static const emailLink = 'mailto:idris.ghamid@gmail.com';

  // ── Assets ────────────────────────────────────────────────
  static const founderPicUrl = 'https://i.postimg.cc/j2Vkg6kg/idris-ghamid.jpg';
  static const corpLogoUrl = 'https://i.postimg.cc/YSjfXgQh/logo.png';

  /// Check if a given email belongs to the admin.
  static bool isAdminEmail(String? email) =>
      email != null && email.toLowerCase() == adminEmail.toLowerCase();
}
