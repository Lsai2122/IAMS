import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/academic_controller.dart';
import 'main_navigation_screen.dart';
import 'dashboard/student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final idStr = _idController.text.trim();

    if (email.isEmpty || password.isEmpty || (_isSignUp && (name.isEmpty || idStr.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    String? error;
    if (_isSignUp) {
      final id = int.tryParse(idStr);
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student ID must be a number')));
        return;
      }
      error = await academicController.signUp(name, email, password, id);
    } else {
      error = await academicController.login(email, password, context);
    }

    if (error == null) {
      if (_isSignUp) {
        setState(() => _isSignUp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please login.')),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(
              dashboard: StudentDashboard(),
              role: 'Student',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryBlue.withOpacity(0.1), Colors.white, AppTheme.accentBlue.withOpacity(0.05)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.school_rounded, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(_isSignUp ? 'Create Account' : 'IAMS Portal', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 48),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        if (_isSignUp) ...[
                          TextField(
                            controller: _idController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Student ID', prefixIcon: Icon(Icons.badge_outlined)),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ListenableBuilder(
                          listenable: academicController,
                          builder: (context, _) {
                            return academicController.isLoading 
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _handleAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(_isSignUp ? 'Sign Up' : 'Login'),
                                );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp ? 'Already have an account? Login' : 'New here? Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
