import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tip_a_friend_client/models/post.dart';
import 'package:tip_a_friend_client/services/post_service.dart';
// TODO: import review service/model if needed

class RequestDetailScreen extends StatefulWidget {
  final Post post;
  const RequestDetailScreen({super.key, required this.post});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  bool isAccepting = false;
  String? acceptMessage;
  // Placeholder: Simulate current user ID (should be fetched from auth/profile)
  final String currentUserId = 'user123'; // TODO: Replace with real user ID

  // Placeholder: Simulate acceptance status (should come from backend/Post model)
  String? acceptedBy; // userId of the accepter
  bool confirmedByPoster = false;

  @override
  void initState() {
    super.initState();
    // TODO: Fetch acceptance status from backend or Post model
    // For now, simulate with widget.post.acceptedBy, widget.post.confirmedByPoster, etc.
    acceptedBy = widget.post.acceptedBy; // Add this field to Post model/backend
    confirmedByPoster =
        widget.post.confirmedByPoster ?? false; // Add this field as well
  }

  Future<void> acceptRequest() async {
    setState(() {
      isAccepting = true;
      acceptMessage = null;
    });
    try {
      await PostService.acceptRequest(widget.post.id);
      setState(() {
        acceptMessage = 'Request accepted!';
        acceptedBy = currentUserId;
      });
    } catch (e) {
      setState(() {
        acceptMessage = 'Failed to accept: $e';
      });
    } finally {
      setState(() {
        isAccepting = false;
      });
    }
  }

  Future<void> confirmAcceptance() async {
    setState(() {
      isAccepting = true;
      acceptMessage = null;
    });
    try {
      await PostService.confirmAcceptance(widget.post.id);
      setState(() {
        acceptMessage = 'You confirmed the acceptance!';
        confirmedByPoster = true;
      });
    } catch (e) {
      setState(() {
        acceptMessage = 'Failed to confirm: $e';
      });
    } finally {
      setState(() {
        isAccepting = false;
      });
    }
  }

  String _formatDateTime(DateTime time) {
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

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isPoster =
        post.posterId == currentUserId; // Add posterId to Post model
    final isAccepted = acceptedBy != null;
    final isAcceptedByMe = acceptedBy == currentUserId;
    final isWaitingForPoster = isAccepted && isPoster && !confirmedByPoster;
    final isWaitingForConfirmation =
        isAccepted && !isPoster && !confirmedByPoster;
    final isConfirmed = isAccepted && confirmedByPoster;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Gradient background
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
          // Main content (full screen, no card)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ListView(
                children: [
                  Text(post.title,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(post.description,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 20),
                  Row(children: [
                    Icon(Icons.attach_money, color: Color(0xFF2196F3)),
                    const SizedBox(width: 4),
                    Text(post.price,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.access_time, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(_formatDateTime(post.time),
                        style: const TextStyle(color: Colors.white70)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.person, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(post.posterName,
                        style: const TextStyle(color: Colors.white70)),
                  ]),
                  const SizedBox(height: 24),
                  const Text('Reviews & Ratings',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  // TODO: Show reviews/ratings here
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('No reviews yet.',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 24),
                  // Button logic
                  if (!isAccepted) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isAccepting ? null : acceptRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isAccepting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Accept Request',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                  ] else if (isWaitingForPoster) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isAccepting ? null : confirmAcceptance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isAccepting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Confirm Acceptance',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        'Someone accepted your request. Confirm to proceed!',
                        style: TextStyle(color: Colors.white70)),
                  ] else if (isWaitingForConfirmation) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Waiting for poster to confirm...',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ] else if (isConfirmed) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Request fully accepted!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                  if (acceptMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(acceptMessage!,
                        style: TextStyle(
                            color: acceptMessage!.contains('accept')
                                ? Colors.green
                                : Colors.red)),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
