
import 'package:firebase_auth/firebase_auth.dart';

import 'package:agrismart/models/utilisateur.dart';
import 'package:agrismart/services/auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<Utilisateur?> get utilisateur {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }

      return Utilisateur(
        uid: user.uid,
        email: user.email ?? '',
      );
    });
  }

  @override
  Future<void> connexion(String email, String motDePasse) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: motDePasse,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageErreur(e.code));
    }
  }

  @override
  Future<void> inscription(String email, String motDePasse) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: motDePasse,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageErreur(e.code));
    }
  }

  @override
  Future<void> reinitialiserMotDePasse(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageErreur(e.code));
    }
  }

  @override
  Future<void> deconnexion() async {
    await _firebaseAuth.signOut();
  }

  String _messageErreur(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (6 caractères minimum).';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Problème de connexion Internet.';
      default:
        return 'Une erreur est survenue. Réessayez.';
    }
  }
}
