import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isRegister = false;
  final _nameCtrl = TextEditingController();
  final _businessIdCtrl = TextEditingController();
  String _selectedRole = 'member';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.fitness_center, size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(_isRegister ? 'Create Account' : 'Business Platform', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  if (_isRegister) ...[
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                    validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                    validator: (v) => v == null || v.length < 4 ? 'Min 4 characters' : null,
                  ),
                  if (_isRegister) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge), border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'owner', child: Text('Business Owner')),
                        DropdownMenuItem(value: 'trainer', child: Text('Trainer')),
                        DropdownMenuItem(value: 'member', child: Text('Member')),
                      ],
                      onChanged: (v) => setState(() => _selectedRole = v!),
                    ),
                    if (_selectedRole != 'owner') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _businessIdCtrl,
                        decoration: const InputDecoration(labelText: 'Business ID', prefixIcon: Icon(Icons.business), border: OutlineInputBorder(), hintText: 'From your business owner'),
                        validator: (v) => _selectedRole != 'owner' && (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ],
                  ],
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: auth.isLoading ? null : _submit,
                      child: auth.isLoading ? const CircularProgressIndicator() : Text(_isRegister ? 'Register' : 'Login'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(_isRegister ? 'Already have an account? Login' : 'Don\'t have an account? Register'),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    bool success;
    if (_isRegister) {
      success = await auth.register(_nameCtrl.text, _emailCtrl.text, _passwordCtrl.text, _selectedRole, businessId: _businessIdCtrl.text);
    } else {
      success = await auth.login(_emailCtrl.text, _passwordCtrl.text);
    }
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
