import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
      if (kIsWeb) {
            return android;
                }
                    switch (defaultTargetPlatform) {
                          case TargetPlatform.android:
                                  return android;
                                        case TargetPlatform.iOS:
                                                return android;
                                                      default:
                                                              return android;
                                                                  }
                                                                    }

                                                                      static const FirebaseOptions android = FirebaseOptions(
                                                                          apiKey: 'AIzaSyBFxCx5xw12SgzFVXuitjkQo2IXWQuB5lM',
                                                                              appId: '1:736013105572:android:976d193b5ce37748c4e931',
                                                                                  messagingSenderId: '736013105572',
                                                                                      projectId: 'sportlivetv-3d133',
                                                                                          storageBucket: 'sportlivetv-3d133.firebasestorage.app',
                                                                                            );
                                                                                            }