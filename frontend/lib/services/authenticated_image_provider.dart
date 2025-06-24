import 'dart:async';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthenticatedNetworkImage extends ImageProvider<AuthenticatedNetworkImage> {
  const AuthenticatedNetworkImage(this.url, {this.scale = 1.0});

  final String url;
  final double scale;

  @override
  Future<AuthenticatedNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AuthenticatedNetworkImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(AuthenticatedNetworkImage key, ImageDecoderCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();
    
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<AuthenticatedNetworkImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    AuthenticatedNetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async {
    try {
      final String? token = await _getAuthToken();
      final Map<String, String> headers = {};
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final http.Response response = await http.get(
        Uri.parse(key.url),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw NetworkImageLoadException(
          statusCode: response.statusCode,
          uri: Uri.parse(key.url),
        );
      }

      final Uint8List bytes = response.bodyBytes;
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: ${key.url}');
      }

      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (e) {
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting auth token for image: $e');
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AuthenticatedNetworkImage &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'AuthenticatedNetworkImage')}("$url", scale: $scale)';
}

// Helper widget to make it easier to use
class AuthenticatedImage extends StatelessWidget {
  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AuthenticatedNetworkImage(imageUrl),
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading authenticated image: $error');
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            );
      },
    );
  }
}