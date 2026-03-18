import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PremiumSuccessScreen extends StatelessWidget {
  const PremiumSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: "premium_icon",
              child: SizedBox(
                height: 150,
                child: Lottie.asset("assets/success.json", repeat: false),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Bienvenue Premium 🎉",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Votre abonnement est activé avec succès.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Continuer"),
            ),
          ],
        ),
      ),
    );
  }
}
