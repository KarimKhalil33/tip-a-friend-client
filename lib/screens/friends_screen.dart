import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  bool isSending = false;
  String? error;
  String? sentMessage;
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> sentRequests = [];
  List<Map<String, dynamic>> receivedRequests = [];
  List<Map<String, dynamic>> friends = [];
  int tabIndex = 0;

  static const String baseUrl = 'http://localhost:4000/api';

  @override
  void initState() {
    super.initState();
    _loadFriendsData();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _loadFriendsData() async {
    setState(() {
      error = null;
    });
    try {
      final token = await _getToken();
      // Get current friends
      final friendsRes = await http.get(Uri.parse('$baseUrl/friends/list'),
          headers: {'Authorization': 'Bearer $token'});
      if (friendsRes.statusCode == 200) {
        friends = List<Map<String, dynamic>>.from(json.decode(friendsRes.body));
      }
      // Get sent requests (pending requests sent by me)
      final sentRes = await http.get(
          Uri.parse('$baseUrl/friends/sent-requests'),
          headers: {'Authorization': 'Bearer $token'});
      if (sentRes.statusCode == 200) {
        sentRequests =
            List<Map<String, dynamic>>.from(json.decode(sentRes.body));
      }
      // Get received requests (pending requests received by me)
      final receivedRes = await http.get(
          Uri.parse('$baseUrl/friends/received-requests'),
          headers: {'Authorization': 'Bearer $token'});
      if (receivedRes.statusCode == 200) {
        receivedRequests =
            List<Map<String, dynamic>>.from(json.decode(receivedRes.body));
      }
      setState(() {});
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> _searchUser() async {
    setState(() {
      isSearching = true;
      error = null;
      searchResults = [];
      sentMessage = null;
    });
    try {
      final token = await _getToken();
      final res = await http.get(
        Uri.parse(
            '$baseUrl/users/search?name=${Uri.encodeComponent(_searchController.text)}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List) {
          searchResults = List<Map<String, dynamic>>.from(data);
        } else {
          searchResults = [];
        }
      } else {
        error = json.decode(res.body)['message'] ?? 'Error searching user';
      }
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
      final token = await _getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/friends/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode({'friendId': friendId}),
      );
      if (res.statusCode == 200) {
        sentMessage = 'Friend request sent!';
      } else {
        error = json.decode(res.body)['message'] ?? 'Error sending request';
      }
    } catch (e) {
      error = 'Error sending request';
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  Future<void> _acceptFriendRequest(int requesterId) async {
    setState(() {
      isSending = true;
      error = null;
    });
    try {
      final token = await _getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/friends/accept'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode({'requesterId': requesterId}),
      );
      if (res.statusCode == 200) {
        await _loadFriendsData();
      } else {
        error = json.decode(res.body)['message'] ?? 'Error accepting request';
      }
    } catch (e) {
      error = 'Error accepting request';
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  Widget _buildUserAction(Map<String, dynamic> user) {
    final isFriend = friends.any((f) => f['id'] == user['id']);
    final isSent = sentRequests.any((r) => r['id'] == user['id']);
    final isReceived = receivedRequests.any((r) => r['id'] == user['id']);
    if (isFriend) {
      return const Text('Friends', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
    } else if (isSent) {
      return const Text('Requested', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold));
    } else if (isReceived) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isSending ? null : () => _acceptFriendRequest(user['id']),
        child: isSending
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Accept'),
      );
    } else {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isSending ? null : () => _sendFriendRequest(user['id']),
        child: isSending
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Add'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends & Requests'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search username',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
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
                  ],
                ),
              ),
              if (error != null) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      Text(error!, style: const TextStyle(color: Colors.red)),
                ),
              ],
              if (sentMessage != null) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(sentMessage!,
                      style: const TextStyle(color: Colors.green)),
                ),
              ],
              // Search results
              if (searchResults.isNotEmpty)
                Expanded(
                  child: ListView(
                    children: searchResults
                        .map((user) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[800],
                                backgroundImage: user['profile_image'] != null
                                    ? NetworkImage(user['profile_image'])
                                    : null,
                                child: user['profile_image'] == null
                                    ? const Icon(Icons.person,
                                        color: Color(0xFF2196F3))
                                    : null,
                              ),
                              title: Text(user['name'],
                                  style: const TextStyle(color: Colors.white)),
                              trailing: _buildUserAction(user),
                            ))
                        .toList(),
                  ),
                ),
              // Tabs for requests/friends
              if (searchResults.isEmpty)
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: const Color(0xFF2196F3),
                          unselectedLabelColor: Colors.white70,
                          indicatorColor: const Color(0xFF2196F3),
                          tabs: const [
                            Tab(text: 'Friends'),
                            Tab(text: 'Sent'),
                            Tab(text: 'Received'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Friends
                              ListView(
                                children: friends
                                    .map((f) => ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.grey[800],
                                            backgroundImage:
                                                f['profile_image'] != null
                                                    ? NetworkImage(
                                                        f['profile_image'])
                                                    : null,
                                            child: f['profile_image'] == null
                                                ? const Icon(Icons.person,
                                                    color: Color(0xFF2196F3))
                                                : null,
                                          ),
                                          title: Text(f['name'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          subtitle: Text(f['email'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.white70)),
                                        ))
                                    .toList(),
                              ),
                              // Sent requests (placeholder)
                              ListView(
                                children: sentRequests.isEmpty
                                    ? [
                                        const ListTile(
                                            title: Text('No sent requests',
                                                style: TextStyle(
                                                    color: Colors.white70)))
                                      ]
                                    : sentRequests
                                        .map((r) => ListTile(
                                              title: Text(r['name'] ?? '',
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                              subtitle: const Text('Pending',
                                                  style: TextStyle(
                                                      color: Colors.white70)),
                                            ))
                                        .toList(),
                              ),
                              // Received requests (placeholder)
                              ListView(
                                children: receivedRequests.isEmpty
                                    ? [
                                        const ListTile(
                                            title: Text('No received requests',
                                                style: TextStyle(
                                                    color: Colors.white70)))
                                      ]
                                    : receivedRequests
                                        .map((r) => ListTile(
                                              title: Text(r['name'] ?? '',
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                              trailing: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF2196F3),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                ),
                                                onPressed: isSending
                                                    ? null
                                                    : () =>
                                                        _acceptFriendRequest(
                                                            r['id']),
                                                child: isSending
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors
                                                                    .white))
                                                    : const Text('Accept'),
                                              ),
                                            ))
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
