import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

const Color kNavy = Color(0xFF0C447C);
const Color kMidBlue = Color(0xFF378ADD);
const Color kBgBlue = Color(0xFFF4F8FD);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  String _selectedRole = 'user';

  final ApiService _apiService = ApiService();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _aadhaarController.dispose();
    _otpController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // SUBMIT
  void _submit() async {
    // SUBMIT
    if (_selectedRole == 'user') {
      if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
          ),
        );
        return;
      }
    } else {
      if (_usernameController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
          ),
        );
        return;
      }
    }

    if (_selectedRole == 'user') {
      if (_phoneController.text.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a valid 10-digit phone number'),
          ),
        );
        return;
      }
    }

    if (_isLogin) {
      // LOGIN FLOW
      _showLoader();
      bool success;

      if (_selectedRole == 'user') {
        success = await _apiService.login(
          _phoneController.text,
          _passwordController.text,
          _selectedRole,
        );
      } else {
        success = await _apiService.adminLogin(
          _usernameController.text,
          _passwordController.text,
        );
      }
      if (mounted) context.pop();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Successful!'),
            backgroundColor: Colors.green,
          ),
        );

        if (_selectedRole == 'admin') {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials or role'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // REGISTER FLOW — Step 1: Request OTP
      if (_selectedRole == 'user') {
        if (_aadhaarController.text.length != 12) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aadhaar must be exactly 12 digits'),
            ),
          );
          return;
        }
      }
      _showLoader();
      bool success;

      if (_selectedRole == 'user') {
        success = await _apiService.requestOtp(
          _phoneController.text,
          _aadhaarController.text,
        );
      } else {
        success = await _apiService.requestAdminOtp(
          _emailController.text,
        );
      }
      if (mounted) context.pop();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedRole == 'user'
                  ? 'OTP sent successfully.'
                  : 'OTP sent to your email!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        _showOtpBottomSheet();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedRole == 'user'
                  ? 'Failed to send OTP. Check phone and Aadhaar.'
                  : 'Failed to send OTP. Check admin email.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  // OTP BOTTOM SHEET
  void _showOtpBottomSheet() {
    _otpController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.message_rounded, size: 50, color: kMidBlue),
            const SizedBox(height: 16),
            const Text('Enter OTP',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: kNavy)),
            const SizedBox(height: 8),
            Text(
                _selectedRole == 'user'
                    ? "We've sent a code to ${_phoneController.text}"
                    : "We've sent a code to ${_emailController.text}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 12,
                fontWeight: FontWeight.bold,
                color: kNavy,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '000000',
                filled: true,
                fillColor: kBgBlue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _finalizeRegistration();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('VERIFY OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // FINAL REGISTRATION
  void _finalizeRegistration() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid 6-digit OTP'),
        ),
      );
      return;
    }
    _showLoader();
    bool success;

    if (_selectedRole == 'user') {
      bool otpVerified = await _apiService.verifyOtp(
        _phoneController.text,
        _otpController.text,
      );

      if (!otpVerified) {
        if (mounted) context.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid or Expired OTP"),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      success = await _apiService.register(
        _phoneController.text,
        _passwordController.text,
        _aadhaarController.text,
        _selectedRole,
      );
    } else {
      success = await _apiService.adminRegister(
        _usernameController.text,
        _nameController.text,
        _departmentController.text,
        _emailController.text,
        _passwordController.text,
        _otpController.text,
      );
    }
    if (mounted) context.pop();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful! Please login.'),
          backgroundColor: kMidBlue,
        ),
      );

      setState(() => _isLogin = true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Please check your details.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _isLogin
                      ? Icons.lock_person_rounded
                      : Icons.person_add_alt_1_rounded,
                  size: 80,
                  color: kNavy,
                ),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kNavy,
                  ),
                ),
                const SizedBox(height: 32),

                // Role selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 'user'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'user'
                                  ? kMidBlue
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(11),
                              ),
                            ),
                            child: Text(
                              'Citizen',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedRole == 'user'
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 'admin'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'admin'
                                  ? kNavy
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(11),
                              ),
                            ),
                            child: Text(
                              'Admin',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedRole == 'admin'
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Phone field ──
                if (_selectedRole == 'user')
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_android, color: kMidBlue),
                    ),
                  )
                else
                  TextField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person, color: kMidBlue),
                    ),
                  ),

                const SizedBox(height: 16),

                // Aadhaar (register only)
                if (!_isLogin && _selectedRole == 'user') ...[
                  TextField(
                    controller: _aadhaarController,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    decoration: const InputDecoration(
                      labelText: 'Aadhaar Number',
                      prefixIcon: Icon(Icons.credit_card, color: kMidBlue),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (!_isLogin && _selectedRole == 'admin') ...[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _departmentController.text.isEmpty
                        ? null
                        : _departmentController.text,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.category, color: kMidBlue),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Agriculture & Farmers',
                        child: Text('Agriculture & Farmers'),
                      ),
                      DropdownMenuItem(
                        value: 'Business, Employment & MSME',
                        child: Text('Business, Employment & MSME'),
                      ),
                      DropdownMenuItem(
                        value: 'Education & Learning',
                        child: Text('Education & Learning'),
                      ),
                      DropdownMenuItem(
                        value: 'Financial Inclusion & Social Security',
                        child: Text('Financial Inclusion & Social Security'),
                      ),
                      DropdownMenuItem(
                        value: 'Housing & Shelter',
                        child: Text('Housing & Shelter'),
                      ),
                      DropdownMenuItem(
                        value: 'Infrastructure, Transport & Connectivity',
                        child: Text('Infrastructure, Transport & Connectivity'),
                      ),
                      DropdownMenuItem(
                        value: 'Rural Development & Governance',
                        child: Text('Rural Development & Governance'),
                      ),
                      DropdownMenuItem(
                        value: 'Water Supply & Sanitation',
                        child: Text('Water Supply & Sanitation'),
                      ),
                      DropdownMenuItem(
                        value: 'Women, Children & Social Welfare',
                        child: Text('Women, Children & Social Welfare'),
                      ),
                    ],
                    onChanged: (value) {
                      _departmentController.text = value ?? '';
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Admin Email',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, color: kMidBlue),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit button
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedRole == 'admin' ? kNavy : kMidBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isLogin ? 'LOGIN' : 'REQUEST OTP',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle login/register
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      children: [
                        TextSpan(
                          text: _isLogin
                              ? "Don't have an account? "
                              : 'Already have an account? ',
                        ),
                        TextSpan(
                          text: _isLogin ? 'Register Now' : 'Login Here',
                          style: const TextStyle(
                            color: kMidBlue,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
