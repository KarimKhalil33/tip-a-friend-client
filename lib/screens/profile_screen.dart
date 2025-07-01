import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  String? error;
  String profilePicUrl = '';
  String username = '';
  String displayName = '';
  int friendsCount = 0;
  double rating = 0.0;
  int reviewsCount = 0;
  List<Map<String, dynamic>> posts = [];

  static const String baseUrl = 'http://localhost:4000/api';

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> loadProfileData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final userInfo = await _fetchUserInfo();
      final friends = await _fetchFriends();
      final myPosts = await _fetchMyPosts();
      setState(() {
        profilePicUrl = userInfo['profile_image'] ?? '';
        username = userInfo['name'] ?? '';
        displayName = userInfo['name'] ?? '';
        rating = (userInfo['rating'] ?? 0).toDouble();
        friendsCount = friends.length;
        posts = myPosts;
        reviewsCount = 0; // TODO: fetch reviews count if endpoint available
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchUserInfo() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['user'] ?? {};
    } else {
      throw Exception('Failed to load user info: ${response.body}');
    }
  }

  Future<List<dynamic>> _fetchFriends() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/friends/list'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load friends: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMyPosts() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/requests/my'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data
            .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load your posts: ${response.body}');
    }
  }

  Widget _profileStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2196F3), size: 28),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.85),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Masculine, bold gradient background (match HomeFeedScreen)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Glassmorphism overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          if (error != null)
            Center(
                child:
                    Text('Error: $error', style: TextStyle(color: Colors.red))),
          if (!isLoading && error == null)
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                children: [
                  const SizedBox(height: 24),
                  // Profile header card
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 24),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.18),
                            Colors.white.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.18),
                            blurRadius: 32,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Glowing profile image
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                ),
                              ],
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF0F2027)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: Colors.grey[900],
                              backgroundImage: profilePicUrl.isNotEmpty
                                  ? NetworkImage(profilePicUrl)
                                  : null,
                              child: profilePicUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 60, color: Color(0xFF2196F3))
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '@$username',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats row card
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.13),
                            Colors.white.withOpacity(0.07),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _profileStat(
                              Icons.people, '$friendsCount', 'Friends'),
                          _profileStat(
                              Icons.star, rating.toStringAsFixed(1), 'Rating'),
                          _profileStat(
                              Icons.reviews, '$reviewsCount', 'Reviews'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Section: Your Posts
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Your Posts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.98),
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Posts grid glass card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.10),
                          Colors.white.withOpacity(0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.13),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: posts.isEmpty
                        ? Center(
                            child: Text(
                              'No posts yet.',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: posts.length,
                            itemBuilder: (context, idx) {
                              final post = posts[idx];
                              return GestureDetector(
                                onTap: () async {
                                  final result = await showDialog(
                                    context: context,
                                    builder: (context) => _PostDetailDialog(
                                      post: post,
                                      baseUrl: baseUrl,
                                    ),
                                  );
                                  if (result == true || result == 'deleted') {
                                    // Refresh posts after edit or delete
                                    await loadProfileData();
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.all(2),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.13),
                                        Colors.white.withOpacity(0.06),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color:
                                          Colors.blueAccent.withOpacity(0.13),
                                      width: 1.1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Category chip
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.blueAccent
                                              .withOpacity(0.18),
                                        ),
                                        child: Text(
                                          post['category']?.toString() ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Title
                                      Text(
                                        post['title']?.toString() ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 15,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Date or status (if available)
                                      if (post['createdAt'] != null)
                                        Text(
                                          formatDate(post['createdAt']),
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.6),
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PostDetailDialog extends StatefulWidget {
  final Map<String, dynamic> post;
  final String baseUrl;
  const _PostDetailDialog({required this.post, required this.baseUrl});

  @override
  State<_PostDetailDialog> createState() => _PostDetailDialogState();
}

class _PostDetailDialogState extends State<_PostDetailDialog> {
  bool isEditing = false;
  bool isDeleting = false;
  late Map<String, dynamic> editedPost;
  String? error;

  // Add your categories here (should match HomeFeedScreen)
  final List<String> _categories = [
    'Ride',
    'Cook',
    'Chore',
    'Space Rental',
    'Borrow',
    'Custom'
  ];

  @override
  void initState() {
    super.initState();
    editedPost = Map<String, dynamic>.from(widget.post);
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _editPost() async {
    setState(() => error = null);
    final token = await _getToken();
    final id = widget.post['id']?.toString() ?? widget.post['_id']?.toString();
    if (id == null) return;
    try {
      final response = await http.put(
        Uri.parse('${widget.baseUrl}/requests/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'type': editedPost['type'],
          'category': editedPost['category'],
          'title': editedPost['title'],
          'description': editedPost['description'],
          'location': editedPost['location'],
          'price': editedPost['price'],
          // Remove 'currency'
          'time': editedPost['time'],
        }),
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pop(true); // Indicate success
      } else {
        setState(() => error = 'Failed to edit post: ${response.body}');
      }
    } catch (e) {
      setState(() => error = 'Error: $e');
    }
  }

  Future<void> _deletePost() async {
    setState(() => isDeleting = true);
    final token = await _getToken();
    final id = widget.post['id']?.toString() ?? widget.post['_id']?.toString();
    if (id == null) return;
    try {
      final response = await http.delete(
        Uri.parse('${widget.baseUrl}/requests/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pop('deleted');
      } else {
        setState(() {
          isDeleting = false;
          error = 'Failed to delete post: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        isDeleting = false;
        error = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 60),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.black.withOpacity(0.65), // More solid for readability
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: isEditing ? _editForm(context) : _detailsView(context),
          ),
        ),
      ),
    );
  }

  Widget _detailsView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.blueAccent.withOpacity(0.18),
          ),
          child: Text(
            widget.post['category']?.toString() ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.1,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          widget.post['title']?.toString() ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 14),
        if (widget.post['description'] != null &&
            widget.post['description'].toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              widget.post['description'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.92),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        if (widget.post['amount'] != null ||
            widget.post['payment'] != null ||
            widget.post['price'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.attach_money,
                    color: Colors.greenAccent, size: 18),
                const SizedBox(width: 6),
                Text(
                  widget.post['amount']?.toString() ??
                      widget.post['payment']?.toString() ??
                      widget.post['price']?.toString() ??
                      '',
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(width: 4),
                const Text(
                  'CAD',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        if (widget.post['time'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  formatDateTime(widget.post['time']),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        if (widget.post['location'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on,
                    color: Colors.redAccent, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.post['location'].toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        if (widget.post['createdAt'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  formatDate(widget.post['createdAt']),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() => isEditing = true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                // Removed textStyle to avoid TextStyle interpolation error
              ),
              child: const Text('Edit'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: isDeleting
                  ? null
                  : () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Post'),
                          content: const Text(
                              'Are you sure you want to delete this post?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _deletePost();
                      }
                    },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                // Removed textStyle to avoid TextStyle interpolation error
              ),
              child: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _editForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Edit Post',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18)),
        const SizedBox(height: 16),
        _editField('Title', 'title'),
        _editField('Description', 'description', maxLines: 3),
        // Category dropdown
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DropdownButtonFormField<String>(
            value: editedPost['category'] != null &&
                    _categories.contains(editedPost['category'])
                ? editedPost['category']
                : null,
            items: _categories
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat,
                          style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
            onChanged: (val) => setState(() => editedPost['category'] = val),
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
          ),
        ),
        _editField('Location', 'location'),
        // Price (with CAD label, no dropdown)
        Row(
          children: [
            Expanded(
              child: _editField('Price (CAD)', 'price',
                  keyboardType: TextInputType.number, numericOnly: true),
            ),
          ],
        ),
        _dateTimeField(context),
        const SizedBox(height: 18),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() => isEditing = false),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _editPost,
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _editField(String label, String key,
      {int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      bool numericOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: editedPost[key]?.toString() ?? '',
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputFormatters: numericOnly
            ? [
                // Only allow digits
                FilteringTextInputFormatter.digitsOnly
              ]
            : null,
        onChanged: (val) => setState(() => editedPost[key] = val),
      ),
    );
  }

  Widget _dateTimeField(BuildContext context) {
    DateTime? parsed;
    try {
      parsed = DateTime.parse(editedPost['time'] ?? '');
    } catch (_) {}
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () async {
          final now = DateTime.now();
          final initialDate = parsed ?? now;
          final date = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(now.year - 1),
            lastDate: DateTime(now.year + 5),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: parsed != null
                  ? TimeOfDay(hour: parsed.hour, minute: parsed.minute)
                  : TimeOfDay.now(),
            );
            if (time != null) {
              final dt = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
              setState(() => editedPost['time'] = dt.toIso8601String());
            }
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: TextEditingController(
                text: parsed != null
                    ? formatDateTime(parsed.toIso8601String())
                    : ''),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Time',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon:
                  const Icon(Icons.calendar_today, color: Colors.white70),
            ),
            readOnly: true,
          ),
        ),
      ),
    );
  }
}

// Move these to the bottom of the file as top-level helpers:
String formatDate(dynamic date) {
  try {
    final dt = DateTime.parse(date.toString());
    return "${dt.day}/${dt.month}/${dt.year}";
  } catch (_) {
    return '';
  }
}

String formatDateTime(String isoString) {
  try {
    final dateTime = DateTime.parse(isoString);
    // Format: 27/10/2023, 14:30
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  } catch (_) {
    return isoString; // Fallback to original string on error
  }
}
