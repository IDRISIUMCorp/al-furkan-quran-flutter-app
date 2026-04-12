import "dart:developer";

import "package:al_quran_v3/l10n/app_localizations.dart";
import "package:al_quran_v3/main.dart";
import "package:al_quran_v3/src/platform_services.dart";
import "package:al_quran_v3/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:al_quran_v3/src/screen/location_handler/manual_selection/address_selection.dart";
import "package:al_quran_v3/src/screen/location_handler/manual_selection/cubit/manual_location_selection_cubit.dart";
import "package:al_quran_v3/src/screen/location_handler/model/lat_lon.dart";
import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:gap/gap.dart";
import "package:geolocator/geolocator.dart";

class LocationAcquire extends StatefulWidget {
  final bool backToPage;

  const LocationAcquire({super.key, this.backToPage = false});

  @override
  State<LocationAcquire> createState() => _LocationAcquireState();
}

class _LocationAcquireState extends State<LocationAcquire> {
  bool isGPSLocationLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: widget.backToPage ? AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ) : null,
      backgroundColor: isDark ? const Color(0xFF111111) : const Color(0xFFF9F6F0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: themeState.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mosque_rounded,
                      size: 80,
                      color: themeState.primary,
                    ),
                  ),
                  const Gap(32),
                  Text(
                    "مواقيت الصلاة واتجاه القبلة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    "لتجربة متكاملة، يرجى تزويدنا بموقعك الجغرافي. سنقوم بحساب أوقات الصلاة بدقة فائقة وتحديد اتجاه القبلة لمكانك الحالي.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const Gap(40),
                  
                  if (!(platformOwn == PlatformOwn.isLinux))
                    FilledButton.icon(
                      onPressed: () async {
                        setState(() => isGPSLocationLoading = true);
                        try {
                          bool isServiceAvailable = await Geolocator.isLocationServiceEnabled();
                          if (!isServiceAvailable) {
                            Fluttertoast.showToast(msg: l10n.pleaseEnableLocationService);
                            await Geolocator.openLocationSettings();
                          }
                          LocationPermission permission = await Geolocator.checkPermission();
                          if (!(permission == LocationPermission.whileInUse || permission == LocationPermission.always)) {
                            permission = await Geolocator.requestPermission();
                          }
                          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                            Position position = await Geolocator.getCurrentPosition();
                            if (!mounted) return;
                            context.read<LocationQiblaPrayerDataCubit>().saveLocationData(
                              LatLon(latitude: position.latitude, longitude: position.longitude),
                              save: !widget.backToPage,
                            );
                            if (widget.backToPage) Navigator.pop(context);
                          }
                        } catch (e) {
                          log(e.toString());
                        } finally {
                          if (mounted) setState(() => isGPSLocationLoading = false);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: themeState.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: isGPSLocationLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.my_location_rounded),
                      label: Text(
                        "تحديد الموقع تلقائياً",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                  if (!(platformOwn == PlatformOwn.isLinux)) ...[
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "أو",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
                      ],
                    ),
                    const Gap(16),
                  ],

                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => ManualLocationSelectionCubit(),
                            child: AddressSelection(backToPage: widget.backToPage),
                          ),
                        ),
                      );
                      if (widget.backToPage && mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeState.primary,
                      side: BorderSide(color: themeState.primary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.location_city_rounded),
                    label: Text(
                      "اختيار المدينة يدوياً",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  const Gap(32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: themeState.primary, size: 20),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            "نحتاج للموقع فقط لحساب المواقيت واتجاه القبلة، ولا يتم مشاركته مع أي جهة خارجية.",
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
