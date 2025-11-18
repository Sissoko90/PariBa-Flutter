# 📡 Documentation API Backend - PariBa

## 🔧 Configuration Backend

### **Base URL**
```
Development: http://localhost:8082
Production: https://api.pariba.com (à configurer)
```

### **Port**
- **Dev**: 8082
- **Prod**: Variable d'environnement `PORT` (défaut: 8082)

### **Base de données**
- **Type**: MySQL
- **Dev**: localhost:8889/pariba
- **Credentials Dev**: root/root

---

## 🔐 Authentification

### **Type**: JWT Bearer Token

### **Headers requis**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Format de réponse**
```json
{
  "success": true,
  "message": "Message de succès",
  "data": { ... }
}
```

---

## 📋 **ENDPOINTS DISPONIBLES**

### **1. AUTHENTIFICATION** (`/auth`)

#### **POST /auth/register**
Inscription d'un nouvel utilisateur

**Request:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+22370123456",
  "email": "john@example.com",
  "password": "Password123!",
  "confirmPassword": "Password123!",
  "dateOfBirth": "1990-01-01"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Inscription réussie",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "tokenType": "Bearer",
    "expiresIn": 86400000,
    "person": {
      "id": "uuid",
      "firstName": "John",
      "lastName": "Doe",
      "phone": "+22370123456",
      "email": "john@example.com"
    }
  }
}
```

#### **POST /auth/login**
Connexion utilisateur

**Request:**
```json
{
  "phone": "+22370123456",
  "password": "Password123!"
}
```

**Response:** Identique à `/register`

#### **POST /auth/password/forgot**
Mot de passe oublié

**Request:**
```json
{
  "phone": "+22370123456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Code OTP envoyé avec succès",
  "data": "123456"  // En dev uniquement
}
```

#### **POST /auth/password/reset**
Réinitialiser le mot de passe

**Request:**
```json
{
  "target": "+22370123456",
  "otpCode": "123456",
  "newPassword": "NewPassword123!"
}
```

#### **POST /auth/password/change**
Changer le mot de passe (utilisateur connecté)

**Request:**
```json
{
  "oldPassword": "OldPassword123!",
  "newPassword": "NewPassword123!"
}
```

#### **POST /auth/refresh**
Rafraîchir le token JWT

**Request:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

#### **POST /auth/logout**
Déconnexion

**Request:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

---

### **2. GROUPES DE TONTINE** (`/groups`)

#### **POST /groups**
Créer un groupe

**Request:**
```json
{
  "name": "Tontine Famille",
  "description": "Groupe familial mensuel",
  "contributionAmount": 50000,
  "frequency": "MONTHLY",
  "startDate": "2024-01-01",
  "gracePeriodDays": 3,
  "latePenaltyAmount": 5000
}
```

**Response:**
```json
{
  "success": true,
  "message": "Groupe créé avec succès",
  "data": {
    "id": "uuid",
    "name": "Tontine Famille",
    "description": "Groupe familial mensuel",
    "contributionAmount": 50000,
    "frequency": "MONTHLY",
    "status": "ACTIVE",
    "memberCount": 1,
    "currentTour": null,
    "createdAt": "2024-01-01T00:00:00",
    "invitationCode": "ABC123"
  }
}
```

#### **GET /groups/my-groups**
Récupérer mes groupes

**Response:**
```json
{
  "success": true,
  "message": "Opération réussie",
  "data": [
    {
      "id": "uuid",
      "name": "Tontine Famille",
      "contributionAmount": 50000,
      "frequency": "MONTHLY",
      "memberCount": 5,
      "status": "ACTIVE",
      "role": "ADMIN"
    }
  ]
}
```

#### **GET /groups/{groupId}**
Détails d'un groupe

**Response:**
```json
{
  "success": true,
  "message": "Opération réussie",
  "data": {
    "id": "uuid",
    "name": "Tontine Famille",
    "description": "Groupe familial",
    "contributionAmount": 50000,
    "frequency": "MONTHLY",
    "status": "ACTIVE",
    "memberCount": 5,
    "totalContributions": 250000,
    "currentTour": {
      "tourNumber": 1,
      "beneficiaryName": "John Doe",
      "dueDate": "2024-02-01"
    },
    "invitationCode": "ABC123",
    "createdAt": "2024-01-01T00:00:00"
  }
}
```

#### **PUT /groups/{groupId}**
Modifier un groupe (ADMIN uniquement)

**Request:**
```json
{
  "name": "Nouveau nom",
  "description": "Nouvelle description",
  "contributionAmount": 60000,
  "gracePeriodDays": 5,
  "latePenaltyAmount": 10000
}
```

#### **DELETE /groups/{groupId}**
Supprimer un groupe (ADMIN uniquement)

#### **POST /groups/{groupId}/leave**
Quitter un groupe

---

### **3. MEMBRES** (`/memberships`)

#### **GET /memberships/group/{groupId}**
Liste des membres d'un groupe

**Response:**
```json
{
  "success": true,
  "message": "Opération réussie",
  "data": [
    {
      "id": "uuid",
      "personId": "uuid",
      "personName": "John Doe",
      "personPhone": "+22370123456",
      "role": "ADMIN",
      "status": "ACTIVE",
      "joinedAt": "2024-01-01T00:00:00",
      "totalContributions": 150000,
      "paidContributions": 3,
      "pendingContributions": 0
    }
  ]
}
```

#### **PUT /memberships/role**
Modifier le rôle d'un membre (ADMIN uniquement)

**Request:**
```json
{
  "groupId": "uuid",
  "personId": "uuid",
  "newRole": "TREASURER"
}
```

**Rôles disponibles:**
- `ADMIN` - Administrateur
- `TREASURER` - Trésorier
- `MEMBER` - Membre simple

#### **DELETE /memberships/group/{groupId}/member/{personId}**
Retirer un membre (ADMIN uniquement)

---

### **4. INVITATIONS** (`/invitations`)

#### **POST /invitations**
Inviter un membre (ADMIN uniquement)

**Request:**
```json
{
  "groupId": "uuid",
  "phone": "+22370123456",
  "message": "Rejoignez notre tontine !"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Invitation envoyée",
  "data": {
    "id": "uuid",
    "groupId": "uuid",
    "groupName": "Tontine Famille",
    "inviterName": "John Doe",
    "phone": "+22370123456",
    "linkCode": "ABC123XYZ",
    "status": "PENDING",
    "expiresAt": "2024-02-01T00:00:00",
    "createdAt": "2024-01-01T00:00:00"
  }
}
```

#### **POST /invitations/accept**
Accepter une invitation

**Request:**
```json
{
  "linkCode": "ABC123XYZ"
}
```

#### **GET /invitations/group/{groupId}**
Liste des invitations d'un groupe

---

### **5. PAIEMENTS** (`/payments`)

#### **POST /payments**
Effectuer un paiement

**Request:**
```json
{
  "contributionId": "uuid",
  "amount": 50000,
  "method": "ORANGE_MONEY",
  "transactionReference": "OM123456789",
  "notes": "Paiement du mois de janvier"
}
```

**Méthodes de paiement:**
- `ORANGE_MONEY`
- `MOOV_MONEY`
- `BANK_TRANSFER`
- `CASH`

**Response:**
```json
{
  "success": true,
  "message": "Paiement traité avec succès",
  "data": {
    "id": "uuid",
    "contributionId": "uuid",
    "amount": 50000,
    "method": "ORANGE_MONEY",
    "status": "PENDING",
    "transactionReference": "OM123456789",
    "paidAt": "2024-01-15T10:30:00"
  }
}
```

#### **GET /payments/{id}**
Détails d'un paiement

#### **GET /payments/contribution/{contributionId}**
Paiements d'une contribution

#### **GET /payments/person/{personId}**
Paiements d'une personne

#### **POST /payments/{id}/verify**
Vérifier un paiement (ADMIN/TREASURER uniquement)

---

### **6. NOTIFICATIONS** (`/notifications`)

#### **GET /notifications**
Mes notifications

**Response:**
```json
{
  "success": true,
  "message": "Opération réussie",
  "data": [
    {
      "id": "uuid",
      "type": "PAYMENT_REMINDER",
      "title": "Rappel de paiement",
      "message": "Votre cotisation est due dans 3 jours",
      "isRead": false,
      "createdAt": "2024-01-15T10:00:00",
      "data": {
        "groupId": "uuid",
        "contributionId": "uuid"
      }
    }
  ]
}
```

**Types de notifications:**
- `PAYMENT_REMINDER` - Rappel de paiement
- `PAYMENT_RECEIVED` - Paiement reçu
- `INVITATION_RECEIVED` - Invitation reçue
- `TOUR_ASSIGNED` - Tour assigné
- `GROUP_UPDATE` - Mise à jour du groupe

#### **GET /notifications/unread**
Notifications non lues

#### **PUT /notifications/{id}/read**
Marquer comme lue

#### **PUT /notifications/read-all**
Tout marquer comme lu

---

### **7. PROFIL** (`/persons`)

#### **GET /persons/me**
Mon profil

**Response:**
```json
{
  "success": true,
  "message": "Opération réussie",
  "data": {
    "id": "uuid",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+22370123456",
    "email": "john@example.com",
    "dateOfBirth": "1990-01-01",
    "profilePictureUrl": "https://...",
    "createdAt": "2024-01-01T00:00:00",
    "statistics": {
      "totalGroups": 3,
      "totalContributions": 450000,
      "activeGroups": 2,
      "completedTours": 5
    }
  }
}
```

#### **PUT /persons/me**
Modifier mon profil

**Request:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "newemail@example.com",
  "dateOfBirth": "1990-01-01"
}
```

