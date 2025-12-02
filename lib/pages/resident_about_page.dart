import 'package:flutter/material.dart';

class ResidentAboutPage extends StatelessWidget {
  const ResidentAboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF2E7D32);
    const Color lightGreen = Color(0xFFDCEED9);

    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: const Text('About'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: green, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/barangay_logo.png',
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.account_balance,
                                  size: 80,
                                  color: green,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Barangay San Jose 1',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: green,
                        ),
                      ),
                      const Text(
                        'Noveleta, Cavite',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // System Overview
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: green, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              'About the System',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'The Barangay Information System is your one-stop platform for requesting barangay documents online. No need to wait in long queues – submit your requests anytime, anywhere, and track their status in real-time.',
                          style: TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Available Documents
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, color: green, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              'Available Documents',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDocumentItem('Barangay Clearance',
                            'For employment, scholarship, and other purposes'),
                        _buildDocumentItem('Business Permit',
                            'Required for operating businesses within the barangay'),
                        _buildDocumentItem('Certificate of Indigency',
                            'For residents belonging to low-income category'),
                        _buildDocumentItem('First-time Job Seeker Certificate',
                            'For first-time job seekers (RA 11261)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // How to Use
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline, color: green, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              'How to Use the System',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStep('1', 'Fill out the request form',
                            'Provide your complete information and select the document type'),
                        _buildStep('2', 'Upload your valid ID',
                            'Upload a clear photo of your ID that shows your address'),
                        _buildStep('3', 'Submit your request',
                            'You will receive a reference number – save it!'),
                        _buildStep('4', 'Track your request',
                            'Use your reference number to check the status anytime'),
                        _buildStep('5', 'Claim your document',
                            'Visit the barangay office once your request is approved'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contact Information
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.contact_mail, color: green, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              'Contact Us',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(Icons.location_on, 'Address',
                            'Barangay San Jose 1, Noveleta, Cavite'),
                        _buildContactItem(
                            Icons.phone, 'Contact Number', '(046) 123-4567'),
                        _buildContactItem(Icons.email, 'Email',
                            'barangaysanjose1@noveleta.gov.ph'),
                        _buildContactItem(Icons.access_time, 'Office Hours',
                            'Monday - Friday, 8:00 AM - 5:00 PM'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Footer
                Center(
                  child: Text(
                    '© ${DateTime.now().year} Barangay San Jose 1. All rights reserved.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
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

  Widget _buildDocumentItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    const Color green = Color(0xFF2E7D32);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    const Color green = Color(0xFF2E7D32);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
