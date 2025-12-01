import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ReportsAnalyticsPage extends StatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  State<ReportsAnalyticsPage> createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> {
  final _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic> _dashboardData = {};
  List<dynamic> _weeklyRequests = [];

  @override
  void initState() {
    super.initState();
    print('🚀 Reports & Analytics initState called');
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    print('=== FETCHING ANALYTICS DATA ===');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch dashboard stats first
      final dashboardData = await _apiService.get(ApiConfig.dashboardEndpoint);
      print('Dashboard Data: $dashboardData');

      // Try to fetch weekly requests, but don't fail if it errors
      List<dynamic> weeklyData = [];
      try {
        final weeklyResult =
            await _apiService.get(ApiConfig.weeklyRequestsEndpoint);
        print('Weekly Requests: $weeklyResult');
        weeklyData = weeklyResult['requestStats'] ?? [];
      } catch (weeklyError) {
        print('Weekly requests error (continuing anyway): $weeklyError');
        // Continue without weekly data
      }

      setState(() {
        _dashboardData = dashboardData;
        _weeklyRequests = weeklyData;
        _isLoading = false;
      });
      print('Analytics data loaded successfully');
    } catch (e) {
      print('Analytics API Error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading analytics data...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAnalyticsData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Reports & Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchAnalyticsData,
              tooltip: 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Total Requests',
                (_dashboardData['totalRequests'] ?? 0).toString(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Pending Requests',
                (_dashboardData['pendingRequests'] ?? 0).toString(),
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Total Complaints',
                (_dashboardData['totalComplaints'] ?? 0).toString(),
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Resolved Complaints',
                (_dashboardData['resolvedComplaints'] ?? 0).toString(),
                Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Request Analytics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weekly Requests',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(child: _buildWeeklyRequestsChart()),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Request Status',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(child: _buildRequestStatusChart()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('Complaint Analytics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Complaint Status',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(child: _buildComplaintBarChart()),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Complaint Distribution',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(child: _buildComplaintPieChart()),
                      ],
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

  Widget _statCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRequestsChart() {
    if (_weeklyRequests.isEmpty) {
      return const Center(
        child:
            Text('No request data available', style: TextStyle(fontSize: 14)),
      );
    }

    // Group data by date and sum counts
    final Map<String, int> dailyCounts = {};
    for (var stat in _weeklyRequests) {
      final date = stat['_id']?['date'] ?? 'Unknown';
      final count = (stat['count'] ?? 0) as int;
      dailyCounts[date] = (dailyCounts[date] ?? 0) + count;
    }

    final sortedDates = dailyCounts.keys.toList()..sort();
    final maxValue = dailyCounts.values.isEmpty
        ? 10.0
        : dailyCounts.values.reduce((a, b) => a > b ? a : b).toDouble();
    final chartMaxY = maxValue > 0 ? maxValue * 1.2 : 10.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < sortedDates.length) {
                  // Show last 2 digits of date (e.g., "25" from "2025-11-25")
                  final date = sortedDates[idx];
                  final day = date.split('-').last;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(day, style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          sortedDates.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: dailyCounts[sortedDates[index]]!.toDouble(),
                color: Colors.blue,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestStatusChart() {
    final pending = (_dashboardData['pendingRequests'] ?? 0).toDouble();
    final approved = (_dashboardData['approvedRequests'] ?? 0).toDouble();
    final rejected = (_dashboardData['rejectedRequests'] ?? 0).toDouble();
    final total = pending + approved + rejected;

    if (total == 0) {
      return const Center(
        child: Text('No data available', style: TextStyle(fontSize: 14)),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          if (pending > 0)
            PieChartSectionData(
              value: pending,
              title: 'Pending\n${(pending / total * 100).toStringAsFixed(1)}%',
              color: Colors.orange,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (approved > 0)
            PieChartSectionData(
              value: approved,
              title:
                  'Approved\n${(approved / total * 100).toStringAsFixed(1)}%',
              color: Colors.green,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (rejected > 0)
            PieChartSectionData(
              value: rejected,
              title:
                  'Rejected\n${(rejected / total * 100).toStringAsFixed(1)}%',
              color: Colors.red,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComplaintBarChart() {
    final total = (_dashboardData['totalComplaints'] ?? 0).toDouble();
    final resolved = (_dashboardData['resolvedComplaints'] ?? 0).toDouble();
    final pending = total - resolved;
    final maxValue = [pending, resolved].reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxValue > 0 ? maxValue * 1.2 : 10.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Pending', 'Resolved'];
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child:
                        Text(labels[idx], style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: pending, color: Colors.orange)],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: resolved, color: Colors.green)],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintPieChart() {
    final total = (_dashboardData['totalComplaints'] ?? 0).toDouble();
    final resolved = (_dashboardData['resolvedComplaints'] ?? 0).toDouble();
    final pending = total - resolved;

    if (total == 0) {
      return const Center(
        child: Text('No data available', style: TextStyle(fontSize: 14)),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          if (pending > 0)
            PieChartSectionData(
              value: pending,
              title: 'Pending\\n${(pending / total * 100).toStringAsFixed(1)}%',
              color: Colors.orange,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (resolved > 0)
            PieChartSectionData(
              value: resolved,
              title:
                  'Resolved\\n${(resolved / total * 100).toStringAsFixed(1)}%',
              color: Colors.green,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
