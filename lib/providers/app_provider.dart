import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:developer' as developer;

// --- Data Models ---

class Company {
  final String id;
  final String name;
  final String? ownerId;
  final List<String> modulars;
  final String? logoUrl;

  Company({
    required this.id,
    required this.name,
    this.ownerId,
    required this.modulars,
    this.logoUrl,
  });

  factory Company.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Company(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Company',
      ownerId: data['ownerId'],
      modulars: List<String>.from(data['modulars'] ?? []),
      logoUrl: data['logoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerId': ownerId,
      'modulars': modulars,
      'logoUrl': logoUrl,
    };
  }
}

class UserData {
  final String id;
  final String email;
  final String name;
  final List<String> companyIds;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    required this.companyIds,
  });

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserData(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      companyIds: List<String>.from(data['companyIds'] ?? []),
    );
  }
}

// --- Main Application State Provider ---

class AppProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Internal State
  User? _firebaseUser;
  UserData? _userData;
  Company? _selectedCompany;
  String? _selectedModuleId;
  List<Company> _userCompanies = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserData? get userData => _userData;
  Company? get selectedCompany => _selectedCompany;
  String? get selectedModuleId => _selectedModuleId;
  List<Company> get userCompanies => _userCompanies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;

  // Logic expected by Router
  bool get isLoggedIn => _firebaseUser != null;
  bool get isInitialized => !_isLoading;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AppProvider() {
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }

  void _listenToAuthChanges() {
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      developer.log("Auth state changed: ${user?.uid}");
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _firebaseUser = user;
      _userDocSubscription?.cancel();

      if (user != null) {
        await _ensureUserRecordExists(user);
        _listenToUserDoc(user.uid);
      } else {
        _userData = null;
        _userCompanies = [];
        _selectedCompany = null;
        _selectedModuleId = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _listenToUserDoc(String userId) {
    _userDocSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((doc) async {
      if (doc.exists) {
        _userData = UserData.fromFirestore(doc);
        await _fetchCompanies();
      } else {
        _errorMessage = "User record not found.";
        _isLoading = false;
        notifyListeners();
      }
    }, onError: (e) {
      _errorMessage = "Error listening to user data: $e";
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _ensureUserRecordExists(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': user.email,
          'name': user.displayName ?? 'New User',
          'companyIds': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      developer.log("Error ensuring user record exists", error: e);
    }
  }

  Future<void> _fetchCompanies() async {
    if (_userData == null || _userData!.companyIds.isEmpty) {
      _userCompanies = [];
      _selectedCompany = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final companyQuery = await _firestore
          .collection('companies')
          .where(FieldPath.documentId, whereIn: _userData!.companyIds)
          .get();

      _userCompanies =
          companyQuery.docs.map((doc) => Company.fromFirestore(doc)).toList();

      // Do NOT auto-select if nothing is selected. Let the user choose.
      if (_selectedCompany != null) {
        bool stillExists =
            _userCompanies.any((c) => c.id == _selectedCompany!.id);
        if (!stillExists) {
          _selectedCompany = null;
          _selectedModuleId = null;
        }
      }
    } catch (e) {
      _errorMessage = "Failed to load companies: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCompany(Company company) {
    developer.log("Selecting company: ${company.name}");
    _selectedCompany = company;
    _selectedModuleId = null; // Reset module when company changes
    notifyListeners();
  }

  void selectModule(String? moduleId) {
    developer.log("Selecting module: $moduleId");
    _selectedModuleId = moduleId;
    notifyListeners();
  }

  // Authentication Methods
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password,
      {String name = 'New User'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid,
          'email': email,
          'name': name,
          'companyIds': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _selectedCompany = null;
      _selectedModuleId = null;
      _userCompanies = [];
      _userData = null;
    } catch (e) {
      developer.log("Error signing out", error: e);
    }
  }

  // Company Management Methods
  Future<void> addCompany({required String name, String? logoUrl}) async {
    if (_firebaseUser == null) return;
    try {
      final docRef = await _firestore.collection('companies').add({
        'name': name,
        'ownerId': _firebaseUser!.uid,
        'modulars': [],
        'logoUrl': logoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(_firebaseUser!.uid).update({
        'companyIds': FieldValue.arrayUnion([docRef.id]),
      });
    } catch (e) {
      developer.log("Error adding company", error: e);
      rethrow;
    }
  }

  Future<void> updateCompany(String companyId,
      {required String name, String? logoUrl}) async {
    try {
      await _firestore.collection('companies').doc(companyId).update({
        'name': name,
        'logoUrl': logoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log("Error updating company", error: e);
      rethrow;
    }
  }
}
