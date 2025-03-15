// class ScreensaverRepository {
//   final Box _screensaversBox;
//   final ApiClient? _apiClient;

//   ScreensaverRepository({ApiClient? apiClient})
//       : _apiClient = apiClient,
//         _screensaversBox = Hive.box(LocalStorage.screensaversBoxKey);

//   Future<List<Screensaver>> getScreensavers() async {
//     return _screensaversBox.values.map((e) => Screensaver.fromJson(e)).toList();
//   }

//   Future<void> downloadNewScreensavers() async {
//     if (_apiClient == null) return;

//     try {
//       final newScreensavers = await _apiClient.getNewScreensavers();
      
//       // Download images
//       for (var screensaver in newScreensavers) {
//         final bytes = await _apiClient.downloadImage(screensaver.imageUrl);
//         final localPath = await _saveImageLocally(bytes, screensaver.id);
//         screensaver.localPath = localPath;
        
//         await _screensaversBox.put(screensaver.id, screensaver.toJson());
//       }
//     } catch (e) {
//       debugPrint('Failed to download screensavers: $e');
//     }
//   }

//   Future<String> _saveImageLocally(List<int> bytes, String id) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/screensavers/$id.jpg');
//     await file.create(recursive: true);
//     await file.writeAsBytes(bytes);
//     return file.path;
//   }
// }