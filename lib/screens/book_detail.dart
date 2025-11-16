import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/book_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color kPrimaryPurple = Color(0xFF8E24AA);
const Color kLightPurple = Color(0xFFE1BEE7);
const Color kLighterPurple = Color(0xFFF3E5F5);

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookService _bookService = BookService();
  final TextEditingController reviewCtrl = TextEditingController();
  int rating = 5;
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final wishlistDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(widget.bookId);

    final doc = await wishlistDoc.get();
    setState(() {
      isWishlisted = doc.exists;
    });
  }

  void _addReview(DocumentSnapshot bookDoc) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userName =
        FirebaseAuth.instance.currentUser!.displayName ?? 'Anonymous';
    await bookDoc.reference.collection('reviews').add({
      'userId': uid,
      'userName': userName,
      'review': reviewCtrl.text.trim(),
      'rating': rating,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    reviewCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted 💜')),
    );
  }

  void _addToCart(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final cartRef = FirebaseFirestore.instance.collection('carts').doc(uid);
    final snapshot = await cartRef.get();
    List items = [];
    if (snapshot.exists) items = (snapshot.data()!['items'] as List) ?? [];
    final idx = items.indexWhere((i) => i['bookId'] == widget.bookId);
    if (idx >= 0) {
      items[idx]['quantity'] = (items[idx]['quantity'] ?? 1) + 1;
    } else {
      items.add({
        'bookId': widget.bookId,
        'title': data['title'],
        'price': data['price'],
        'quantity': 1,
        'coverUrl': data['coverUrl'] ?? '',
      });
    }
    await cartRef.set({'items': items});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart 🛒')),
    );
  }

  void _toggleWishlist(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(widget.bookId);

    final doc = await wishlistRef.get();

    if (doc.exists) {
      await wishlistRef.delete();
      setState(() => isWishlisted = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from wishlist 💔')),
      );
    } else {
      await wishlistRef.set({
        'bookId': widget.bookId,
        'title': data['title'],
        'author': data['author'],
        'price': data['price'],
        'genre': data['genre'],
        'coverUrl': data['coverUrl'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() => isWishlisted = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to wishlist 💜')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _bookService.getBookById(widget.bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: kPrimaryPurple),
            ),
          );
        }

        if (!snapshot.hasData ||
            !(snapshot.data as DocumentSnapshot).exists) {
          return const Scaffold(
            body: Center(child: Text('Book not found')),
          );
        }

        final doc = snapshot.data as DocumentSnapshot;
        final data = doc.data() as Map<String, dynamic>;
        final genre = data['genre'] ?? 'Unknown';

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              // 🌈 App bar with gradient and image
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: kPrimaryPurple,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white), // ✅ White back button
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: const Color.fromARGB(255, 87, 31, 124)),
                      if (data['coverUrl'] != null &&
                          data['coverUrl'].isNotEmpty)
                        Opacity(
                          opacity: 0.25,
                          child: Image.network(
                            data['coverUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      Center(
                        child: Hero(
                          tag: widget.bookId,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              data['coverUrl'] ?? '',
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.book,
                                size: 100,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    data['title'] ?? 'Book Details',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 4)
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  centerTitle: true,
                ),
              ),

              // 📖 Book info section
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.deepPurple.shade50,
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text(
    data['title'] ?? '',
    style: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.deepPurple,
    ),
  ),
),




                      const SizedBox(height: 6),
                      Text(
                        'by ${data['author'] ?? 'Unknown'}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                     // 🏷️ Genre + Badges Section
Row(
  children: [
    Chip(
      label: Text(genre),
      backgroundColor: kLighterPurple,
      labelStyle: const TextStyle(color: kPrimaryPurple),
    ),
    const SizedBox(width: 8),

    if (data['isBestseller'] == true)
      Chip(
        label: const Text('Best Seller '),
       
        labelStyle: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
      ),

    if (data['isNewArrival'] == true)
      Chip(
        label: const Text('New Arrival '),
       
        labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      ),
  ],
),

                      const SizedBox(height: 10),
                      Text(
                        '\$${(data['price'] ?? 0).toString()}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Buttons
                     // 🛒 Buttons
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16), // ⬆ Increased size
        minimumSize: const Size(150, 50), // ⬆ Wider and taller
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: () => _addToCart(data),
      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
      label: const Text(
        'Add to Cart',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16), // ⬆ Increased size
        minimumSize: const Size(150, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: () => _toggleWishlist(data),
      icon: Icon(
        isWishlisted ? Icons.favorite : Icons.favorite_border,
        color: Colors.white,
        size: 22,
      ),
      label: const Text(
        'Wishlist',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  ],
),

                      const SizedBox(height: 20),
                      const Divider(),

                      // ⭐ Reviews Section
                      const Text(
                        'Reviews',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: doc.reference
                            .collection('reviews')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: kPrimaryPurple));
                          }
                          final reviews = snap.data!.docs;
                          if (reviews.isEmpty) {
                            return const Text('No reviews yet 💭');
                          }
                          return Column(
                            children: reviews.map((r) {
                              final rv = r.data() as Map<String, dynamic>;
                              return Card(
                                color: kLighterPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(rv['userName'] ?? 'User',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:Colors.black)),
                                  subtitle: Text(rv['review'] ?? ''),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${rv['rating'] ?? 0} ⭐'),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.thumb_up_alt_outlined,
                                          color: kPrimaryPurple,
                                        ),
                                        onPressed: () async {
                                          await r.reference.update({
                                            'likes': (rv['likes'] ?? 0) + 1
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Review input
                      TextField(
                        controller: reviewCtrl,
                        decoration: InputDecoration(
                          labelText: 'Write a review...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: kLighterPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                     Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const Text(
      'Ratings:',
      style: TextStyle(
        color: Colors.green,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(width: 10),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: kLighterPurple,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryPurple),
      ),
      child: DropdownButton<int>(
        value: rating,
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        iconEnabledColor: kPrimaryPurple,
        items: List.generate(5, (i) => i + 1)
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text('$v ⭐', style: const TextStyle(color: Colors.black87)),
                ))
            .toList(),
        onChanged: (v) => setState(() => rating = v ?? 5),
      ),
    ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _addReview(doc),
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // 📚 Related Books
                      const Text(
                        'Related Books',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('books')
                            .where('genre', isEqualTo: genre)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final related = snapshot.data!.docs
                              .where((b) => b.id != widget.bookId)
                              .toList();
                          if (related.isEmpty) {
                            return const Text('No related books found.');
                          }
                          return SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: related.length,
                              itemBuilder: (context, index) {
                                final rData = related[index].data()
                                    as Map<String, dynamic>;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookDetailScreen(
                                            bookId: related[index].id),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 140,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kLightPurple.withOpacity(0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(12)),
                                          child: rData['coverUrl'] != null &&
                                                  rData['coverUrl'].isNotEmpty
                                              ? Image.network(
                                                  rData['coverUrl'],
                                                  height: 100,
                                                  width: 140,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  height: 100,
                                                  width: 140,
                                                  color: kLighterPurple,
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                rData['title'] ?? '',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: kPrimaryPurple),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '\$${(rData['price'] ?? 0).toString()}',
                                                style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                rData['genre'] ?? 'Unknown',
                                                style: const TextStyle(
                                                    color: kPrimaryPurple,
                                                    fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
