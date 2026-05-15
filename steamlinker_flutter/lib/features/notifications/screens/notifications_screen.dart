import 'package:flutter/material.dart';
import '../../../models/notification_model.dart';
import '../../../theme/colors.dart';
import '../../../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _filters = ['Todas', 'No leídas', 'Interesantes'];

  // Lista local mutable
  final List<NotificationModel> _notifs =
      List.from(sampleNotifications);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filters.length, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String get _currentFilter => _filters[_tabs.index];

  List<NotificationModel> get _filtered {
    switch (_currentFilter) {
      case 'No leídas':
        return _notifs.where((n) => !n.isRead).toList();
      case 'Interesantes':
        return _notifs.where((n) => n.interested == true).toList();
      default:
        return _notifs;
    }
  }

  int get _unreadCount => _notifs.where((n) => !n.isRead).length;
  int get _interestingCount =>
      _notifs.where((n) => n.interested == true).length;

  void _markAllRead() => setState(() {
        for (final n in _notifs) {
          n.isRead = true;
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SteamColors.bgDeep,
      appBar: AppBar(
        backgroundColor: SteamColors.bgPanel,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: SteamColors.border),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: SteamColors.blue, width: 1.5),
            ),
            child: const Icon(Icons.sports_esports,
                size: 16, color: SteamColors.blue),
          ),
        ),
        title: Row(children: [
          const Text(
            'NOTIFICACIONES',
            style: TextStyle(
              color: SteamColors.light,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: SteamColors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ]),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Todo leído',
                style: TextStyle(
                  color: SteamColors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Column(children: [
        // ── Tabs de filtro ───────────────────────────────────────────
        Container(
          color: SteamColors.bgPanel,
          child: TabBar(
            controller: _tabs,
            indicatorColor: SteamColors.blue,
            indicatorWeight: 2,
            labelColor: SteamColors.blue,
            unselectedLabelColor: SteamColors.muted,
            labelStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6),
            tabs: [
              _buildTab('Todas', 0),
              _buildTab('No leídas', _unreadCount,
                  badgeColor: SteamColors.red),
              _buildTab('Interesantes', _interestingCount),
            ],
          ),
        ),

        // ── Lista ────────────────────────────────────────────────────
        Expanded(
          child: _filtered.isEmpty
              ? _EmptyState(filter: _currentFilter)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: SteamColors.border,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (ctx, i) {
                    final n = _filtered[i];
                    return NotificationTile(
                      notif: n,
                      onChanged: () => setState(() {}),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Tab _buildTab(String label, int count,
      {Color badgeColor = SteamColors.blue}) {
    return Tab(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 5),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

// ── Estado vacío ─────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isInteresting = filter == 'Interesantes';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            isInteresting
                ? Icons.thumb_up_outlined
                : Icons.notifications_off_outlined,
            size: 56,
            color: SteamColors.muted.withOpacity(0.35),
          ),
          const SizedBox(height: 16),
          Text(
            isInteresting ? 'Sin notificaciones marcadas' : 'Todo al día',
            style: const TextStyle(
              color: SteamColors.light,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isInteresting
                ? 'Usa los ⋮ para marcar lo que te interesa'
                : 'No tienes notificaciones nuevas',
            style: const TextStyle(
                color: SteamColors.textSec, fontSize: 12.5),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}
