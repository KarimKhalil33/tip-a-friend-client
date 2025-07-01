import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tip_a_friend_client/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tip_a_friend_client/services/post_service.dart';
import 'package:tip_a_friend_client/screens/request_detail_screen.dart';
import 'package:tip_a_friend_client/screens/profile_screen.dart';
import 'package:tip_a_friend_client/screens/friends_screen.dart';
import 'package:tip_a_friend_client/screens/create_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  bool isLoading = false;
  List<Post> posts = [];

  // Category filter state
  final List<String> categories = [
    'Ride',
    'Cook',
    'Chore',
    'Space Rental',
    'Borrow',
    'Custom'
  ];
  String selectedCategory = 'Ride';

  // Dropdown selector state
  bool showRequests = true;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      print('Token in HomeFeedScreen: $token');
      final postsData = await PostService.fetchFeed(token);
      setState(() {
        posts = postsData;
      });
    } catch (e) {
      print('Fetch error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} d ago';
    }
  }

  String _formatDateTime(DateTime time) {
    // Example: Jun 28, 3:00 PM
    return '${_monthAbbr(time.month)} ${time.day}, ${_formatHourMinute(time)}';
  }

  String _monthAbbr(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  String _formatHourMinute(DateTime time) {
    int hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $ampm';
  }

  List<Post> get filteredPosts {
    print(posts);
    return posts
        .where((post) =>
            post.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
  }

  void _onNavBarTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Masculine, bold gradient background
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
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                children: [
                  // User avatar and greeting
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 32, right: 32, bottom: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[900],
                          child: Icon(Icons.person,
                              size: 36, color: Color(0xFF2196F3)),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications,
                              color: Color(0xFF2196F3), size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // App title
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Tip A Friend',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                              blurRadius: 8,
                              color: Colors.black54,
                              offset: Offset(0, 2))
                        ],
                      ),
                    ),
                  ),
                  // Dropdown selector for Requests/Offers
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[850]?.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: showRequests ? 'Requests' : 'Offers',
                        dropdownColor: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Requests',
                            child: Text('Requests'),
                          ),
                          DropdownMenuItem(
                            value: 'Offers',
                            child: Text('Offers'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            showRequests = value == 'Requests';
                          });
                        },
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF2196F3)),
                      ),
                    ),
                  ),
                  // Category filter bar (only for requests)
                  if (showRequests)
                    Container(
                      height: 48,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, idx) {
                                final cat = categories[idx];
                                final isSelected = cat == selectedCategory;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = cat;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF2196F3)
                                          : Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(24),
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.white, width: 2)
                                          : null,
                                    ),
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Feed list
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : showRequests
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: ListView.builder(
                                  itemCount: filteredPosts.length,
                                  itemBuilder: (context, index) {
                                    final post = filteredPosts[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.grey[900]?.withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.18),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                            color: Colors.grey[800]!,
                                            width: 1.2),
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RequestDetailScreen(
                                                      post: post),
                                            ),
                                          );
                                        },
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 24),
                                        title: Text(
                                          post.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                            color: Color.fromARGB(
                                                255, 252, 252, 253),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post.description,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.attach_money,
                                                      size: 18,
                                                      color: Color(0xFF2196F3)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    post.price,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Icon(Icons.access_time,
                                                      size: 16,
                                                      color: Colors.white70),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatDateTime(post.time),
                                                    style: const TextStyle(
                                                        color: Colors.white70),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Icon(Icons.person,
                                                      size: 16,
                                                      color: Colors.white70),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    post.posterName,
                                                    style: const TextStyle(
                                                        color: Colors.white70),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        trailing: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Color(0xFF2196F3)),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'No offers available yet.',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 18),
                                ),
                              ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Color(0xFF2196F3),
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onNavBarTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.people),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FriendsScreen()),
          );
        },
        tooltip: 'Friends & Requests',
      ),
    );
  }
}

class _FriendRequestDialog extends StatefulWidget {
  @override
  State<_FriendRequestDialog> createState() => _FriendRequestDialogState();
}

class _FriendRequestDialogState extends State<_FriendRequestDialog> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  bool isSending = false;
  String? error;
  List<Map<String, dynamic>> searchResults = [];
  String? sentMessage;

  Future<void> _searchUser() async {
    setState(() {
      isSearching = true;
      error = null;
      searchResults = [];
      sentMessage = null;
    });
    try {
      // TODO: Replace with your actual search endpoint
      // Example: GET /api/users/search?name=xxx
      await Future.delayed(const Duration(seconds: 1));
      // Simulate result
      searchResults = [
        {'id': 2, 'name': _searchController.text, 'profile_image': null},
      ];
    } catch (e) {
      error = 'Error searching user';
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  Future<void> _sendFriendRequest(int friendId) async {
    setState(() {
      isSending = true;
      error = null;
      sentMessage = null;
    });
    try {
      // TODO: Use your /api/friends/send endpoint
      await Future.delayed(const Duration(seconds: 1));
      sentMessage = 'Friend request sent!';
    } catch (e) {
      error = 'Error sending request';
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Find & Add Friend',
          style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Enter username',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: isSearching ? null : _searchUser,
            child: isSearching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Search'),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          if (sentMessage != null) ...[
            const SizedBox(height: 8),
            Text(sentMessage!, style: const TextStyle(color: Colors.green)),
          ],
          if (searchResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...searchResults.map((user) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    backgroundImage: user['profile_image'] != null
                        ? NetworkImage(user['profile_image'])
                        : null,
                    child: user['profile_image'] == null
                        ? const Icon(Icons.person, color: Color(0xFF2196F3))
                        : null,
                  ),
                  title: Text(user['name'],
                      style: const TextStyle(color: Colors.white)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed:
                        isSending ? null : () => _sendFriendRequest(user['id']),
                    child: isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Add'),
                  ),
                )),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
