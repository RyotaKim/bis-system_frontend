import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // added for kDebugMode
import 'login_page.dart'; // use the existing LoginPage instead of AdminLoginPage

// Converted to StatefulWidget so we can show a one-time debug notice.
class ResidentMainPage extends StatefulWidget {
  const ResidentMainPage({super.key});

  @override
  State<ResidentMainPage> createState() => _ResidentMainPageState();
}

class _ResidentMainPageState extends State<ResidentMainPage> {
  bool _devNoticeShown = false;

  @override
  void initState() {
    super.initState();
    // Show a one-time, non-intrusive debug SnackBar explaining the DevTools messages.
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_devNoticeShown && mounted) {
          _devNoticeShown = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 6),
              content: Text(
                'DevTools/VM service messages are emitted by Flutter tooling during hot reload/restart. '
                'They are usually benign for web/debug configurations and do not affect app behavior.',
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color green = const Color(0xFF2E7D32);
    final Color lightGreen = const Color(0xFFDCEED9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top navigation bar (centered) with Admin button on the right
          Container(
            color: green,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _navText('Home'),
                      const SizedBox(width: 28),
                      _navText('Request'),
                      const SizedBox(width: 28),
                      _navText('About'),
                      const SizedBox(width: 28),
                      _navText('Contact'),
                    ],
                  ),
                ),

                // Debug-only info button (right side)
                if (kDebugMode)
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    tooltip: 'DevTools info',
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('DevTools / VM service info'),
                            content: const Text(
                              'The runtime messages about DevTools / VM service are emitted by Flutter tooling during '
                              'hot restart/hot reload. They indicate the IDE/tooling did not set deep-link metadata for '
                              'DevTools in this session. This is usually benign for web or certain debug configurations.\n\n'
                              'To get DevTools deep links, run with a debug configuration that exposes the VM service (e.g. '
                              '`flutter run` with supported options) or attach via your IDE\'s Flutter tools.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                // Admin button aligned to the right
                TextButton(
                  onPressed: () {
                    // Navigate to the existing LoginPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Admin'),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Container(
              width: double.infinity,
              color: lightGreen,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Seal / logo
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black54, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          // Replace with AssetImage('assets/seal.png') when available
                          child: Icon(Icons.account_balance,
                              size: 64, color: green),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Titles
                      Text(
                        'Barangay San Jose 1',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Noveleta, Cavite',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome, Resident!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Action buttons
                      Wrap(
                        spacing: 18,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Show file-a-request dialog
                                final _formKey = GlobalKey<FormState>();
                                final fullNameCtrl = TextEditingController();
                                final addressCtrl = TextEditingController();
                                final purposeCtrl = TextEditingController();
                                final eduAttainCtrl = TextEditingController();
                                final eduCourseCtrl = TextEditingController();
                                final ageCtrl = TextEditingController();
                                final maritalCtrl = TextEditingController();
                                String docType = 'Barangay Clearance';
                                String? uploadedFile;

                                showDialog<void>(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        // Larger responsive dialog
                                        final maxWidth =
                                            MediaQuery.of(context).size.width *
                                                0.85;
                                        final maxHeight =
                                            MediaQuery.of(context).size.height *
                                                0.85;
                                        return Dialog(
                                          insetPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 24),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: maxWidth < 900
                                                  ? maxWidth
                                                  : 900,
                                              maxHeight: maxHeight < 900
                                                  ? maxHeight
                                                  : 900,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Title
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 8.0),
                                                    child: Text(
                                                        'File a Request',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),

                                                  // Form area (scrollable if tall)
                                                  Expanded(
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Form(
                                                        key: _formKey,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            TextFormField(
                                                              controller:
                                                                  fullNameCtrl,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Full Name'),
                                                              validator: (v) =>
                                                                  (v == null ||
                                                                          v.isEmpty)
                                                                      ? 'Required'
                                                                      : null,
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            TextFormField(
                                                              controller:
                                                                  addressCtrl,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Address'),
                                                              validator: (v) =>
                                                                  (v == null ||
                                                                          v.isEmpty)
                                                                      ? 'Required'
                                                                      : null,
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            TextFormField(
                                                              controller:
                                                                  purposeCtrl,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Purpose'),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            TextFormField(
                                                              controller:
                                                                  eduAttainCtrl,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Educational Attainment'),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            TextFormField(
                                                              controller:
                                                                  eduCourseCtrl,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Educational Course'),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            TextFormField(
                                                              controller:
                                                                  ageCtrl,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Age'),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            TextFormField(
                                                              controller:
                                                                  maritalCtrl,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Marital Status'),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            DropdownButtonFormField<
                                                                String>(
                                                              value: docType,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Type of Document'),
                                                              items: <String>[
                                                                'Barangay Clearance',
                                                                'Business Permit',
                                                                'Certificate of Indigency',
                                                                'First time job seeker'
                                                              ]
                                                                  .map((d) =>
                                                                      DropdownMenuItem(
                                                                          value:
                                                                              d,
                                                                          child:
                                                                              Text(d)))
                                                                  .toList(),
                                                              onChanged: (v) {
                                                                if (v != null)
                                                                  setState(() =>
                                                                      docType =
                                                                          v);
                                                              },
                                                            ),
                                                            const SizedBox(
                                                                height: 12),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    uploadedFile ??
                                                                        'No file selected',
                                                                    style: TextStyle(
                                                                        color: uploadedFile ==
                                                                                null
                                                                            ? Colors.grey
                                                                            : Colors.black),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    // Placeholder upload: replace with file picker later
                                                                    setState(() =>
                                                                        uploadedFile =
                                                                            'document.pdf');
                                                                  },
                                                                  child: const Text(
                                                                      'Upload'),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 12),

                                                  // Actions
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          if (_formKey
                                                                  .currentState
                                                                  ?.validate() ??
                                                              false) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Request submitted for ${fullNameCtrl.text}'),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Submit'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.post_add, size: 22),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('File a Request',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 26),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to the requests page to check status
                                Navigator.pushNamed(context, '/requests');
                              },
                              icon: const Icon(Icons.search, size: 22),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Check Request Status',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green.withOpacity(0.92),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navText(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
