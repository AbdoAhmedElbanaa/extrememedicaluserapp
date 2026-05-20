import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic method to get a collection
  CollectionReference<Map<String, dynamic>> getCollection(String collectionPath) {
    return _firestore.collection(collectionPath);
  }

  // Generic method to get a document
  DocumentReference<Map<String, dynamic>> getDocument(String collectionPath, String documentId) {
    return _firestore.collection(collectionPath).doc(documentId);
  }

  // Generic method to stream a collection
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  // Generic method to add a document
  Future<DocumentReference<Map<String, dynamic>>> addDocument(String collectionPath, Map<String, dynamic> data) {
    return _firestore.collection(collectionPath).add(data);
  }

  // Generic method to update a document
  Future<void> updateDocument(String collectionPath, String documentId, Map<String, dynamic> data) {
    return _firestore.collection(collectionPath).doc(documentId).update(data);
  }

  // Generic method to delete a document
  Future<void> deleteDocument(String collectionPath, String documentId) {
    return _firestore.collection(collectionPath).doc(documentId).delete();
  }
}
