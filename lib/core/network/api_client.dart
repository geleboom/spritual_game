// class ApiClient {
//   final Dio _dio;
//   final ConnectivityService _connectivity;

//   ApiClient(this._dio, this._connectivity);

//   Future<bool> hasConnection() async {
//     return await _connectivity.checkConnection();
//   }

//   Future<List<Map<String, dynamic>>> getVerseUpdates(String? lastSync) async {
//     if (!await hasConnection()) return [];

//     try {
//       final response = await _dio.get(
//         '/verses/updates',
//         queryParameters: {'last_sync': lastSync},
//       );
//       return List<Map<String, dynamic>>.from(response.data);
//     } catch (e) {
//       debugPrint('API Error: $e');
//       return [];
//     }
//   }

//   Future<List<Map<String, dynamic>>> getNewScreensavers() async {
//     if (!await hasConnection()) return [];

//     try {
//       final response = await _dio.get('/screensavers/new');
//       return List<Map<String, dynamic>>.from(response.data);
//     } catch (e) {
//       debugPrint('API Error: $e');
//       return [];
//     }
//   }

//   Future<List<int>> downloadImage(String url) async {
//     final response = await _dio.get(
//       url,
//       options: Options(responseType: ResponseType.bytes),
//     );
//     return response.data;
//   }
// }