#### **POST /persons/me/profile-picture**
Upload photo de profil

**Request:** Multipart form-data
```
file: [image file]
```

---

### **8. DASHBOARD** (`/dashboard`)

#### **GET /dashboard/summary**
Résumé du dashboard

**Response:**
```json
{
  "success": true,
  "message": "Opération réussie",
  "data": {
    "totalGroups": 3,
    "activeGroups": 2,
    "totalContributions": 450000,
    "pendingPayments": 1,
    "upcomingPayments": [
      {
        "groupName": "Tontine Famille",
        "amount": 50000,
        "dueDate": "2024-02-01"
      }
    ],
    "recentGroups": [
      {
        "id": "uuid",
        "name": "Tontine Famille",
        "memberCount": 5,
        "nextPaymentDate": "2024-02-01"
      }
    ]
  }
}
```

---

## 🔒 **Sécurité**

### **JWT Configuration**
- **Algorithm**: HS256
- **Expiration**: 24 heures (86400000 ms)
- **Secret**: Base64 encoded (dev: `bXktZGV2LXNlY3JldC1sb25nLXNlY3JldC1iYXNlNjQ=`)

### **Refresh Token**
- **Durée de vie**: 30 jours
- **Stockage**: Base de données
- **Révocation**: Lors de la déconnexion

