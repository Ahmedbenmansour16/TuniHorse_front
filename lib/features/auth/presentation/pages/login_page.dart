import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/horseshoe_mark.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/data/auth_api_client.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';
import 'package:tunihorse/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:tunihorse/features/auth/presentation/pages/role_choice_page.dart';
import 'package:tunihorse/features/rider/presentation/pages/rider_root_page.dart';
import 'package:tunihorse/features/trainer/presentation/pages/trainer_root_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authApiClient = AuthApiClient();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _authApiClient.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Email et mot de passe obligatoires.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = await _authApiClient.login(
        email: email,
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
      title: 'TuniHorse',
      showBack: true,
      children: [
        const SizedBox(height: 8),
        const Center(child: HorseshoeMark(size: 62, color: AppColors.green)),
        const SizedBox(height: 18),
        const Text(
          'Bienvenue !',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        const Text(
          'Connectez-vous pour continuer',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'exemple@gmail.com',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mot de passe',
            suffixIcon: Icon(Icons.visibility_outlined),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => openPage(context, const ForgotPasswordPage()),
            child: const Text('Mot de passe oublie ?'),
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: _isLoading ? 'Connexion...' : 'Se connecter',
          onPressed: _isLoading ? null : _login,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pas encore de compte ?'),
            TextButton(
              onPressed: () => openPage(context, const RoleChoicePage()),
              child: const Text('Creer un compte'),
            ),
          ],
        ),
      ],
    );
  }
}
