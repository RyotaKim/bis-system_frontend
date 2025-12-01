import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic> _dashboardData = {};

  @override
  void initState() {
    super.initState();
    print('🚀 Dashboard initState called');
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    print('=== FETCHING DASHBOARD DATA ===');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('API Endpoint: ${ApiConfig.dashboardEndpoint}');
      print('Full URL: ${ApiConfig.baseUrl}${ApiConfig.dashboardEndpoint}');
      final data = await _apiService.get(ApiConfig.dashboardEndpoint);
      print('Dashboard API Response: $data');
      print('Total Requests: ${data['totalRequests']}');
      print('Pending Requests: ${data['pendingRequests']}');
      print('Total Complaints: ${data['totalComplaints']}');
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
      print('Dashboard data set successfully');
    } catch (e) {
      print('Dashboard API Error: $e');
      print('Error type: ${e.runtimeType}');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading dashboard data...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchDashboardData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overview',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _infoCard(
                            'Total Requests',
                            (_dashboardData['totalRequests'] ?? 0).toString(),
                            Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _infoCard(
                            'Pending Requests',
                            (_dashboardData['pendingRequests'] ?? 0).toString(),
                            Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          _infoCard(
                            'Approved',
                            (_dashboardData['approvedRequests'] ?? 0)
                                .toString(),
                            Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _infoCard(
                            'Total Complaints',
                            (_dashboardData['totalComplaints'] ?? 0).toString(),
                            Colors.purple,
                          ),
                          const SizedBox(width: 12),
                          _infoCard(
                            'Resolved Complaints',
                            (_dashboardData['resolvedComplaints'] ?? 0)
                                .toString(),
                            Colors.teal,
                          ),
                          const SizedBox(width: 12),
                          _infoCard(
                            'Rejected',
                            (_dashboardData['rejectedRequests'] ?? 0)
                                .toString(),
                            Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Request Analytics',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Request Status',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Expanded(
                                                child: _buildRequestBarChart()),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Request Distribution',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Expanded(
                                                child: _buildRequestPieChart()),
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
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Complaint Status',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Expanded(
                                                child:
                                                    _buildComplaintBarChart()),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Complaint Distribution',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Expanded(
                                                child:
                                                    _buildComplaintPieChart()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

  Widget _infoCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
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
      ),
    );
  }

  Widget _buildRequestBarChart() {
    final pending = (_dashboardData['pendingRequests'] ?? 0).toDouble();
    final approved = (_dashboardData['approvedRequests'] ?? 0).toDouble();
    final rejected = (_dashboardData['rejectedRequests'] ?? 0).toDouble();
    final maxValue =
        [pending, approved, rejected].reduce((a, b) => a > b ? a : b);
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
                const labels = ['Pending', 'Approved', 'Rejected'];
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[idx],
                      style: const TextStyle(fontSize: 10),
                    ),
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
            barRods: [BarChartRodData(toY: approved, color: Colors.green)],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: rejected, color: Colors.red)],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestPieChart() {
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
              title: '${(pending / total * 100).toStringAsFixed(1)}%',
              color: Colors.orange,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (approved > 0)
            PieChartSectionData(
              value: approved,
              title: '${(approved / total * 100).toStringAsFixed(1)}%',
              color: Colors.green,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (rejected > 0)
            PieChartSectionData(
              value: rejected,
              title: '${(rejected / total * 100).toStringAsFixed(1)}%',
              color: Colors.red,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
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
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[idx],
                      style: const TextStyle(fontSize: 10),
                    ),
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
              title: '${(pending / total * 100).toStringAsFixed(1)}%',
              color: Colors.orange,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (resolved > 0)
            PieChartSectionData(
              value: resolved,
              title: '${(resolved / total * 100).toStringAsFixed(1)}%',
              color: Colors.green,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
