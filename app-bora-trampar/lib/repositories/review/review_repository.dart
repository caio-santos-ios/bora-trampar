import 'package:app_bora_trampar/api/http_client_api.dart';

class ReviewRepository {
  final _api = HttpClientApi(); 

  Future<void> create(Object body) async {
    await _api.client.post("/api/reviews", data: body);
  }
}