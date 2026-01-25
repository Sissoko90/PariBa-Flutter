import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/support_ticket_model.dart';
import '../../models/faq_model.dart';
import '../../models/guide_model.dart';
import '../../models/support_contact_model.dart';

abstract class SupportRemoteDataSource {
  Future<List<SupportTicketModel>> getMyTickets();
  Future<SupportTicketModel> createTicket(Map<String, dynamic> data);
  Future<SupportTicketModel> getTicketById(String id);
  Future<void> deleteTicket(String id);

  Future<List<FAQModel>> getFAQs();
  Future<List<FAQModel>> getFAQsByCategory(String category);
  Future<FAQModel> getFAQById(String id);

  Future<List<GuideModel>> getGuides();
  Future<List<GuideModel>> getGuidesByCategory(String category);
  Future<GuideModel> getGuideById(String id);

  Future<SupportContactModel> getSupportContact();
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final DioClient dioClient;

  SupportRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<SupportTicketModel>> getMyTickets() async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.baseUrl}/support/tickets',
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => SupportTicketModel.fromJson(json)).toList();
      }

      throw Exception(
        response.data['message'] ??
            'Erreur lors de la récupération des tickets',
      );
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<SupportTicketModel> createTicket(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        '${ApiConstants.baseUrl}/support/tickets',
        data: data,
      );

      if (response.data['success'] == true) {
        return SupportTicketModel.fromJson(response.data['data']);
      }

      throw Exception(
        response.data['message'] ?? 'Erreur lors de la création du ticket',
      );
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<SupportTicketModel> getTicketById(String id) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.baseUrl}/support/tickets/$id',
      );

      if (response.data['success'] == true) {
        return SupportTicketModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Ticket non trouvé');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<void> deleteTicket(String id) async {
    try {
      final response = await dioClient.delete(
        '${ApiConstants.baseUrl}/support/tickets/$id',
      );

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Erreur lors de la suppression',
        );
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<List<FAQModel>> getFAQs() async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.baseUrl}/support/faqs',
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => FAQModel.fromJson(json)).toList();
      }

      throw Exception(
        response.data['message'] ?? 'Erreur lors de la récupération des FAQs',
      );
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<List<FAQModel>> getFAQsByCategory(String category) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.baseUrl}/support/faqs/category/$category',
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => FAQModel.fromJson(json)).toList();
      }

      throw Exception(
        response.data['message'] ?? 'Erreur lors de la récupération des FAQs',
      );
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<FAQModel> getFAQById(String id) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.baseUrl}/support/faqs/$id',
      );

      if (response.data['success'] == true) {
        return FAQModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'FAQ non trouvée');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<List<GuideModel>> getGuides() async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.baseUrl}/support/guides',
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => GuideModel.fromJson(json)).toList();
      }

      throw Exception(
        response.data['message'] ?? 'Erreur lors de la récupération des guides',
      );
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<List<GuideModel>> getGuidesByCategory(String category) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.baseUrl}/support/guides/category/$category',
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => GuideModel.fromJson(json)).toList();
      }

      throw Exception(
        response.data['message'] ?? 'Erreur lors de la récupération des guides',
      );
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<GuideModel> getGuideById(String id) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.baseUrl}/support/guides/$id',
      );

      if (response.data['success'] == true) {
        return GuideModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Guide non trouvé');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<SupportContactModel> getSupportContact() async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.baseUrl}/support/contact',
      );

      if (response.data['success'] == true) {
        return SupportContactModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Contact non trouvé');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
