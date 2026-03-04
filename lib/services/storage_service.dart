import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late FirebaseStorage _firebaseStorage;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal() {
    _firebaseStorage = FirebaseStorage.instance;
  }

  /// Upload a file to Firebase Storage
  /// 
  /// [folderPath]: The folder path in storage (e.g., "uploads/user_images/")
  /// [fileName]: The name for the file in storage
  /// [filePath]: The local file path to upload
  /// 
  /// Returns the download URL of the uploaded file
  Future<String> uploadFile({
    required String folderPath,
    required String fileName,
    required String filePath,
  }) async {
    try {
      final File file = File(filePath);
      
      // Create reference with folder and file name
      final Reference ref = _firebaseStorage.ref("$folderPath$fileName");
      
      // Upload file
      await ref.putFile(file);
      
      // Get and return download URL
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Upload a file with metadata
  /// 
  /// Useful for tracking file type, size, and other metadata
  Future<String> uploadFileWithMetadata({
    required String folderPath,
    required String fileName,
    required String filePath,
    required String contentType,
    Map<String, String>? customMetadata,
  }) async {
    try {
      final File file = File(filePath);
      
      final settingsMetadata = SettableMetadata(
        contentType: contentType,
        customMetadata: customMetadata ?? {},
      );
      
      final Reference ref = _firebaseStorage.ref("$folderPath$fileName");
      await ref.putFile(file, settingsMetadata);
      
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Upload with metadata failed: ${e.message}');
    } catch (e) {
      throw Exception('Upload with metadata failed: $e');
    }
  }

  /// Get download URL for an existing file
  /// 
  /// [storagePath]: Full path to the file (e.g., "uploads/user_images/photo.jpg")
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final Reference ref = _firebaseStorage.ref(storagePath);
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Failed to get download URL: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Delete a file from Firebase Storage
  /// 
  /// [storagePath]: Full path to the file to delete
  Future<void> deleteFile(String storagePath) async {
    try {
      final Reference ref = _firebaseStorage.ref(storagePath);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw Exception('Delete failed: ${e.message}');
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }

  /// Delete multiple files
  /// 
  /// [storagePaths]: List of file paths to delete
  Future<void> deleteMultipleFiles(List<String> storagePaths) async {
    try {
      for (final path in storagePaths) {
        final Reference ref = _firebaseStorage.ref(path);
        await ref.delete();
      }
    } on FirebaseException catch (e) {
      throw Exception('Batch delete failed: ${e.message}');
    } catch (e) {
      throw Exception('Batch delete failed: $e');
    }
  }

  /// Get file metadata
  /// 
  /// [storagePath]: Full path to the file
  Future<FullMetadata> getFileMetadata(String storagePath) async {
    try {
      final Reference ref = _firebaseStorage.ref(storagePath);
      final FullMetadata metadata = await ref.getMetadata();
      return metadata;
    } on FirebaseException catch (e) {
      throw Exception('Failed to get metadata: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get metadata: $e');
    }
  }

  /// List all files in a folder
  /// 
  /// [folderPath]: The folder path to list files from
  Future<List<String>> listFiles(String folderPath) async {
    try {
      final Reference ref = _firebaseStorage.ref(folderPath);
      final ListResult result = await ref.listAll();
      
      final List<String> fileNames = result.items
          .map((Reference ref) => ref.name)
          .toList();
      
      return fileNames;
    } on FirebaseException catch (e) {
      throw Exception('Failed to list files: ${e.message}');
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// Generate unique filename with timestamp
  /// 
  /// [extension]: File extension (e.g., "jpg", "png")
  String generateUniqueFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "$timestamp.$extension";
  }

  /// Calculate file size in MB
  /// 
  /// [filePath]: Local file path
  double getFileSizeInMB(String filePath) {
    final File file = File(filePath);
    final sizeInBytes = file.lengthSync();
    return sizeInBytes / (1024 * 1024);
  }

  /// Validate file size before upload
  /// 
  /// [filePath]: Local file path
  /// [maxSizeInMB]: Maximum allowed size in MB
  bool isFileSizeValid(String filePath, double maxSizeInMB) {
    final sizeInMB = getFileSizeInMB(filePath);
    return sizeInMB <= maxSizeInMB;
  }

  /// Get file reference
  /// 
  /// [storagePath]: Full path to the file
  Reference getFileReference(String storagePath) {
    return _firebaseStorage.ref(storagePath);
  }

  /// Get storage root reference
  Reference getRootReference() {
    return _firebaseStorage.ref();
  }

  /// Get folder reference
  /// 
  /// [folderPath]: Path to the folder
  Reference getFolderReference(String folderPath) {
    return _firebaseStorage.ref(folderPath);
  }
}
