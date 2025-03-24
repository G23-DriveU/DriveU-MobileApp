import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SafetyFeaturesPage extends StatelessWidget {
  const SafetyFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safety Features"),
      ),
      body: Container(
        // Use a BoxDecoration to ensure the gradient covers the entire screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 203, 232, 246), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(  // Prevent overflow of right pixels

          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle("In Case of Emergency"),
                _buildInfoRow("🚨 911 Emergency", "Call if you're in immediate danger"),
                _buildInfoRow("🛡️ Ride Dispute", "Call support for ride issues"),
                _buildInfoRow("🚫 Harassment", "Report incidents to 1-800-799-SAFE"),
                _buildInfoRow("🚑 Accident Support", "Call (850) 617-2000 for accident assistance"),
                const SizedBox(height: 25),
                
                _buildSectionTitle("Important Hotlines"),
                _buildInfoRow("📞 Victim Services", "1-800-799-SAFE for support"),
                _buildInfoRow("🆘 Rider Assistance", "1-800-555-HELP for ride problems"),
                const SizedBox(height: 25),

                // Bold text instead of button
                const Text(
                  "If you're in immediate danger, call 911.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(duration: 700.ms).slideY(),
                const SizedBox(height: 25),

                // Additional information for user enhancement
                const Text(
                  "Additional Safety Tips:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                const Text(
                  "1. Always share your ride details with a friend or family member.\n"
                  "2. Verify the driver's identity and vehicle before getting in.\n"
                  "3. Trust your instincts; if something feels off, don't hesitate to cancel the ride.\n"
                  "4. Keep your phone charged and have emergency contacts easily accessible.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            decoration: TextDecoration.underline,
          ),
        ),
      ).animate().fade(duration: 500.ms),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(  // Use Expanded to prevent overflow
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),  // Add some spacing
          Expanded(  // Use Expanded to prevent overflow
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.end,  // Align text to the end
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms);
  }
}
