import 'dart:async';

import 'package:aura_box/aura_box.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/token.dart';
import '../services/token_service.dart';

class GridHomeScreen extends StatefulWidget {
  const GridHomeScreen({super.key});

  @override
  State<GridHomeScreen> createState() => _GridHomeScreenState();
}

class _GridHomeScreenState extends State<GridHomeScreen> {
  final TokenService _tokenService = TokenService();
  List<Token> _tokens = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  late Timer _refreshTimer;
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final compactCurrencyFormat =
      NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _loadTokens();
    // Set up auto-refresh every 15 seconds
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 15), (_) => _loadTokens());
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _loadTokens() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final tokens = await _tokenService.getTopTokens(
          count: 20); // Increased count for grid view
      if (mounted) {
        setState(() {
          _tokens = tokens;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading data: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTokens,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_tokens.isEmpty) {
      return const Center(child: Text('No tokens available'));
    }

    return RefreshIndicator(
      onRefresh: _loadTokens,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determine number of columns based on screen width
          int crossAxisCount;
          if (constraints.maxWidth < 600) {
            // Mobile: 1-2 columns
            crossAxisCount = constraints.maxWidth < 400 ? 1 : 2;
          } else if (constraints.maxWidth < 900) {
            // Tablet: 3-4 columns
            crossAxisCount = 3;
          } else {
            // Desktop: 5-6 columns
            crossAxisCount = constraints.maxWidth < 1200 ? 5 : 6;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _tokens.length,
            itemBuilder: (context, index) {
              final token = _tokens[index];
              return _buildTokenCard(token);
            },
          );
        },
      ),
    );
  }

  Widget _buildTokenCard(Token token) {
    final isPositiveChange = token.priceChangePercentage24h >= 0;
    final changeColor = isPositiveChange ? Colors.green : Colors.red;
    final changeIcon =
        isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward;

    // Define colors based on token
    List<Color> auraColors = [];

    // Special colors for popular tokens
    if (token.symbol.toLowerCase() == 'btc') {
      // Bitcoin - gold/orange
      auraColors = [Colors.orange[700]!, Colors.amber[600]!];
    } else if (token.symbol.toLowerCase() == 'eth') {
      // Ethereum - blue/purple
      auraColors = [Colors.blue[700]!, Colors.purple[500]!];
    } else if (token.symbol.toLowerCase() == 'sol') {
      // Solana - purple/green
      auraColors = [Colors.purple[600]!, Colors.green[500]!];
    } else if (token.symbol.toLowerCase() == 'bnb') {
      // Binance - yellow/gold
      auraColors = [Colors.yellow[700]!, Colors.amber[500]!];
    } else {
      // Default colors based on price change
      auraColors = isPositiveChange
          ? [Colors.green[700]!, Colors.green[400]!]
          : [Colors.red[700]!, Colors.red[400]!];
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AuraBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        spots: [
          AuraSpot(
            color: auraColors[0],
            radius: 100.0,
            alignment: Alignment.topLeft,
            blurRadius: 60.0,
            stops: const [0.0, 0.7],
          ),
          AuraSpot(
            color: auraColors[1],
            radius: 120.0,
            alignment: Alignment(0.5, 0.7),
            blurRadius: 120.0,
            stops: const [0.0, 0.7],
          ),
        ],
        child: Stack(
          children: [
            // First layer: Token details with padding
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          token.image,
                          width: 32,
                          height: 32,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 32,
                              height: 32,
                              color: Colors.grey[800],
                              child: const Icon(Icons.broken_image, size: 16),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          token.symbol.toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: changeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(changeIcon, color: changeColor, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              '${token.priceChangePercentage24h.toStringAsFixed(1)}%',
                              style: TextStyle(
                                  color: changeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currencyFormat.format(token.currentPrice),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    token.name,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  // Market cap and volume information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem('MCap',
                          compactCurrencyFormat.format(token.marketCap)),
                      _buildInfoItem('Vol',
                          compactCurrencyFormat.format(token.totalVolume)),
                    ],
                  ),
                  // Add space for the chart at the bottom
                  const SizedBox(height: 70),
                ],
              ),
            ),

            // Second layer: Chart without padding, positioned at the bottom
            if (token.sparklineData != null && token.sparklineData!.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 70,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: token.sparklineData!.map((point) {
                            return FlSpot(
                                point[0].toDouble(), point[1].toDouble());
                          }).toList(),
                          isCurved: true,
                          color: isPositiveChange ? Colors.green : Colors.red,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: isPositiveChange
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                          ),
                        ),
                      ],
                      lineTouchData: const LineTouchData(enabled: false),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
