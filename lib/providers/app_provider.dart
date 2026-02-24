
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _firebaseUser = user;
      _userDocSubscription?.cancel();

      if (user != null) {
        await _ensureUserRecordExists(user);
        // Start listening to the user document for real-time company updates
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
    _userDocSubscription = _firestore.collection('users').doc(userId).snapshots().listen((doc) async {
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
      print("Error ensuring user record exists: $e");
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

      _userCompanies = companyQuery.docs.map((doc) => Company.fromFirestore(doc)).toList();
      
      // Keep the current selection if it still exists, otherwise pick the first
      if (_selectedCompany != null) {
        bool stillExists = _userCompanies.any((c) => c.id == _selectedCompany!.id);
        if (stillExists) {
          _selectedCompany = _userCompanies.firstWhere((c) => c.id == _selectedCompany!.id);
        } else {
          _selectedCompany = _userCompanies.isNotEmpty ? _userCompanies.first : null;
        }
      } else {
        _selectedCompany = _userCompanies.isNotEmpty ? _userCompanies.first : null;
      }
    } catch (e) {
      _errorMessage = "Failed to load companies: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCompany(Company company) {
    _selectedCompany = company;
    _selectedModuleId = null; 
    notifyListeners();
  }

  void selectModule(String? moduleId) {
    _selectedModuleId = moduleId;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
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
    }
  }

  Future<bool> signUp({required String email, required String password, String name = 'New User'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
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

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
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
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
