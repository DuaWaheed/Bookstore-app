import 'package:cloud_firestore/cloud_firestore.dart';

class BookService {
  final CollectionReference books = FirebaseFirestore.instance.collection('books');

  Stream<QuerySnapshot> getAllBooks() => books.orderBy('createdAt', descending: true).snapshots();

  Stream<QuerySnapshot> getBooksByGenre(String genre) =>
      books.where('genre', isEqualTo: genre).snapshots();

  Stream<QuerySnapshot> searchBooksByTitle(String title) =>
      books.where('title', isGreaterThanOrEqualTo: title).where('title', isLessThanOrEqualTo: '$title\uf8ff').snapshots();

  Future<DocumentSnapshot> getBookById(String id) => books.doc(id).get();

  Future<void> addBook(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    await books.add(data);
  }

  Future<void> updateBook(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await books.doc(id).update(data);
  }

  Future<void> deleteBook(String id) async {
    // delete reviews subcollection if needed (Firestore doesn't cascade)
    final reviews = await books.doc(id).collection('reviews').get();
    for (final r in reviews.docs) {
      await r.reference.delete();
    }
    await books.doc(id).delete();
  }

  Stream<QuerySnapshot> getBestsellers() =>
      books.where('isBestseller', isEqualTo: true).snapshots();

  Stream<QuerySnapshot> getNewArrivals() =>
      books.where('isNewArrival', isEqualTo: true).snapshots();
}
