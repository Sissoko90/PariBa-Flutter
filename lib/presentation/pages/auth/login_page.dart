import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

/// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController =
      TextEditingController(); // Changé de _emailController
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isPhoneLogin = false; // Nouveau: pour suivre le mode de connexion

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final identifier = _identifierController.text.trim();

      context.read<AuthBloc>().add(
        LoginEvent(
          identifier: identifier, // Utiliser identifier au lieu de email
          password: _passwordController.text,
        ),
      );
    }
  }

  void _toggleLoginMethod() {
    setState(() {
      _isPhoneLogin = !_isPhoneLogin;
      _identifierController.clear();
    });
  }

  String? _identifierValidator(String? value) {
    if (value == null || value.isEmpty) {
      return _isPhoneLogin
          ? 'Le numéro de téléphone est requis'
          : 'L\'email est requis';
    }

    if (_isPhoneLogin) {
      return Validators.phone(value);
    } else {
      return Validators.email(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    Icon(
                      Icons.account_balance_wallet,
                      size: 80,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Bienvenue sur PariBa',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Connectez-vous pour continuer',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Toggle Button pour changer entre email et téléphone
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: isLoading ? null : _toggleLoginMethod,
                        icon: Icon(
                          _isPhoneLogin
                              ? Icons.email_outlined
                              : Icons.phone_outlined,
                          size: 16,
                        ),
                        label: Text(
                          _isPhoneLogin
                              ? 'Utiliser l\'email'
                              : 'Utiliser le téléphone',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Email/Phone Field
                    CustomTextField(
                      controller: _identifierController,
                      label: _isPhoneLogin ? 'Téléphone' : 'Email',
                      hint: _isPhoneLogin
                          ? '+223 00 00 00 00'
                          : 'votre@email.com',
                      keyboardType: _isPhoneLogin
                          ? TextInputType.phone
                          : TextInputType.emailAddress,
                      prefixIcon: _isPhoneLogin
                          ? Icons.phone_outlined
                          : Icons.email_outlined,
                      validator: _identifierValidator,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) => Validators.required(
                        value,
                        fieldName: 'Le mot de passe',
                      ),
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 8),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage(),
                                  ),
                                );
                              },
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    CustomButton(
                      text: 'Se connecter',
                      onPressed: isLoading ? null : _handleLogin,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pas encore de compte ? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                          child: const Text('S\'inscrire'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
