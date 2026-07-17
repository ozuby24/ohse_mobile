import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/labels.dart';
import '../core/theme.dart';
import '../models/dashboard_stats.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import 'incidents/incident_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: async.when(
            loading: () => const LoadingView(),
            error: (e, _) => ListView(
              children: [
                const SizedBox(height: 200),
                ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(dashboardProvider),
                ),
              ],
            ),
            data: (stats) => _DashboardBody(stats: stats, userName: user?.name),
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats, this.userName});

  final DashboardStats stats;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Text('Halo,',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
        Text(
          userName ?? 'Petugas HSSE',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // KPI grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _StatCard(
              label: 'Insiden Terbuka',
              value: '${stats.incidentsOpen}',
              sub: 'dari ${stats.incidentsTotal} total',
              icon: Icons.report,
              color: AppColors.high,
            ),
            _StatCard(
              label: 'PTW Aktif',
              value: '${stats.permitsActive}',
              sub: '${stats.permitsPending} menunggu',
              icon: Icons.assignment_turned_in,
              color: AppColors.primary,
            ),
            _StatCard(
              label: 'Inspeksi',
              value: '${stats.inspectionsCompleted}/${stats.inspectionsTotal}',
              sub: 'skor rata² ${stats.inspectionsAvgScore}',
              icon: Icons.fact_check,
              color: AppColors.info,
            ),
            _StatCard(
              label: 'Observasi Terbuka',
              value: '${stats.observationsOpen}',
              sub: 'dari ${stats.observationsTotal} total',
              icon: Icons.visibility,
              color: AppColors.accent,
            ),
          ],
        ),
        const SizedBox(height: 20),

        _SectionCard(
          title: 'Insiden per Tingkat Keparahan',
          child: SizedBox(
            height: 180,
            child: _SeverityChart(data: stats.incidentsBySeverity),
          ),
        ),
        const SizedBox(height: 16),

        _SectionCard(
          title: 'Insiden Terbaru',
          child: Column(
            children: [
              if (stats.recentIncidents.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyView(message: 'Belum ada insiden'),
                )
              else
                ...stats.recentIncidents.map(
                  (inc) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          Labels.severityColor(inc.severity).withValues(alpha: 0.15),
                      child: Icon(Icons.warning_amber_rounded,
                          color: Labels.severityColor(inc.severity)),
                    ),
                    title: Text(inc.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(inc.incidentNumber),
                    trailing: TagChip(
                      label: Labels.of(Labels.severity, inc.severity),
                      color: Labels.severityColor(inc.severity),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IncidentDetailScreen(incidentId: inc.id),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
              ],
            ),
            const Spacer(),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Text(sub,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SeverityChart extends StatelessWidget {
  const _SeverityChart({required this.data});

  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    const order = ['low', 'medium', 'high', 'critical'];
    final maxVal = (data.values.isEmpty
            ? 0
            : data.values.reduce((a, b) => a > b ? a : b))
        .toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal == 0 ? 1 : maxVal + 1,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= order.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    Labels.of(Labels.severity, order[i]),
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < order.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (data[order[i]] ?? 0).toDouble(),
                  color: Labels.severityColor(order[i]),
                  width: 26,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Shared date formatter helper.
String formatDate(DateTime? dt, {bool withTime = false}) {
  if (dt == null) return '-';
  final pattern = withTime ? 'd MMM yyyy, HH:mm' : 'd MMM yyyy';
  return DateFormat(pattern, 'id_ID').format(dt.toLocal());
}
