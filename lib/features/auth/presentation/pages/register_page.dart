import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/data/auth_api_client.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';
import 'package:tunihorse/features/rider/presentation/pages/rider_root_page.dart';
import 'package:tunihorse/features/trainer/presentation/pages/trainer_root_page.dart';

class RegisterPage extends StatefulWidget {
  final String role;

  const RegisterPage({super.key, required this.role});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authApiClient = AuthApiClient();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  String get _backendRole {
    return widget.role.toLowerCase().startsWith('entra')
        ? 'ENTRAINEUR'
        : 'CAVALIER';
  }

  @override
  void dispose() {
    _authApiClient.close();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();
    final password = _passwordController.text;

    if ([name, email, phone, city, password].any((value) => value.isEmpty)) {
      _showError('Tous les champs sont obligatoires.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = await _authApiClient.register(
        nomComplet: name,
        email: email,
        telephone: phone,
        ville: city,
        role: _backendRole,
        password: password,
      );

      if (!mounted) return;
      _openHome(session);
    } on AuthApiException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Backend indisponible. Verifiez que NestJS est lance.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openHome(AuthSession session) {
    AuthSessionStore.save(session);

    final target = session.isTrainer
        ? const TrainerRootPage()
        : const RiderRootPage();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => target),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Inscription',
      subtitle: widget.role,
      showBack: true,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nom complet',
            hintText: 'Ahmed Ben Said',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'ahmed@gmail.com',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telephone',
            hintText: '22 123 456',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'Ville',
            hintText: 'Sousse',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: false,
          decoration: InputDecoration(labelText: 'Role', hintText: widget.role),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mot de passe'),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: _isLoading ? 'Creation...' : 'Creer le compte',
          onPressed: _isLoading ? null : _register,
        ),
      ],
    );
  }
}
