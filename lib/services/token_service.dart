import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/token.dart';

class TokenService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';
  static const String cacheKey = 'cached_tokens';
  static const Duration cacheExpiration = Duration(minutes: 5);
  
  // Get top tokens by market cap
  Future<List<Token>> getTopTokens({int count = 10}) async {
    try {
      // Try to get cached data first
      final cachedData = await _getCachedTokens();
      if (cachedData != null) {
        return cachedData;
      }
      
      // If no cache, fetch from API
      final response = await http.get(Uri.parse(
        '$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$count&page=1&sparkline=true&price_change_percentage=24h'
      ));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final tokens = data.map((json) => Token.fromJson(json)).toList();
        
        // Cache the result
        _cacheTokens(tokens);
        
        return tokens;
      } else {
        throw Exception('Failed to load tokens: ${response.statusCode}');
      }
    } catch (e) {
      // If API fails, try to return cached data even if expired
      final cachedData = await _getCachedTokens(ignoreExpiration: true);
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('Failed to load tokens: $e');
    }
  }
  
  // Cache tokens data
  Future<void> _cacheTokens(List<Token> tokens) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenMaps = tokens.map((token) => {
        'id': token.id,
        'symbol': token.symbol,
        'name': token.name,
        'image': token.image,
        'current_price': token.currentPrice,
        'price_change_percentage_24h': token.priceChangePercentage24h,
        'market_cap': token.marketCap,
        'total_volume': token.totalVolume,
        'sparkline_in_7d': token.sparklineData != null ? {
          'price': token.sparklineData!.map((point) => point[1]).toList()
        } : null,
        'cache_timestamp': DateTime.now().millisecondsSinceEpoch,
      }).toList();
      
      await prefs.setString(cacheKey, json.encode(tokenMaps));
    } catch (e) {
      print('Error caching tokens: $e');
    }
  }
  
  // Get cached tokens
  Future<List<Token>?> _getCachedTokens({bool ignoreExpiration = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(cacheKey);
      
      if (cachedString == null) {
        return null;
      }
      
      final List<dynamic> cachedData = json.decode(cachedString);
      
      // Check cache expiration
      if (!ignoreExpiration) {
        final cacheTimestamp = cachedData.first['cache_timestamp'] as int;
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimestamp;
        
        if (cacheAge > cacheExpiration.inMilliseconds) {
          return null; // Cache expired
        }
      }
      
      return cachedData.map((data) => Token.fromJson(data)).toList();
    } catch (e) {
      print('Error getting cached tokens: $e');
      return null;
    }
  }
}