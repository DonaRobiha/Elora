import 'supabase_service.dart';

class EloraAiService {
  EloraAiService._();

  static final EloraAiService instance = EloraAiService._();

  Future<String> reply(List<Map<String, String>> messages) async {
    final response = await SupabaseService.client.functions.invoke(
      'elora-ai',
      body: {'mode': 'chat', 'messages': messages},
    );
    final data = response.data;

    if (response.status < 200 || response.status >= 300) {
      final message = data is Map ? data['message'] : null;
      throw Exception(
        message?.toString() ?? 'Layanan ELORA AI gagal (${response.status}).',
      );
    }

    if (data is! Map || data['success'] != true) {
      final message = data is Map ? data['message'] : null;
      throw Exception(message?.toString() ?? 'Respons ELORA AI tidak valid.');
    }

    final answer = data['reply'];
    if (answer is! String || answer.trim().isEmpty) {
      throw Exception('ELORA AI mengirim jawaban kosong.');
    }
    return answer.trim();
  }
}
