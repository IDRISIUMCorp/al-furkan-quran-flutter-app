import "package:al_quran_v3/src/core/khatma/khatma_models.dart";
import "package:al_quran_v3/src/core/khatma/khatma_repository.dart";
import "package:al_quran_v3/src/screen/mushaf/mushaf_screen.dart";
import "package:al_quran_v3/src/utils/number_localization.dart";
import "package:flutter/material.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

enum _KhatmaSection { overview, today, stats, archive }

enum _KhatmaStartMode { beginning, currentPage }

class SmartKhatmaPage extends StatefulWidget {
  const SmartKhatmaPage({super.key});

  @override
  State<SmartKhatmaPage> createState() => _SmartKhatmaPageState();
}

class _SmartKhatmaPageState extends State<SmartKhatmaPage> {
  late final LocalKhatmaRepository _repository;
  final TextEditingController _customDaysController = TextEditingController(
    text: "30",
  );

  _KhatmaSection _section = _KhatmaSection.overview;
  _KhatmaStartMode _startMode = _KhatmaStartMode.beginning;
  bool _migrationReady = false;
  bool _reminderEnabled = false;
  int _selectedDays = 30;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _repository = LocalKhatmaRepository();
    _bootstrap();
  }

  @override
  void dispose() {
    _customDaysController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _repository.ensureMigrated();
    if (!mounted) return;
    setState(() => _migrationReady = true);
  }

  int get _customDaysValue {
    final parsed = int.tryParse(_customDaysController.text.trim());
    return (parsed ?? _selectedDays).clamp(1, 604);
  }

  int _currentSavedPage() {
    final raw = Hive.box("user").get("wahy_last_page", defaultValue: 1) as int?;
    return (raw ?? 1).clamp(1, 604);
  }

  KhatmaReminderSettings _draftReminderSettings() {
    return KhatmaReminderSettings(
      enabled: _reminderEnabled,
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
    );
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) return;
    setState(() => _reminderTime = picked);
  }

  Future<void> _createPlan() async {
    final startPage = _startMode == _KhatmaStartMode.currentPage
        ? _currentSavedPage()
        : 1;
    final days = _customDaysValue;
    final title = _startMode == _KhatmaStartMode.currentPage
        ? "ختمة من الصفحة الحالية"
        : "خطة ${localizedNumber(context, days)} يوم";

    await _repository.createPlan(
      days: days,
      startPage: startPage,
      title: title,
      reminder: _draftReminderSettings(),
    );

    if (!mounted) return;
    setState(() => _section = _KhatmaSection.overview);
  }

  Future<void> _updateActiveReminder(
    KhatmaPlanRecord plan, {
    bool? enabled,
    TimeOfDay? time,
  }) async {
    final updated = plan.reminder.copyWith(
      enabled: enabled,
      hour: time?.hour,
      minute: time?.minute,
    );
    await _repository.updateReminder(updated);
  }

  Future<void> _openReadingRange(KhatmaTodaySnapshot today) async {
    final startPage = today.hasOverdue
        ? today.overdueAssignments.first.startPage
        : today.scheduledAssignment?.startPage;
    if (startPage == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _KhatmaMushafPageHolder(),
        settings: RouteSettings(arguments: startPage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_migrationReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final box = Hive.box("user");
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: box.listenable(
        keys: const <String>[
          "khatma_v2_active_plan",
          "khatma_v2_archive",
          "wahy_last_page",
        ],
      ),
      builder: (context, _, __) {
        final activePlan = _repository.loadActivePlan();
        final archive = _repository.loadArchive();

        if (activePlan == null) {
          return _buildSetupState(archive);
        }

        final stats = _repository.buildStats(activePlan);
        final today = _repository.buildTodaySnapshot(activePlan);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            _buildActiveHero(activePlan, stats),
            const SizedBox(height: 12),
            _buildSectionSelector(),
            const SizedBox(height: 14),
            _buildActiveSection(
              plan: activePlan,
              stats: stats,
              today: today,
              archive: archive,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSetupState(List<KhatmaArchiveRecord> archive) {
    final currentPage = _currentSavedPage();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: <Widget>[
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Text(
                "تأسيس ختمة جديدة",
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                "خطة واحدة نشطة فقط، مع أرشيف كامل لكل الختمات السابقة وإحصائيات واضحة.",
                textAlign: TextAlign.right,
                style: TextStyle(
                  height: 1.6,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              const _SectionLabel("اختر مدة الخطة"),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _ChoiceChip(
                    label: "7 أيام",
                    selected: _selectedDays == 7,
                    onTap: () => setState(() => _selectedDays = 7),
                  ),
                  _ChoiceChip(
                    label: "10 أيام",
                    selected: _selectedDays == 10,
                    onTap: () => setState(() => _selectedDays = 10),
                  ),
                  _ChoiceChip(
                    label: "20 يوم",
                    selected: _selectedDays == 20,
                    onTap: () => setState(() => _selectedDays = 20),
                  ),
                  _ChoiceChip(
                    label: "30 يوم",
                    selected: _selectedDays == 30,
                    onTap: () => setState(() => _selectedDays = 30),
                  ),
                  _ChoiceChip(
                    label: "مخصص",
                    selected:
                        _selectedDays != 7 &&
                        _selectedDays != 10 &&
                        _selectedDays != 20 &&
                        _selectedDays != 30,
                    onTap: () =>
                        setState(() => _selectedDays = _customDaysValue),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customDaysController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                onChanged: (_) =>
                    setState(() => _selectedDays = _customDaysValue),
                decoration: const InputDecoration(
                  labelText: "عدد الأيام المخصص",
                  hintText: "مثال: 45",
                ),
              ),
              const SizedBox(height: 18),
              const _SectionLabel("ابدأ من"),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ModeCard(
                      title: "الموضع الحالي",
                      subtitle: "صفحة ${localizedNumber(context, currentPage)}",
                      selected: _startMode == _KhatmaStartMode.currentPage,
                      onTap: () => setState(
                        () => _startMode = _KhatmaStartMode.currentPage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ModeCard(
                      title: "بداية المصحف",
                      subtitle: "ابدأ من الصفحة الأولى",
                      selected: _startMode == _KhatmaStartMode.beginning,
                      onTap: () => setState(
                        () => _startMode = _KhatmaStartMode.beginning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _SectionLabel("التذكير اليومي"),
              const SizedBox(height: 10),
              _ReminderCard(
                enabled: _reminderEnabled,
                time: _reminderTime,
                onToggle: (value) => setState(() => _reminderEnabled = value),
                onPickTime: _pickReminderTime,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _createPlan,
                  child: Text(
                    "ابدأ الخطة الآن",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildArchiveSection(archive),
      ],
    );
  }

  Widget _buildActiveHero(KhatmaPlanRecord plan, KhatmaStatsSnapshot stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            plan.title,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            "أنجزت ${localizedNumber(context, stats.completedDays)} من أصل ${localizedNumber(context, plan.totalDays)} أيام",
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: stats.progressPercent / 100,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _StatPill(
                label: "التقدم الكلي",
                value: "${stats.progressPercent.toStringAsFixed(0)}%",
              ),
              _StatPill(
                label: "الالتزام",
                value: "${stats.adherencePercent.toStringAsFixed(0)}%",
              ),
              _StatPill(
                label: "السلسلة",
                value: localizedNumber(context, stats.streak),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSelector() {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: _KhatmaSection.values.map((section) {
        return _ChoiceChip(
          label: _sectionLabel(section),
          selected: _section == section,
          onTap: () => setState(() => _section = section),
        );
      }).toList(),
    );
  }

  Widget _buildActiveSection({
    required KhatmaPlanRecord plan,
    required KhatmaStatsSnapshot stats,
    required KhatmaTodaySnapshot today,
    required List<KhatmaArchiveRecord> archive,
  }) {
    switch (_section) {
      case _KhatmaSection.overview:
        return _buildOverviewSection(plan, stats, today);
      case _KhatmaSection.today:
        return _buildTodaySection(plan, today);
      case _KhatmaSection.stats:
        return _buildStatsSection(plan, stats);
      case _KhatmaSection.archive:
        return _buildArchiveSection(archive);
    }
  }

  Widget _buildOverviewSection(
    KhatmaPlanRecord plan,
    KhatmaStatsSnapshot stats,
    KhatmaTodaySnapshot today,
  ) {
    return Column(
      children: <Widget>[
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const _SectionLabel("ملخص الخطة"),
              const SizedBox(height: 12),
              _KeyValueRow(
                label: "بدأت في",
                value: _formatDate(plan.startedAt),
              ),
              _KeyValueRow(
                label: "الانتهاء المتوقع",
                value: _formatDate(stats.expectedCompletionDate),
              ),
              _KeyValueRow(
                label: "تبدأ من الصفحة",
                value: localizedNumber(context, plan.startPage),
              ),
              _KeyValueRow(
                label: "المتبقي من الأيام",
                value: localizedNumber(context, stats.remainingDays),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const _SectionLabel("تذكير الختمة"),
              const SizedBox(height: 10),
              _ReminderCard(
                enabled: plan.reminder.enabled,
                time: TimeOfDay(
                  hour: plan.reminder.hour,
                  minute: plan.reminder.minute,
                ),
                onToggle: (value) =>
                    _updateActiveReminder(plan, enabled: value),
                onPickTime: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: plan.reminder.hour,
                      minute: plan.reminder.minute,
                    ),
                    builder: (context, child) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: child ?? const SizedBox.shrink(),
                      );
                    },
                  );
                  if (picked == null) return;
                  await _updateActiveReminder(plan, time: picked);
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _repository.sendTestNotification,
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text("إرسال إشعار تجريبي"),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const _SectionLabel("الوضع الحالي"),
              const SizedBox(height: 10),
              Text(
                today.hasOverdue
                    ? "لديك ${localizedNumber(context, today.overdueAssignments.length)} أيام متأخرة تحتاج تعويضًا."
                    : "الخطة تسير بدون أيام متأخرة حاليًا.",
                textAlign: TextAlign.right,
                style: TextStyle(
                  height: 1.6,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _repository.cancelActivePlan(),
                      child: const Text("إلغاء الخطة"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () =>
                          setState(() => _section = _KhatmaSection.today),
                      child: const Text("افتح ورد اليوم"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySection(KhatmaPlanRecord plan, KhatmaTodaySnapshot today) {
    final scheduled = today.scheduledAssignment;
    return Column(
      children: <Widget>[
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const _SectionLabel("ورد اليوم"),
              const SizedBox(height: 10),
              if (scheduled != null) ...<Widget>[
                Text(
                  "اليوم ${localizedNumber(context, scheduled.dayNumber)}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "من الصفحة ${localizedNumber(context, scheduled.startPage)} إلى ${localizedNumber(context, scheduled.endPage)}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _StatPill(
                    label: "الورد المجدول",
                    value: localizedNumber(context, today.todayPages),
                  ),
                  _StatPill(
                    label: "المتأخرات",
                    value: localizedNumber(context, today.backlogPages),
                  ),
                  _StatPill(
                    label: "إجمالي الهدف",
                    value: localizedNumber(context, today.combinedTargetPages),
                  ),
                ],
              ),
              if (today.hasOverdue) ...<Widget>[
                const SizedBox(height: 14),
                Text(
                  "أيام تحتاج تعويضًا",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: today.overdueAssignments.map((assignment) {
                    return _StatPill(
                      label:
                          "اليوم ${localizedNumber(context, assignment.dayNumber)}",
                      value:
                          "${localizedNumber(context, assignment.startPage)}-${localizedNumber(context, assignment.endPage)}",
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const _SectionLabel("الإجراءات"),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: today.completedToday
                      ? null
                      : () => _repository.markTodayCompleted(),
                  child: const Text("أكملت ورد اليوم"),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: today.hasOverdue
                          ? () => _repository.completeNextOverdueDay()
                          : null,
                      child: const Text("تعويض يوم فائت"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: scheduled == null || scheduled.isCompleted
                          ? null
                          : () => _repository.deferToday(),
                      child: const Text("تأجيل اليوم"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => _openReadingRange(today),
                  child: const Text("افتح موضع الورد"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(KhatmaPlanRecord plan, KhatmaStatsSnapshot stats) {
    return Column(
      children: <Widget>[
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const _SectionLabel("الإحصائيات"),
              const SizedBox(height: 12),
              _MetricBar(
                label: "التقدم الكلي",
                valueText: "${stats.progressPercent.toStringAsFixed(0)}%",
                progress: stats.progressPercent / 100,
              ),
              const SizedBox(height: 12),
              _MetricBar(
                label: "نسبة الالتزام",
                valueText: "${stats.adherencePercent.toStringAsFixed(0)}%",
                progress: stats.adherencePercent / 100,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SurfaceCard(
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _StatsTile(
                title: "صفحات مقروءة",
                value: localizedNumber(context, stats.pagesRead),
              ),
              _StatsTile(
                title: "صفحات متبقية",
                value: localizedNumber(context, stats.pagesRemaining),
              ),
              _StatsTile(
                title: "متوسط يومي",
                value: stats.averagePagesPerDay.toStringAsFixed(1),
              ),
              _StatsTile(
                title: "أفضل سلسلة",
                value: localizedNumber(context, stats.bestStreak),
              ),
              _StatsTile(title: "البدء", value: _formatDate(plan.startedAt)),
              _StatsTile(
                title: "الانتهاء المتوقع",
                value: _formatDate(stats.expectedCompletionDate),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArchiveSection(List<KhatmaArchiveRecord> archive) {
    if (archive.isEmpty) {
      return const _SurfaceCard(child: _EmptyArchiveState());
    }

    return Column(
      children: archive
          .map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ArchiveCard(record: record),
            ),
          )
          .toList(),
    );
  }

  String _sectionLabel(_KhatmaSection section) {
    switch (section) {
      case _KhatmaSection.overview:
        return "Overview";
      case _KhatmaSection.today:
        return "ورد اليوم";
      case _KhatmaSection.stats:
        return "الإحصائيات";
      case _KhatmaSection.archive:
        return "الأرشيف";
    }
  }

  String _formatDate(DateTime value) {
    return "${localizedNumber(context, value.day)}/${localizedNumber(context, value.month)}/${localizedNumber(context, value.year)}";
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;

  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.28)
                  : colorScheme.outlineVariant.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final bool enabled;
  final TimeOfDay time;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  const _ReminderCard({
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Switch(value: enabled, onChanged: onToggle),
          const Spacer(),
          TextButton(onPressed: onPickTime, child: Text(time.format(context))),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "تذكير يومي",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  "يُستخدم لتذكيرك بوردك اليومي محليًا على الجهاز",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String label;
  final String valueText;
  final double progress;

  const _MetricBar({
    required this.label,
    required this.valueText,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              valueText,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0, 1),
          minHeight: 9,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    );
  }
}

class _StatsTile extends StatelessWidget {
  final String title;
  final String value;

  const _StatsTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 138,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  final KhatmaArchiveRecord record;

  const _ArchiveCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final statusText = record.status == KhatmaArchiveStatus.completed
        ? "مكتملة"
        : "ملغاة";
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: record.status == KhatmaArchiveStatus.completed
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: record.status == KhatmaArchiveStatus.completed
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Expanded(
                child: Text(
                  record.plan.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _StatPill(
                label: "التقدم",
                value: "${record.stats.progressPercent.toStringAsFixed(0)}%",
              ),
              _StatPill(
                label: "أفضل سلسلة",
                value: record.stats.bestStreak.toString(),
              ),
              _StatPill(
                label: "صفحات مقروءة",
                value: record.stats.pagesRead.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyArchiveState extends StatelessWidget {
  const _EmptyArchiveState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(
          Icons.inventory_2_outlined,
          size: 42,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        const Text(
          "لا يوجد أرشيف بعد",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          "عند إنهاء أول خطة أو إلغائها ستظهر هنا كل السجلات السابقة.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _KhatmaMushafPageHolder extends StatelessWidget {
  const _KhatmaMushafPageHolder();

  @override
  Widget build(BuildContext context) {
    final startPage = ModalRoute.of(context)?.settings.arguments as int? ?? 1;
    return Scaffold(
      body: SafeArea(
        child: MushafView(useDefaultAppBar: true, initialPageNumber: startPage),
      ),
    );
  }
}
