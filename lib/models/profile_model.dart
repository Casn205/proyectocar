import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String id;
  String imageUrl;
  String name;
  String email;
  String ws; // WhatsApp o cualquier otra variable relacionada
  String phone;

  DateTime? createdAt;
  DateTime? fnac; // Fecha de nacimiento

  // Constructor
  Profile({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.ws,
    required this.phone,
    this.createdAt,
    this.fnac,
  });

  // Factory para crear un perfil desde Firestore (deserialización)
  factory Profile.fromFirestore(DocumentSnapshot data) {
    return Profile(
      id: data['id'] ?? '', // Se obtiene el id desde la data de Firestore
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      ws: data['ws'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: (data['createdAt'] != null)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      fnac:
          (data['fnac'] != null) ? (data['fnac'] as Timestamp).toDate() : null,
    );
  }

  // Método para convertir la instancia a un mapa compatible con Firestore (serialización)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id, // El id también se incluye en la serialización
      'imageUrl': imageUrl,
      'name': name,
      'email': email,
      'ws': ws,
      'phone': phone,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'fnac': fnac != null ? Timestamp.fromDate(fnac!) : null,
    };
  }
}
