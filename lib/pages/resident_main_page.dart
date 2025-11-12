import 'package:flutter/material.dart';
import 'login_page.dart'; // use the existing LoginPage instead of AdminLoginPage

// Converted to StatefulWidget (kept) — removed debug-only snack & flag.
class ResidentMainPage extends StatefulWidget {
  const ResidentMainPage({super.key});

  @override
  State<ResidentMainPage> createState() => _ResidentMainPageState();
}

class _ResidentMainPageState extends State<ResidentMainPage> {
  // Add an in-memory list to keep submitted requests (includes encoded date)
  final List<Map<String, dynamic>> _submittedRequests = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _eduAttainController = TextEditingController();
  final TextEditingController _eduCourseController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _maritalController = TextEditingController();
  String docType = 'Barangay Clearance';
  String? uploadedFile;

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF2E7D32);
    const Color lightGreen = Color(0xFFDCEED9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top navigation bar (centered) with Admin button on the right
          LayoutBuilder(builder: (context, constraints) {
            // Consider wide when there's ample horizontal space; mobile keeps original sizing
            final isWide = constraints.maxWidth >= 700;
            final double verticalPadding = isWide ? 22.0 : 14.0;
            final double horizontalPadding = isWide ? 20.0 : 12.0;
            final double navFontSize = isWide ? 20.0 : 18.0;
            final EdgeInsets navPadding = EdgeInsets.symmetric(
                horizontal: isWide ? 28.0 : 24.0,
                vertical: isWide ? 20.0 : 16.0);

            return Container(
              color: green,
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Builder(builder: (context) {
                      if (!isWide) {
                        // Mobile: show a larger menu icon aligned to the right
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu,
                                  color: Colors.white, size: 36),
                              iconSize: 36,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              splashRadius: 28,
                              tooltip: 'Menu',
                              onPressed: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      insetPadding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 24),
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 400),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('Menu',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              const SizedBox(height: 12),
                                              ListTile(
                                                leading: const Icon(Icons.home),
                                                title: const Text('Home',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              'Home page selected')));
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.info),
                                                title: const Text('About',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              'About page selected')));
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.contact_mail),
                                                title: const Text('Contact',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              'Contact page selected')));
                                                },
                                              ),
                                              const SizedBox(height: 6),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Close'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      }

                      // Wide: show inline nav buttons
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Home page selected')),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: navPadding,
                              textStyle: TextStyle(fontSize: navFontSize),
                            ),
                            child: _navText('Home'),
                          ),
                          const SizedBox(
                              width: 36), // spacing between nav items
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('About page selected')),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: navPadding,
                              textStyle: TextStyle(fontSize: navFontSize),
                            ),
                            child: _navText('About'),
                          ),
                          const SizedBox(width: 36),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Contact page selected')),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: navPadding,
                              textStyle: TextStyle(fontSize: navFontSize),
                            ),
                            child: _navText('Contact'),
                          ),
                        ],
                      );
                    }),
                  ),

                  // Admin button aligned to the right (DevTools info button removed)
                  // Visible only on wide screens
                  Visibility(
                    visible: isWide,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to the existing LoginPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 14.0 : 12.0,
                            vertical: isWide ? 12.0 : 8.0),
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isWide ? 18.0 : 14.0),
                      ),
                      child: const Text('Admin'),
                    ),
                  ),
                ],
              ),
            );
          }),

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
                          border: Border.all(color: Colors.black54, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 90, // increased size
                          backgroundColor: Colors.white,
                          // use barangay logo asset; clipped to circle and with fallback icon
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/barangay_logo.png',
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // fallback to icon if asset not found
                                return const Icon(
                                  Icons.account_balance,
                                  size: 96,
                                  color: green,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Titles
                      const Text(
                        'Barangay San Jose 1',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Noveleta, Cavite',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Welcome, Resident!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Action buttons (lowered and larger)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 14,
                          alignment: WrapAlignment.center,
                          children: [
                            SizedBox(
                              width: 320,
                              height: 64,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Show file-a-request dialog
                                  final formKey = GlobalKey<FormState>();

                                  showDialog<void>(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          // Larger responsive dialog
                                          final maxWidth =
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85;
                                          final maxHeight =
                                              MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.85;
                                          return Dialog(
                                            insetPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 24),
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
                                                          key: formKey,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextFormField(
                                                                controller:
                                                                    _nameController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Full Name',
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12),
                                                                ),
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
                                                                    _contactController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Contact Number',
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12),
                                                                ),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .phone,
                                                                validator: (v) {
                                                                  // Basic validation for contact number
                                                                  if (v ==
                                                                          null ||
                                                                      v
                                                                          .isEmpty) {
                                                                    return 'Required';
                                                                  } else if (v
                                                                          .length <
                                                                      10) {
                                                                    return 'Invalid number';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              TextFormField(
                                                                controller:
                                                                    _addressController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Address',
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12),
                                                                ),
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
                                                                    _purposeController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Purpose',
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              TextFormField(
                                                                controller:
                                                                    _eduAttainController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Educational Attainment',
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              TextFormField(
                                                                controller:
                                                                    _eduCourseController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Educational Course',
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              TextFormField(
                                                                controller:
                                                                    _ageController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Age',
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12),
                                                                ),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              TextFormField(
                                                                controller:
                                                                    _maritalController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Marital Status',
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              DropdownButtonFormField<
                                                                  String>(
                                                                initialValue:
                                                                    docType,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Type of Document',
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12),
                                                                ),
                                                                items: <String>[
                                                                  'Barangay Clearance',
                                                                  'Business Permit',
                                                                  'Certificate of Indigency',
                                                                  'First time job seeker'
                                                                ]
                                                                    .map((d) => DropdownMenuItem(
                                                                        value:
                                                                            d,
                                                                        child: Text(
                                                                            d)))
                                                                    .toList(),
                                                                onChanged: (v) {
                                                                  if (v !=
                                                                      null) {
                                                                    setState(() =>
                                                                        docType =
                                                                            v);
                                                                  }
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  height: 12),
                                                              // Instructional note for the upload field
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            8.0),
                                                                child: Text(
                                                                  'Upload a picture of your valid id that certifies your residency.',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      uploadedFile ??
                                                                          'No file selected',
                                                                      style: TextStyle(
                                                                          color: uploadedFile == null
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
                                                        const SizedBox(
                                                            width: 8),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            if (formKey
                                                                    .currentState
                                                                    ?.validate() ??
                                                                false) {
                                                              // Encode current date as ISO string and save the request
                                                              final isoDate =
                                                                  DateTime.now()
                                                                      .toIso8601String();
                                                              // Generate a simple reference number
                                                              final refNo =
                                                                  'RN${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
                                                              // Add to in-memory list for results display
                                                              // Use outer State's setState to ensure stored data persists
                                                              this.setState(() {
                                                                _submittedRequests
                                                                    .add({
                                                                  'refNo':
                                                                      refNo,
                                                                  'fullName':
                                                                      _nameController
                                                                          .text,
                                                                  'contactNumber':
                                                                      _contactController
                                                                          .text,
                                                                  'address':
                                                                      _addressController
                                                                          .text,
                                                                  'purpose':
                                                                      _purposeController
                                                                          .text,
                                                                  'eduAttainment':
                                                                      _eduAttainController
                                                                          .text,
                                                                  'eduCourse':
                                                                      _eduCourseController
                                                                          .text,
                                                                  'age':
                                                                      _ageController
                                                                          .text,
                                                                  'maritalStatus':
                                                                      _maritalController
                                                                          .text,
                                                                  'docType':
                                                                      docType,
                                                                  'uploadedFile':
                                                                      uploadedFile,
                                                                  'date':
                                                                      isoDate, // encoded date
                                                                  'status':
                                                                      'Pending',
                                                                });
                                                              });

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();

                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                      'Request submitted for ${_nameController.text} on ${DateTime.parse(isoDate).toLocal().toString().split('.').first}'),
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
                                icon: const Icon(Icons.post_add,
                                    size: 26, color: Colors.white),
                                label: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text('File a Request',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              height: 64,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Show results dialog with submitted requests and their dates
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) {
                                      final TextEditingController
                                          searchController =
                                          TextEditingController();
                                      Map<String, dynamic>? found;
                                      return StatefulBuilder(
                                          builder: (c, setC) {
                                        return Dialog(
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              maxHeight: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.8,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Request Status',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextField(
                                                          controller:
                                                              searchController,
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText:
                                                                'Reference Number',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          final q =
                                                              searchController
                                                                  .text
                                                                  .trim();
                                                          final match = _submittedRequests
                                                              .firstWhere(
                                                                  (r) =>
                                                                      r['refNo'] ==
                                                                      q,
                                                                  orElse: () =>
                                                                      <String,
                                                                          dynamic>{});
                                                          setC(() {
                                                            found =
                                                                match.isEmpty
                                                                    ? null
                                                                    : match;
                                                          });
                                                        },
                                                        child: const Text(
                                                            'Search'),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Expanded(
                                                    child: found == null
                                                        ? Center(
                                                            child: Text(
                                                              'Enter your reference number to see the request status.',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      700]),
                                                            ),
                                                          )
                                                        : Card(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      12.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'Reference: ${found!['refNo']}',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          6),
                                                                  Text(
                                                                      'Name: ${found!['fullName'] ?? '-'}'),
                                                                  const SizedBox(
                                                                      height:
                                                                          4),
                                                                  Text(
                                                                      'Document: ${found!['docType'] ?? '-'}'),
                                                                  const SizedBox(
                                                                      height:
                                                                          8),
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                8,
                                                                            vertical:
                                                                                4),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: (found!['status'] == 'Released')
                                                                              ? Colors.blue.shade100
                                                                              : (found!['status'] == 'Approved')
                                                                                  ? Colors.green.shade100
                                                                                  : Colors.orange.shade100,
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          found!['status'] ??
                                                                              'Pending',
                                                                          style:
                                                                              TextStyle(
                                                                            color: (found!['status'] == 'Released')
                                                                                ? Colors.blue.shade800
                                                                                : (found!['status'] == 'Approved')
                                                                                    ? Colors.green.shade800
                                                                                    : Colors.orange.shade800,
                                                                            fontWeight:
                                                                                FontWeight.bold,
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
                                                  const SizedBox(height: 12),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child:
                                                          const Text('Close'),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                  );
                                },
                                icon: const Icon(Icons.search,
                                    size: 26, color: Colors.white),
                                label: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text('Check Request Status',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: green.withOpacity(0.92),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
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
        fontSize: 18, // increased from 15
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _purposeController.dispose();
    _eduAttainController.dispose();
    _eduCourseController.dispose();
    _ageController.dispose();
    _maritalController.dispose();
    super.dispose();
  }
}
