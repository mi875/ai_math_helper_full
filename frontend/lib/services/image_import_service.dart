import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_helper;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ImageImportService {
  static const _uuid = Uuid();
  static final _picker = ImagePicker();

  static Future<bool> _requestCameraPermission() async {
    // Check current permission status first
    PermissionStatus status = await Permission.camera.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    // If denied, request permission
    if (status == PermissionStatus.denied) {
      status = await Permission.camera.request();
    }
    
    // Handle different permission states
    switch (status) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.denied:
        debugPrint('Camera permission denied by user');
        return false;
      case PermissionStatus.permanentlyDenied:
        debugPrint('Camera permission permanently denied. Please enable in settings.');
        await openAppSettings();
        return false;
      default:
        debugPrint('Camera permission status: $status');
        return false;
    }
  }

  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status == PermissionStatus.granted;
    }
    return true; // iOS doesn't need storage permission for app documents
  }

  // Debug method to check all permission statuses
  static Future<void> checkAllPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;
    
    debugPrint('=== Permission Status ===');
    debugPrint('Camera: $cameraStatus');
    debugPrint('Storage: $storageStatus');
    debugPrint('Platform: ${Platform.operatingSystem}');
    debugPrint('========================');
  }

  static Future<List<XFile>> importFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        return [image];
      }
      
      return [];
    } catch (e) {
      debugPrint('Error importing from camera: $e');
      return [];
    }
  }

  static Future<List<XFile>> importFromGallery() async {
    try {
      // Allow multiple image selection
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );
      
      return images;
    } catch (e) {
      debugPrint('Error importing from gallery: $e');
      return [];
    }
  }

  static Future<List<XFile>> scanDocument() async {
    try {
      final scannedDocs = await FlutterDocScanner().getScanDocuments();
      
      if (scannedDocs != null && scannedDocs.isNotEmpty) {
        final List<XFile> xFiles = [];
        
        for (final docPath in scannedDocs) {
          xFiles.add(XFile(docPath));
        }
        
        return xFiles;
      }
      
      return [];
    } catch (e) {
      debugPrint('Error scanning document: $e');
      return [];
    }
  }

  static Future<XFile?> importSingleFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      return image;
    } catch (e) {
      debugPrint('Error importing single image from camera: $e');
      return null;
    }
  }

  static Future<XFile?> importSingleFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      return image;
    } catch (e) {
      debugPrint('Error importing single image from gallery: $e');
      return null;
    }
  }

  // DEPRECATED: Images are now uploaded directly to server
  @Deprecated('Use XFile objects directly instead of saving to local storage')
  static Future<String?> _saveImageToAppDirectory(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path_helper.join(directory.path, 'math_images'));
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${_uuid.v4()}.png';
      final filePath = path_helper.join(imagesDir.path, fileName);
      
      await imageFile.copy(filePath);
      return filePath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  static Future<void> deleteImages(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      await deleteImage(imagePath);
    }
  }
}