import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/advertisement_model.dart';

abstract class AdvertisementRemoteDataSource {
  Future<List<AdvertisementModel>> getAdvertisements(String placement);
  Future<List<AdvertisementModel>> getActiveAdvertisements();
  Future<List<AdvertisementModel>> getAllAdvertisements();
  Future<void> recordImpression(String adId);
  Future<void> recordClick(String adId);
}

class AdvertisementRemoteDataSourceImpl
    implements AdvertisementRemoteDataSource {
  final DioClient dioClient;

  AdvertisementRemoteDataSourceImpl(this.dioClient);

  /// Corrige temporairement les URLs localhost (pour les anciennes publicités)
  /// TODO: Supprimer cette fonction une fois toutes les publicités recréées
  Map<String, dynamic> _fixImageUrl(Map<String, dynamic> json) {
    if (json['imageUrl'] != null &&
        json['imageUrl'].toString().contains('localhost')) {
      // Extraire le domaine de base du DioClient
      final baseUrl = dioClient.dio.options.baseUrl;
      final uri = Uri.parse(baseUrl);
      final serverUrl = '${uri.scheme}://${uri.host}:${uri.port}';

      // Remplacer localhost par le domaine configuré
      final originalUrl = json['imageUrl'].toString();
      json['imageUrl'] = originalUrl.replaceAll(
        RegExp(r'http://localhost:\d+'),
        serverUrl,
      );
      print('🔧 [ADS] URL corrigée: ${originalUrl} → ${json['imageUrl']}');
    }
    return json;
  }

  @override
  Future<List<AdvertisementModel>> getAdvertisements(String placement) async {
    try {
      print('🔍 [ADS] Récupération des publicités pour placement: $placement');

      final response = await dioClient.get(
        '/advertisements',
        queryParameters: {'placement': placement},
      );

      print('📡 [ADS] Response status: ${response.statusCode}');
      print('📦 [ADS] Response data: ${response.data}');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        print('✅ [ADS] ${data.length} publicités trouvées');

        // Corriger les URLs localhost temporairement
        final correctedData = data.map((json) => _fixImageUrl(json)).toList();

        final ads = correctedData
            .map((json) => AdvertisementModel.fromJson(json))
            .toList();
        return ads;
      } else {
        print('❌ [ADS] Erreur: ${response.data['message']}');
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      print('❌ [ADS] DioException: ${e.message}');
      print('❌ [ADS] Response: ${e.response?.data}');
      throw Exception('Erreur de récupération des publicités: ${e.message}');
    } catch (e) {
      print('❌ [ADS] Exception: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdvertisementModel>> getActiveAdvertisements() async {
    try {
      final response = await dioClient.get('/advertisements');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AdvertisementModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des publicités: ${e.message}');
    }
  }

  @override
  Future<List<AdvertisementModel>> getAllAdvertisements() async {
    return getActiveAdvertisements();
  }

  @override
  Future<void> recordImpression(String adId) async {
    try {
      await dioClient.post('/advertisements/$adId/impression');
    } on DioException catch (e) {
      throw Exception(
        'Erreur d\'enregistrement de l\'impression: ${e.message}',
      );
    }
  }

  @override
  Future<void> recordClick(String adId) async {
    try {
      await dioClient.post('/advertisements/$adId/click');
    } on DioException catch (e) {
      throw Exception('Erreur d\'enregistrement du clic: ${e.message}');
    }
  }
}
