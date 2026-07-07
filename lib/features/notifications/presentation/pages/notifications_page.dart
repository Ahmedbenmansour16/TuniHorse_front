import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/notifications/data/notifications_api_client.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notification_preferences_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationsApiClient = NotificationsApiClient();

  bool _isLoading = true;
  String? _error;
  List<AppNotificationInfo> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _notificationsApiClient.close();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _notificationsApiClient.getNotifications();
      if (!mounted) return;
      setState(() => _notifications = notifications);
    } on NotificationsApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les notifications.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openNotification(AppNotificationInfo notification) async {
    if (notification.isTeamInvitation &&
        notification.invitationStatus == 'PENDING') {
      await _showInvitationDialog(notification);
      return;
    }

    await _notificationsApiClient.markAsRead(notification.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
    _loadNotifications();
  }

  Future<void> _showInvitationDialog(AppNotificationInfo notification) async {
    final teamName = notification.metadata['teamName']?.toString() ?? 'Equipe';
    final code = notification.metadata['codeInvitation']?.toString() ?? '--';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('Invitation - $teamName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 14),
            InfoLine(icon: Icons.key, label: 'Code equipe', value: code),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _respondInvitation(
              dialogContext,
              notification,
              'REFUSED',
            ),
            child: const Text('Refuser'),
          ),
          FilledButton(
            onPressed: () => _respondInvitation(
              dialogContext,
              notification,
              'ACCEPTED',
            ),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }

  Future<void> _respondInvitation(
    BuildContext dialogContext,
    AppNotificationInfo notification,
    String decision,
  ) async {
    try {
      await _notificationsApiClient.respondTeamInvitation(
        notificationId: notification.id,
        decision: decision,
      );

      if (!mounted) return;
      Navigator.of(dialogContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decision == 'ACCEPTED'
                ? 'Invitation acceptee. Vous etes associe a l equipe.'
                : 'Invitation refusee.',
          ),
        ),
      );
      _loadNotifications();
    } on NotificationsApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Notifications',
      showBack: true,
      actions: [
        IconButton(
          onPressed: () => openPage(context, const NotificationPreferencesPage()),
          icon: const Icon(Icons.tune),
        ),
      ],
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            StatusPill('Toutes'),
            StatusPill('Non lues', color: AppColors.gold),
            StatusPill('Invitations', color: AppColors.green),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const TuniCard(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          TuniCard(
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Reessayer',
                  onPressed: _loadNotifications,
                ),
              ],
            ),
          )
        else if (_notifications.isEmpty)
          const TuniCard(
            child: Text(
              'Aucune notification.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          )
        else
          ..._notifications.map(
            (item) => _NotificationTile(
              item: item,
              onTap: () => _openNotification(item),
            ),
          ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationInfo item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  Color get _color {
    if (item.isTeamInvitation) return AppColors.green;
    if (item.type == 'COURSE_SELECTION') return AppColors.gold;
    return AppColors.muted;
  }

  IconData get _icon {
    if (item.isTeamInvitation) return Icons.groups_outlined;
    if (item.type == 'COURSE_SELECTION') return Icons.emoji_events_outlined;
    return Icons.notifications_outlined;
  }

  String get _time {
    final createdAt = item.createdAt;
    if (createdAt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Maintenant';
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inDays < 1) return '${diff.inHours} h';
    return '${diff.inDays} j';
  }

  String get _statusLabel {
    if (!item.isTeamInvitation) return item.read ? 'Lu' : 'Non lu';
    final status = item.invitationStatus;
    if (status == 'ACCEPTED') return 'Acceptee';
    if (status == 'REFUSED') return 'Refusee';
    return 'En attente';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TuniCard(
        onTap: onTap,
        color: item.read ? AppColors.card : AppColors.greenSoft,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _color.withValues(alpha: 0.12),
              child: Icon(_icon, color: _color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      StatusPill(_statusLabel, color: _color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _time,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
