import 'package:flutter/material.dart';
import 'package:flutter_application_1/application/core/serveice/dio_client.dart';
import 'package:flutter_application_1/application/core/serveice/local_db_serveice.dart';
import 'package:flutter_application_1/application/core/theme/colors.dart';
import 'package:flutter_application_1/application/core/theme/theme/theme_cubit.dart';
import 'package:flutter_application_1/application/core/utils/alert_dialog.dart';
import 'package:flutter_application_1/application/core/utils/enums.dart';
import 'package:flutter_application_1/domain/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:gap/gap.dart';

class AppRoot extends StatelessWidget {
  static const String routeName = 'app-root';

  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Base App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final isCurrentlyDark = state.themeMode == AppThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isCurrentlyDark ? Icons.light_mode : Icons.dark_mode,
                  color: isCurrentlyDark ? ColorResources.lemonYellow : ColorResources.darkBlue,
                ),
                tooltip: isCurrentlyDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  context.read<ThemeCubit>().changeTheme(
                        isCurrentlyDark ? AppThemeMode.light : AppThemeMode.dark,
                      );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242731) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorResources.roseRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: ColorResources.roseRed,
                          size: 24,
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Base Architecture Ready',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : ColorResources.pureBlack,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              'BLoC Core + Interceptors + Injectable DI',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : ColorResources.slateGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(18),

            // Ready Modules Overview
            Text(
              'Common Core Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : ColorResources.pureBlack,
              ),
            ),
            const Gap(12),

            _serviceCard(
              icon: Icons.palette_outlined,
              title: 'Theme & ThemeCubit',
              subtitle: 'Reactive Material 3 light/dark mode state management via ThemeCubit',
              isDark: isDark,
              statusText: sl.isRegistered<ThemeCubit>() ? 'Active' : 'Not Loaded',
              statusColor: ColorResources.oceanBlue,
            ),
            const Gap(10),

            _serviceCard(
              icon: Icons.http,
              title: 'DioClient & 5 Interceptors',
              subtitle: 'Connectivity, Auth (Bearer token), Logging, Error (401 handler), & Pretty Logger',
              isDark: isDark,
              statusText: sl.isRegistered<DioClient>() ? 'Active' : 'Not Loaded',
              statusColor: ColorResources.mintGreen,
            ),
            const Gap(10),

            _serviceCard(
              icon: Icons.storage,
              title: 'LocalDbService',
              subtitle: 'SharedPreferences backed auth token, refresh token, user & theme persistence',
              isDark: isDark,
              statusText: sl.isRegistered<LocalDbService>() ? 'Active' : 'Not Loaded',
              statusColor: ColorResources.mintGreen,
            ),
            const Gap(10),

            _serviceCard(
              icon: Icons.shield_outlined,
              title: 'RunSafely & MainFailure',
              subtitle: 'Functional error handling wrapping API calls into Either<MainFailure, T>',
              isDark: isDark,
              statusText: 'Configured',
              statusColor: ColorResources.amber,
            ),
            const Gap(24),

            // Interactive Test Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorResources.roseRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                CustomAlertDialog.showCustomDialog(
                  title: 'Core Services Active',
                  subtitle: 'Theme, Dio interceptors, LocalDb, and DI are operational.',
                  typeAlert: TypeAlert.success,
                );
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Test Notification & Dropdown Alert'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242731) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: statusColor),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : ColorResources.pureBlack,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : ColorResources.slateGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
