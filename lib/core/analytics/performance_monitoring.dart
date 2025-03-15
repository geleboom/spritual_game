// import 'package:firebase_performance/firebase_performance.dart';

// class PerformanceMonitoring {
//   static final FirebasePerformance _performance = FirebasePerformance.instance;

//   static Future<void> trackVerseLoading(Future<void> Function() action) async {
//     final Trace trace = _performance.newTrace('verse_loading');
//     await trace.start();
    
//     try {
//       await action();
//     } finally {
//       await trace.stop();
//     }
//   }

//   static void setCustomAttribute(String key, String value) {
//     _performance.setPerformanceCollectionEnabled(true);
//     // Add custom attributes for monitoring
//   }
// }