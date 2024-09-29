import 'dart:io';
import 'dart:typed_data';
import 'package:auth_2024/models/item.dart';
import 'package:auth_2024/models/profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // Para usar kIsWeb
import 'package:image_picker/image_picker.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Método para subir una imagen a Firebase Storage para móviles
  Future<String?> uploadImage(File imageFile, String profileId) async {
    try {
      Reference storageReference = _storage.ref().child('users/$profileId');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  // Método para subir imágenes desde la web (Uint8List)
  Future<String?> uploadWebImage(Uint8List imageBytes, String profileId) async {
    try {
      Reference storageReference = _storage.ref().child('users/$profileId');
      UploadTask uploadTask = storageReference
          .putData(imageBytes); // Usar putData para bytes en la web
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen en la web: $e');
      return null;
    }
  }

  // Método para guardar el ítem en Firestore
  Future<void> saveProfile(Profile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .set(profile.toFirestore());
    } catch (e) {
      print('Error al guardar ítem en Firestore: $e');
    }
  }

  // Método para obtener un ítem de Firestore por su ID
  Future<Profile?> getProfile(String idProfile) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(idProfile).get();
      if (doc.exists) {
        return Profile.fromFirestore(doc);
      } else {
        print('El ítem no existe.');
        return null;
      }
    } catch (e) {
      print('Error al obtener ítem de Firestore: $e');
      return null;
    }
  }

  // Método para seleccionar imagen dependiendo de la plataforma (móvil o web)
  Future<dynamic> pickImage(bool fromCamera) async {
    if (kIsWeb) {
      // Si es web, usamos FilePicker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.first.bytes != null) {
        return result
            .files.first.bytes; // Retornamos los bytes de la imagen para la web
      } else {
        return null;
      }
    } else {
      // Si es móvil, usamos ImagePicker
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile != null) {
        return File(
            pickedFile.path); // Retornamos el archivo en dispositivos móviles
      } else {
        return null;
      }
    }
  }

  // Método para subir la imagen según la plataforma (móvil o web)
  Future<String?> uploadImageForPlatform(
      dynamic imageFile, String itemId) async {
    if (kIsWeb && imageFile is Uint8List) {
      return await uploadWebImage(imageFile, itemId); // Subir imagen web
    } else if (imageFile is File) {
      return await uploadImage(imageFile, itemId); // Subir imagen móvil
    } else {
      print('Error: Tipo de archivo no soportado.');
      return null;
    }
  }
}
