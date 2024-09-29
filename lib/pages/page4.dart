import 'dart:io';
import 'package:auth_2024/controllers/auth_controller.dart';
import 'package:auth_2024/controllers/profile_controller.dart';
import 'package:auth_2024/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Page4 extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedBirthDate;
  final ProfileController _profileController = Get.find();
  final AuthController _authController = Get.find();
  Profile? _userProfile;

  @override
  Widget build(BuildContext context) {
    // Cargar los datos del perfil cuando se inicia la página
    _loadUserProfile();

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => _profileController.isLoading.value
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Imagen circular con icono de cámara
                    Stack(
                      children: [
                        Obx(() {
                          if (_profileController.imageFile.value != null) {
                            // Mostrar imagen seleccionada en móviles (File)
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  FileImage(_profileController.imageFile.value!),
                            );
                          } else if (_profileController.imageWebFile.value != null) {
                            // Mostrar imagen seleccionada en web (Uint8List)
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage: MemoryImage(
                                  _profileController.imageWebFile.value!),
                            );
                          } else if (_userProfile?.imageUrl != null &&
                              _userProfile!.imageUrl.isNotEmpty) {
                            // Mostrar imagen guardada en el perfil del usuario
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(_userProfile!.imageUrl),
                            );
                          } else {
                            // Imagen por defecto si no hay ninguna seleccionada o guardada
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, size: 50, color: Colors.white),
                            );
                          }
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                            onPressed: () => _showImagePicker(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Campo de texto para el nombre
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Campo de texto para el correo electrónico
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10),

                    // Campo de texto para WhatsApp
                    TextField(
                      controller: _whatsappController,
                      decoration: InputDecoration(
                        labelText: 'WhatsApp',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 10),

                    // Campo de texto para celular
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Celular',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 10),

                    // Campo de selección de fecha de nacimiento
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedBirthDate != null
                                ? 'Fecha de nacimiento: ${DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)}'
                                : 'Seleccione su fecha de nacimiento',
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectBirthDate(context),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Botón para guardar cambios
                    ElevatedButton(
                      onPressed: () {
                        final String idProfile =
                            _authController.userlogueado!.uid.toString();
                        _profileController.saveProfile(
                          idProfile,
                          _nameController.text,
                          _emailController.text,
                          _whatsappController.text,
                          _phoneController.text,
                          _selectedBirthDate ?? DateTime.now(),
                        );
                      },
                      child: Text('Guardar cambios'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Método para cargar los datos del perfil del usuario
  void _loadUserProfile() async {
    final String idProfile = _authController.userlogueado!.uid.toString();
    _userProfile = await _profileController.getItemById(idProfile);

    if (_userProfile != null) {
      _nameController.text = _userProfile!.name;
      _emailController.text = _userProfile!.email;
      _whatsappController.text = _userProfile!.ws;
      _phoneController.text = _userProfile!.phone;
      _selectedBirthDate = _userProfile!.fnac;
    }
  }

  // Método para seleccionar la fecha de nacimiento
  Future<void> _selectBirthDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      _selectedBirthDate = pickedDate;
    }
  }

  // Mostrar el selector de imágenes
  void _showImagePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Cámara'),
              onTap: () {
                _profileController.pickImage(true);
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galería'),
              onTap: () {
                _profileController.pickImage(false);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
