import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class Company {
  final String id;
  final String name;

  Company({required this.id, required this.name});

  factory Company.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Company(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }
}

class CompanyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Company? _selectedCompany;
  List<Company> _userCompanies = [];
  bool _isLoading = false;

  Company? get selectedCompany => _selectedCompany;
  List<Company> get userCompanies => _userCompanies;
  bool get isLoading => _isLoading;

  Future<void> fetchUserCompanies() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        List<String> companyIds = List<String>.from(
            (userDoc.data() as Map<String, dynamic>)['companyIds'] ?? []);

        if (companyIds.isNotEmpty) {
          List<Company> companies = [];
          for (String id in companyIds) {
            DocumentSnapshot companyDoc =
                await _firestore.collection('companies').doc(id).get();
            if (companyDoc.exists) {
              companies.add(Company.fromFirestore(companyDoc));
            }
          }
          _userCompanies = companies;

          if (_userCompanies.isNotEmpty) {
            _selectedCompany = _userCompanies.first;
          }
        }
      }
    } catch (e) {
      developer.log("Error fetching user companies", error: e);
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectCompany(Company company) {
    _selectedCompany = company;
    notifyListeners();
  }
}
