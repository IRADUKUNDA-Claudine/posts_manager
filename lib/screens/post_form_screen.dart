// lib/screens/post_form_screen.dart
//
// This single screen handles BOTH:
//   • Creating a new post  (post == null)
//   • Editing an existing post (post != null)

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/api_exception.dart';

class PostFormScreen extends StatefulWidget {
  /// When null, the form is in "create" mode.
  /// When set, the form is in "edit" mode and fields are pre-populated.
  final Post? post;

  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PostService _service = PostService();

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  bool _isLoading = false;
  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // UPDATE existing post via PUT
        await _service.updatePost(
          widget.post!.copyWith(
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
          ),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // CREATE new post via POST
        await _service.createPost(
          userId: 1,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } on NetworkException catch (e) {
      _showError('Network error: ${e.message}');
    } on ServerException catch (e) {
      _showError('Server error (${e.statusCode}): ${e.message}');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F36),
        foregroundColor: Colors.white,
        title: Text(_isEditing ? 'Edit Post' : 'New Post'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Title field ---
              const Text(
                'Title',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F36),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration('Enter post title'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (v.trim().length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Body field ---
              const Text(
                'Body',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F36),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bodyController,
                minLines: 6,
                maxLines: 12,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration('Write your post content here…'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Body is required';
                  }
                  if (v.trim().length < 10) {
                    return 'Body must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // --- Submit button ---
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5B6EF5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Save Changes' : 'Create Post',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5B6EF5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
