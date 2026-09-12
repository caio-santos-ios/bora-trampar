import '../../api/http_client_api.dart';
import '../../models/daily_word_model.dart';

class DailyWordRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<DailyWordModel?> getTodayWord({String audience = ''}) async {
    final response = await _api.client.get(
      '/api/daily-words/today',
      queryParameters: audience.isNotEmpty ? {'audience': audience} : null,
    );

    if(response.statusCode == 200) {
      return response.data["result"]["data"] != null ? DailyWordModel.fromJson(response.data["result"]["data"]) : null;
    }

    return null;
  }
}
