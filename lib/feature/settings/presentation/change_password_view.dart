import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/widgets/custom_toast.dart';
import '../../auth/presentation/views/login_view.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'كلمة المرور الجديدة غير متطابقة';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text);
      
      if (!mounted) return;
      showToast(text: 'تم تغيير كلمة المرور بنجاح. يرجى تسجيل الدخول مجدداً.', state: ToastStates.success);
      
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'wrong-password') {
          _errorMessage = 'كلمة المرور القديمة غير صحيحة';
        } else {
          _errorMessage = e.message ?? 'فشل تغيير كلمة المرور';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'تغيير كلمة المرور',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'ReadexPro'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontFamily: 'ReadexPro', fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            _buildTextField(
              controller: _oldPasswordController,
              label: 'كلمة المرور الحالية',
              obscureText: _obscureOld,
              onToggle: () {
                setState(() => _obscureOld = !_obscureOld);
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _newPasswordController,
              label: 'كلمة المرور الجديدة',
              obscureText: _obscureNew,
              onToggle: () {
                setState(() => _obscureNew = !_obscureNew);
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'تأكيد كلمة المرور الجديدة',
              obscureText: _obscureConfirm,
              onToggle: () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4499),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'حفظ التغييرات',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'ReadexPro', color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontFamily: 'ReadexPro'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'ReadexPro'),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4A4499)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

