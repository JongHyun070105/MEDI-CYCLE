import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _medicationReminderEnabled = true;
  bool _expirationAlertEnabled = true;
  bool _allNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _medicationReminderEnabled =
          prefs.getBool('notification_medication_reminder') ?? true;
      _expirationAlertEnabled =
          prefs.getBool('notification_expiration_alert') ?? true;
      _allNotificationsEnabled =
          prefs.getBool('notification_all_enabled') ?? true;
    });
  }

  Future<void> _saveNotificationSettings(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _toggleMedicationReminder(bool value) async {
    setState(() {
      _medicationReminderEnabled = value;
    });
    await _saveNotificationSettings('notification_medication_reminder', value);
  }

  Future<void> _toggleExpirationAlert(bool value) async {
    setState(() {
      _expirationAlertEnabled = value;
    });
    await _saveNotificationSettings('notification_expiration_alert', value);
  }

  Future<void> _toggleAllNotifications(bool value) async {
    setState(() {
      _allNotificationsEnabled = value;
      if (!value) {
        _medicationReminderEnabled = false;
        _expirationAlertEnabled = false;
        _saveNotificationSettings('notification_medication_reminder', false);
        _saveNotificationSettings('notification_expiration_alert', false);
      } else {
        _medicationReminderEnabled = true;
        _expirationAlertEnabled = true;
        _saveNotificationSettings('notification_medication_reminder', true);
        _saveNotificationSettings('notification_expiration_alert', true);
      }
    });
    await _saveNotificationSettings('notification_all_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: AppSizes.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: AppColors.primary,
                          size: AppSizes.iconMd,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          '알림 설정',
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
                    _buildNotificationSwitch(
                      title: '전체 알림',
                      subtitle: '모든 알림을 한번에 켜거나 끌 수 있습니다',
                      value: _allNotificationsEnabled,
                      onChanged: _toggleAllNotifications,
                      isMain: true,
                    ),
                    const Divider(height: AppSizes.xl),
                    _buildNotificationSwitch(
                      title: '복용 알림',
                      subtitle: '약 복용 시간에 알림을 받습니다',
                      value: _medicationReminderEnabled,
                      onChanged: _toggleMedicationReminder,
                      enabled: _allNotificationsEnabled,
                    ),
                    const SizedBox(height: AppSizes.md),
                    _buildNotificationSwitch(
                      title: '만료 알림',
                      subtitle: '약물 만료일이 가까워지면 알림을 받습니다',
                      value: _expirationAlertEnabled,
                      onChanged: _toggleExpirationAlert,
                      enabled: _allNotificationsEnabled,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: AppSizes.iconSm,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      '알림을 끄면 복용 시간을 놓칠 수 있습니다.\n설정에서 앱 알림 권한을 확인해주세요.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
    bool isMain = false,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: isMain ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      value: enabled ? value : false,
      onChanged: enabled
          ? (newValue) => onChanged(newValue)
          : null,
      activeColor: AppColors.primary,
      secondary: Icon(
        isMain ? Icons.notifications_active : Icons.notifications_outlined,
        color: enabled && value
            ? AppColors.primary
            : AppColors.textSecondary,
      ),
    );
  }
}

