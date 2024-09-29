import 'dart:io';
import 'package:auth_2024/models/item.dart';
import 'package:auth_2024/models/profile_model.dart';
import 'package:auth_2024/services/profile_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();

  var isLoading = false.obs; // Definir isLoading como observable
  var imageFile =
      Rxn<File>(); // Variable para almacenar la imagen seleccionada en móvil
  var imageWebFile =
      Rxn<Uint8List>(); // Variable para almacenar la imagen seleccionada en web
  RxList<Item> items = <Item>[]
      .obs; // Lista observable de ítems para actualizar la UI automáticamente
  var filteredItems = <Item>[].obs; // Lista observable de ítems filtrados
  var searchQuery = ''.obs; // Variable observable para el texto de búsqueda

  // Método para seleccionar una imagen (móvil o web)
  Future<void> pickImage(bool fromCamera) async {
    if (kIsWeb) {
      // Seleccionar imagen en Flutter Web usando FilePicker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.first.bytes != null) {
        imageWebFile.value =
            result.files.first.bytes; // Guardar imagen para la web
      } else {
        Get.snackbar("Error", "No se seleccionó ninguna imagen");
      }
    } else {
      // Seleccionar imagen en dispositivos móviles usando ImagePicker
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path); // Guardar la imagen en móviles
      } else {
        Get.snackbar("Error", "No se seleccionó ninguna imagen");
      }
    }
  }

  // Método para guardar un nuevo ítem
  Future<void> saveProfile(String idProfile, String name, String email, String ws, String phone, DateTime fnac) async {
  try {
    isLoading.value = true;
    String itemId = Uuid().v4(); // Generar un ID único para el ítem

    // Subir la imagen si existe
    String? imageUrl;
    if (imageFile.value != null || imageWebFile.value != null) {
      // Subir la imagen (en móvil o web) usando el servicio
      imageUrl = await _profileService.uploadImageForPlatform(
        kIsWeb ? imageWebFile.value! : imageFile.value!, itemId,
      );
    } 

    // Crear una instancia de Profile con todos los datos
    Profile profile = Profile(
  id: idProfile,
  ws: ws,
  phone: phone,
  imageUrl: imageUrl ?? '',  // Si es nulo, asignar una cadena vacía
  name: name,
  email: email,
  fnac: fnac,
);


    // Guardar el perfil usando el servicio
    await _profileService.saveProfile(profile);
    Get.snackbar('Éxito', 'Perfil guardado correctamente');

  } catch (e) {
    Get.snackbar('Error', 'Ocurrió un error al guardar el perfil');
  } finally {
    isLoading.value = false;
  }
}

  // Método para obtener un ítem por su ID
  Future<Profile?> getItemById(String itemId) async {
    try {
      return await _profileService.getProfile(itemId);
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error al obtener el ítem');
      return null;
    }
  }
}
