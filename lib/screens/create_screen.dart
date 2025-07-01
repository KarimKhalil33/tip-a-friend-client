import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String type = 'Request';
  String category = 'Ride';
  String title = '';
  String description = '';
  String location = '';
  String price = '';
  DateTime? time;
  bool isSubmitting = false;
  String? error;
  String? success;

  static const String baseUrl = 'http://localhost:4000/api';
  final List<String> categories = [
    'Ride',
    'Cook',
    'Chore',
    'Space Rental',
    'Borrow',
    'Custom'
  ];

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || time == null) return;
    setState(() {
      isSubmitting = true;
      error = null;
      success = null;
    });
    try {
      final token = await _getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/requests/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'type': type,
          'category': category,
          'title': title,
          'description': description,
          'location': location,
          'price': price,
          'time': time!.toIso8601String(),
        }),
      );
      if (res.statusCode == 201) {
        setState(() {
          success = 'Created successfully!';
        });
        _formKey.currentState!.reset();
        time = null;
      } else {
        error = json.decode(res.body)['message'] ?? 'Error creating request';
      }
    } catch (e) {
      error = 'Error creating request';
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Create Request/Offer'),
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Create a New Post',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: type,
                                decoration: _inputDecoration('Type'),
                                dropdownColor: Colors.black,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Request',
                                      child: Text('Request',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  DropdownMenuItem(
                                      value: 'Offer',
                                      child: Text('Offer',
                                          style:
                                              TextStyle(color: Colors.white))),
                                ],
                                onChanged: (v) => setState(() => type = v!),
                                style: const TextStyle(color: Colors.white),
                                iconEnabledColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: category,
                                decoration: _inputDecoration('Category'),
                                dropdownColor: Colors.black,
                                items: categories
                                    .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c,
                                            style: TextStyle(
                                                color: Colors.white))))
                                    .toList(),
                                onChanged: (v) => setState(() => category = v!),
                                style: const TextStyle(color: Colors.white),
                                iconEnabledColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          decoration: _inputDecoration('Title'),
                          style: const TextStyle(color: Colors.white),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                          onChanged: (v) => title = v,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          decoration: _inputDecoration('Description'),
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                          onChanged: (v) => description = v,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          decoration: _inputDecoration('Location'),
                          style: const TextStyle(color: Colors.white),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                          onChanged: (v) => location = v,
                        ),
                        const SizedBox(height: 18),
                        // Price (with CAD label, no dropdown)
                        TextFormField(
                          decoration: _inputDecoration('Price (CAD)'),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                          onChanged: (v) => price = v,
                        ),
                        const SizedBox(height: 18),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            time == null
                                ? 'Select Date & Time'
                                : _formatDateTime(time!),
                            style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_today,
                                color: Color(0xFF2196F3)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (t != null) {
                                  setState(() {
                                    time = DateTime(picked.year, picked.month,
                                        picked.day, t.hour, t.minute);
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (error != null)
                          Text(error!,
                              style: const TextStyle(color: Colors.red)),
                        if (success != null)
                          Text(success!,
                              style: const TextStyle(color: Colors.green)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 6,
                            shadowColor: Colors.black.withOpacity(0.25),
                          ),
                          onPressed: isSubmitting ? null : _submit,
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Create',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final date =
        "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$date  $hour:$minute $ampm";
  }
}