### **Rate Limiting**
- **Dev**: 200 requêtes / minute
- **Prod**: 100 requêtes / minute

---

## 📱 **Intégration Mobile**

### **1. Configuration Dio (Flutter)**

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static const String baseUrl = 'http://10.0.2.2:8082'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8082'; // iOS Simulator
  
  final Dio _dio;
  final FlutterSecureStorage _storage;

  DioClient(this._storage) : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ajouter le token JWT
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Gérer le refresh token si 401
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await _storage.write(key: 'access_token', value: data['accessToken']);
        await _storage.write(key: 'refresh_token', value: data['refreshToken']);
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _storage.read(key: 'access_token');
    requestOptions.headers['Authorization'] = 'Bearer $token';
    return _dio.fetch(requestOptions);
  }

  Dio get dio => _dio;
}
```

### **2. Modèles de Données**

```dart
// lib/data/models/api_response_model.dart
class ApiResponseModel<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}
```

### **3. Exemple d'utilisation**

```dart
// lib/data/datasources/group_remote_datasource.dart
class GroupRemoteDataSource {
  final DioClient dioClient;

  GroupRemoteDataSource(this.dioClient);

  Future<List<TontineGroupModel>> getMyGroups() async {
    try {
      final response = await dioClient.dio.get('/groups/my-groups');
      
      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (data) => (data as List)
            .map((json) => TontineGroupModel.fromJson(json))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      
      throw ServerException(apiResponse.message);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Erreur réseau');
    }
  }

  Future<TontineGroupModel> createGroup(CreateGroupRequest request) async {
    try {
      final response = await dioClient.dio.post(
        '/groups',
        data: request.toJson(),
      );
      
      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (data) => TontineGroupModel.fromJson(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      
      throw ServerException(apiResponse.message);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Erreur réseau');
    }
  }
}
```

---

## 🚀 **Prochaines Étapes**

1. ✅ Remplacer `http://10.0.2.2:3000` par `http://10.0.2.2:8082`
2. ✅ Implémenter DioClient avec intercepteurs
3. ✅ Créer les datasources pour chaque endpoint
4. ✅ Mapper les réponses vers les modèles Flutter
5. ✅ Tester tous les endpoints
6. ✅ Gérer les erreurs et le refresh token

---

## 📞 **Support**

Pour toute question sur l'API, consulter la documentation Swagger (quand activée) :
```
http://localhost:8082/swagger-ui.html
```

**Note**: Swagger est actuellement désactivé dans la configuration.
