import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/services/auth_service.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'package:pariba/di/injection.dart' as di;
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
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _isPhoneLogin = false;
  bool _isOtpSent = false;
  String? _otpTarget;
  bool _isSendingOtp = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Envoyer l'OTP avant login
  Future<void> _sendOtp() async {
    if (_identifierController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre email ou téléphone'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    final target = _identifierController.text.trim();
    _otpTarget = target;

    try {
      // Récupérer le repository depuis le contexte
      final authRepository = di.sl<AuthRepository>();

      // Appeler l'envoi d'OTP
      await authRepository.sendOtp(target: target);

      if (mounted) {
        setState(() => _isOtpSent = true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Code OTP envoyé à ${_isPhoneLogin ? target : target}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingOtp = false);
      }
    }
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Si l'OTP n'a pas encore été envoyé, l'envoyer d'abord
      if (!_isOtpSent) {
        _sendOtp();
        return;
      }

      // Vérifier que l'OTP est rempli
      final otpCode = _otpController.text.trim();
      if (otpCode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez entrer le code OTP reçu'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final identifier = _identifierController.text.trim();

      context.read<AuthBloc>().add(
        LoginEvent(
          identifier: identifier,
          password: _passwordController.text,
          otpCode: otpCode, // Passer l'OTP
        ),
      );
    }
  }

  void _toggleLoginMethod() {
    setState(() {
      _isPhoneLogin = !_isPhoneLogin;
      _identifierController.clear();
      // Réinitialiser l'état OTP quand on change de méthode
      _isOtpSent = false;
      _otpController.clear();
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
                  duration: const Duration(seconds: 4),
                ),
              );

              // Réinitialiser sur erreur OTP pour permettre un nouvel envoi
              if (state.message.toLowerCase().contains('otp') ||
                  state.message.toLowerCase().contains('code')) {
                setState(() {
                  _isOtpSent = false;
                  _otpController.clear();
                });
              }
            }

            // Si login réussi, ne rien faire (le bloc va naviguer)
            if (state is Authenticated) {
              // Le bloc gère déjà la navigation ou l'état
              print('✅ Login réussi, utilisateur authentifié');
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
                    if (!_isOtpSent) ...[
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
                    ],

                    const SizedBox(height: 8),

                    // Email/Phone Field - Désactivé après envoi OTP
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
                      enabled: !isLoading && !_isOtpSent,
                    ),

                    const SizedBox(height: 16),

                    // Password Field - Toujours actif
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

                    const SizedBox(height: 16),

                    // Champ OTP - Visible seulement après envoi
                    if (_isOtpSent) ...[
                      CustomTextField(
                        controller: _otpController,
                        label: 'Code OTP',
                        hint: '123456',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.security_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Code OTP requis';
                          }
                          if (value.length != 6) {
                            return 'Le code doit contenir 6 chiffres';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),

                      const SizedBox(height: 8),

                      // Bouton renvoyer OTP
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading || _isSendingOtp
                              ? null
                              : _sendOtp,
                          child: Text(
                            _isSendingOtp
                                ? 'Envoi en cours...'
                                : 'Renvoyer le code',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],

                    // Mot de passe oublié (caché pendant le flow OTP)
                    if (!_isOtpSent) ...[
                      const SizedBox(height: 8),
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
                    ],

                    const SizedBox(height: 24),

                    // Login/Envoyer Button
                    CustomButton(
                      text: _isOtpSent ? 'Se connecter' : 'Envoyer le code',
                      onPressed: isLoading || _isSendingOtp
                          ? null
                          : _handleLogin,
                      isLoading: isLoading || _isSendingOtp,
                    ),

                    const SizedBox(height: 24),

                    // Register Link (caché pendant le flow OTP)
                    if (!_isOtpSent) ...[
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

                    // Indicateur de mode développement
                    if (_isOtpSent && !isLoading) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Mode développement: Le code OTP est affiché dans la console du terminal',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
