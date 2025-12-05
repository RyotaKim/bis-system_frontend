import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart'; // use the existing LoginPage instead of AdminLoginPage
import 'resident_about_page.dart';
import '../services/request_service.dart';
import '../models/document_type_model.dart';
import '../config/api_config.dart';

// Converted to StatefulWidget (kept) — removed debug-only snack & flag.
class ResidentMainPage extends StatefulWidget {
  const ResidentMainPage({super.key});

  @override
  State<ResidentMainPage> createState() => _ResidentMainPageState();
}

class _ResidentMainPageState extends State<ResidentMainPage> {
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _eduAttainController = TextEditingController();
  final TextEditingController _eduCourseController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _maritalController = TextEditingController();
  String docType = 'Barangay Clearance';
  File? _selectedImage;
  String? _selectedImageName;
  List<int>? _webImageBytes; // For web platform
  final RequestService _requestService = RequestService();
  List<DocumentType> _documentTypes = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDocumentTypes();
  }

  Future<void> _loadDocumentTypes() async {
    try {
      final types = await _requestService.getDocumentTypes();
      setState(() {
        _documentTypes = types.map((t) => DocumentType.fromJson(t)).toList();
        if (_documentTypes.isNotEmpty) {
          docType = _documentTypes[0].name;
          print('Loaded ${_documentTypes.length} document types from backend');
          // Debug: Print document types and their required fields
          for (var dt in _documentTypes) {
            print(
                'Document Type: ${dt.name}, Required Fields: ${dt.requiredFields}');
          }
        }
      });
    } catch (e) {
      // Don't show error for document types - we'll use fallback
      print('Could not load document types from backend: $e');
        print(
          'Using fallback document type mapping. Ensure backend is running at ${ApiConfig.baseUrl}');
    }
  }

  Future<void> _pickImage() async {
    if (!mounted) return;

    try {
      // Create a new ImagePicker instance
      final picker = ImagePicker();

      // Attempt to pick an image
      final XFile? pickedFile = await picker
          .pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      )
          .catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open image picker: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      });

      if (pickedFile == null) {
        return; // User cancelled or error occurred
      }

      // Read file as bytes (works on all platforms)
      final bytes = await pickedFile.readAsBytes();
      final fileSize = bytes.length;

      // Check file size (max 5MB)
      if (fileSize > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image too large. Maximum size is 5MB.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // On web, we'll use bytes; on mobile, we'll use File
      if (kIsWeb) {
        setState(() {
          _webImageBytes = bytes;
          _selectedImageName = pickedFile.name;
          _selectedImage = null; // Clear File reference on web
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedImageName = pickedFile.name;
          _webImageBytes = null;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected: ${pickedFile.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Check if the selected document type requires a specific field
  bool _isFieldRequired(String fieldName) {
    print('DEBUG: ============================================');
    print('DEBUG: Checking if "$fieldName" is required');
    print('DEBUG: Current docType: "$docType"');
    print('DEBUG: _documentTypes.isEmpty: ${_documentTypes.isEmpty}');
    print('DEBUG: Number of document types loaded: ${_documentTypes.length}');

    // Handle fallback case when backend is not loaded
    if (_documentTypes.isEmpty) {
      print('DEBUG: Using FALLBACK mode (backend not loaded)');
      // For First-time Job Seeker, education fields are required
      if ((docType == 'First-time Job Seeker' ||
              docType == 'First Time Job Seeker Form') &&
          (fieldName == 'eduAttainment' || fieldName == 'eduCourse')) {
        print('DEBUG: ✓ FALLBACK - $fieldName IS REQUIRED for "$docType"');
        return true;
      }
      print('DEBUG: ✗ FALLBACK - $fieldName is NOT required for "$docType"');
      return false;
    }

    print('DEBUG: Using BACKEND mode (${_documentTypes.length} types loaded)');
    final selectedDocType = _documentTypes.firstWhere(
      (dt) {
        print('DEBUG: Comparing "$docType" with "${dt.name}"');
        return dt.name == docType;
      },
      orElse: () {
        print(
            'DEBUG: No match found, using first document type: ${_documentTypes.first.name}');
        return _documentTypes.first;
      },
    );

    print('DEBUG: Selected document type: "${selectedDocType.name}"');
    print(
        'DEBUG: Required fields from backend: ${selectedDocType.requiredFields}');

    // Check backend required fields first
    final isRequired = selectedDocType.isFieldRequired(fieldName);

    // TEMPORARY FIX: If backend doesn't have requiredFields configured,
    // manually check for First Time Job Seeker variants
    if (!isRequired &&
        (selectedDocType.name == 'First-time Job Seeker' ||
            selectedDocType.name == 'First Time Job Seeker Form') &&
        (fieldName == 'eduAttainment' || fieldName == 'eduCourse')) {
      print(
          'DEBUG: ✓ OVERRIDE - $fieldName IS REQUIRED for job seeker form (backend config missing)');
      return true;
    }

    print('DEBUG: Result - $fieldName required: $isRequired');
    print('DEBUG: ============================================');

    return isRequired;
  }

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
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ResidentAboutPage(),
                                                    ),
                                                  );
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ResidentAboutPage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: navPadding,
                              textStyle: TextStyle(fontSize: navFontSize),
                            ),
                            child: _navText('About'),
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

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 600;
                            final buttonWidth = isMobile
                                ? (constraints.maxWidth > 320
                                    ? 320.0
                                    : constraints.maxWidth - 40)
                                : 320.0;

                            return Wrap(
                              spacing: 20,
                              runSpacing: 14,
                              alignment: WrapAlignment.center,
                              children: [
                                SizedBox(
                                  width: buttonWidth,
                                  height: isMobile ? 56 : 64,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Show file-a-request dialog
                                      final formKey = GlobalKey<FormState>();

                                      showDialog<void>(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              // Responsive sizing
                                              final screenWidth =
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width;
                                              final screenHeight =
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height;
                                              final isMobile =
                                                  screenWidth < 600;

                                              return Dialog(
                                                insetPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal:
                                                            isMobile ? 16 : 40,
                                                        vertical:
                                                            isMobile ? 20 : 40),
                                                child: Container(
                                                  width: isMobile
                                                      ? screenWidth - 32
                                                      : (screenWidth > 900
                                                          ? 900
                                                          : screenWidth * 0.85),
                                                  constraints: BoxConstraints(
                                                    maxHeight: screenHeight -
                                                        (isMobile ? 40 : 80),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                        isMobile ? 16.0 : 24.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // Title with close button
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                'File a Request',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      isMobile
                                                                          ? 18
                                                                          : 22,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons.close),
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  const BoxConstraints(),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                            height: isMobile
                                                                ? 8
                                                                : 12),

                                                        // Data Privacy Notice
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFFE8F5E9),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                              color: const Color(
                                                                      0xFF2E7D32)
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .privacy_tip_outlined,
                                                                color: Color(
                                                                    0xFF2E7D32),
                                                                size: 20,
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Data Privacy Notice',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize: isMobile
                                                                            ? 12
                                                                            : 13,
                                                                        color: const Color(
                                                                            0xFF2E7D32),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            4),
                                                                    Text(
                                                                      'Your personal information is protected under the Data Privacy Act of 2012 (RA 10173). All data collected will be used solely for processing your barangay document request and will be kept confidential and secure.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize: isMobile
                                                                            ? 11
                                                                            : 12,
                                                                        color: Colors
                                                                            .black87,
                                                                        height:
                                                                            1.4,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height: isMobile
                                                                ? 12
                                                                : 16),

                                                        // Form area (scrollable)
                                                        Expanded(
                                                          child:
                                                              SingleChildScrollView(
                                                            padding:
                                                                EdgeInsets.only(
                                                              bottom: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets
                                                                  .bottom,
                                                            ),
                                                            child: Form(
                                                              key: formKey,
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  TextFormField(
                                                                    controller:
                                                                        _lastNameController,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'Last Name',
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              12,
                                                                          vertical:
                                                                              12),
                                                                    ),
                                                                    validator: (v) => (v ==
                                                                                null ||
                                                                            v.isEmpty)
                                                                        ? 'Required'
                                                                        : null,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          8),
                                                                  TextFormField(
                                                                    controller:
                                                                        _firstNameController,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'First Name',
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              12,
                                                                          vertical:
                                                                              12),
                                                                    ),
                                                                    validator: (v) => (v ==
                                                                                null ||
                                                                            v.isEmpty)
                                                                        ? 'Required'
                                                                        : null,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          8),
                                                                  TextFormField(
                                                                    controller:
                                                                        _middleInitialController,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'Middle Initial (Optional)',
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              12,
                                                                          vertical:
                                                                              12),
                                                                    ),
                                                                    maxLength:
                                                                        1,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          8),
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
                                                                            BorderRadius.circular(8),
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
                                                                    validator:
                                                                        (v) {
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
                                                                      height:
                                                                          8),
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
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              12,
                                                                          vertical:
                                                                              12),
                                                                    ),
                                                                    validator: (v) => (v ==
                                                                                null ||
                                                                            v.isEmpty)
                                                                        ? 'Required'
                                                                        : null,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          8),
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
                                                                            BorderRadius.circular(8),
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
                                                                      height:
                                                                          8),
                                                                  // Educational Attainment - Only show if required by document type
                                                                  if (_isFieldRequired(
                                                                      'eduAttainment'))
                                                                    TextFormField(
                                                                      controller:
                                                                          _eduAttainController,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Educational Attainment *',
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                12,
                                                                            vertical:
                                                                                12),
                                                                      ),
                                                                      validator: (v) => _isFieldRequired('eduAttainment') &&
                                                                              (v == null || v.isEmpty)
                                                                          ? 'Required for this document type'
                                                                          : null,
                                                                    ),
                                                                  if (_isFieldRequired(
                                                                      'eduAttainment'))
                                                                    const SizedBox(
                                                                        height:
                                                                            8),
                                                                  // Educational Course - Only show if required by document type
                                                                  if (_isFieldRequired(
                                                                      'eduCourse'))
                                                                    TextFormField(
                                                                      controller:
                                                                          _eduCourseController,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Educational Course *',
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                12,
                                                                            vertical:
                                                                                12),
                                                                      ),
                                                                      validator: (v) => _isFieldRequired('eduCourse') &&
                                                                              (v == null || v.isEmpty)
                                                                          ? 'Required for this document type'
                                                                          : null,
                                                                    ),
                                                                  if (_isFieldRequired(
                                                                      'eduCourse'))
                                                                    const SizedBox(
                                                                        height:
                                                                            8),
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
                                                                            BorderRadius.circular(8),
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
                                                                      height:
                                                                          8),
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
                                                                            BorderRadius.circular(8),
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
                                                                      height:
                                                                          8),
                                                                  DropdownButtonFormField<
                                                                      String>(
                                                                    value:
                                                                        docType,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'Type of Document',
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              12,
                                                                          vertical:
                                                                              12),
                                                                    ),
                                                                    items: _documentTypes
                                                                            .isEmpty
                                                                        ? <String>[
                                                                            'Barangay Clearance',
                                                                            'Business Permit',
                                                                            'Certificate of Indigency',
                                                                            'First-time Job Seeker'
                                                                          ]
                                                                            .map((d) => DropdownMenuItem(
                                                                                value:
                                                                                    d,
                                                                                child: Text(
                                                                                    d)))
                                                                            .toList()
                                                                        : _documentTypes
                                                                            .map((dt) =>
                                                                                DropdownMenuItem(value: dt.name, child: Text(dt.name)))
                                                                            .toList(),
                                                                    onChanged:
                                                                        (v) {
                                                                      if (v !=
                                                                          null) {
                                                                        setState(
                                                                            () {
                                                                          docType =
                                                                              v;
                                                                        });
                                                                      }
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          12),
                                                                  // Instructional note for the upload field
                                                                  const Padding(
                                                                    padding: EdgeInsets.only(
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
                                                                            FontStyle.italic,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          _selectedImageName ??
                                                                              'No image selected',
                                                                          style:
                                                                              TextStyle(color: _selectedImageName == null ? Colors.grey : Colors.black),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                      TextButton
                                                                          .icon(
                                                                        onPressed:
                                                                            _pickImage,
                                                                        icon: const Icon(
                                                                            Icons
                                                                                .upload_file,
                                                                            size:
                                                                                18),
                                                                        label: const Text(
                                                                            'Upload'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                            height: 12),

                                                        // Actions
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
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
                                                              onPressed:
                                                                  _isSubmitting
                                                                      ? null
                                                                      : () async {
                                                                          if (formKey.currentState?.validate() ??
                                                                              false) {
                                                                            // Validate image upload (check both web bytes and mobile file)
                                                                            if (_selectedImage == null &&
                                                                                _webImageBytes == null) {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                const SnackBar(
                                                                                  content: Text('Please upload a valid ID image'),
                                                                                  backgroundColor: Colors.red,
                                                                                ),
                                                                              );
                                                                              return;
                                                                            }

                                                                            setState(() =>
                                                                                _isSubmitting = true);

                                                                            try {
                                                                              // Check if document types are loaded
                                                                                if (_documentTypes.isEmpty) {
                                                                                if (context.mounted) {
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    SnackBar(
                                                                                      content: Text('Backend connection failed. Please ensure the backend server is running at ${ApiConfig.baseUrl}'),
                                                                                      backgroundColor: Colors.red,
                                                                                      duration: Duration(seconds: 5),
                                                                                    ),
                                                                                  );
                                                                                }
                                                                                return;
                                                                              }

                                                                              // Find the matching document type from backend
                                                                              final selectedDocType = _documentTypes.firstWhere(
                                                                                (dt) => dt.name == docType,
                                                                                orElse: () => _documentTypes.first,
                                                                              );

                                                                              // Submit request to backend
                                                                              final response = await _requestService.createRequestWithImage(
                                                                                lastName: _lastNameController.text,
                                                                                firstName: _firstNameController.text,
                                                                                middleInitial: _middleInitialController.text.isEmpty ? null : _middleInitialController.text,
                                                                                contactNumber: _contactController.text,
                                                                                address: _addressController.text,
                                                                                purpose: _purposeController.text,
                                                                                age: int.parse(_ageController.text),
                                                                                docTypeId: selectedDocType.id,
                                                                                idImage: _selectedImage,
                                                                                idImageBytes: _webImageBytes,
                                                                                idImageName: _selectedImageName,
                                                                                eduAttainment: _eduAttainController.text.isEmpty ? null : _eduAttainController.text,
                                                                                eduCourse: _eduCourseController.text.isEmpty ? null : _eduCourseController.text,
                                                                                maritalStatus: _maritalController.text.isEmpty ? null : _maritalController.text,
                                                                              );

                                                                              final refNo = response['ref'] ?? 'N/A';

                                                                              // Close the form dialog
                                                                              if (context.mounted) {
                                                                                Navigator.of(context).pop();

                                                                                // Show success dialog with reference number
                                                                                showDialog(
                                                                                  context: context,
                                                                                  barrierDismissible: false,
                                                                                  builder: (BuildContext dialogContext) {
                                                                                    return AlertDialog(
                                                                                      title: const Row(
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.check_circle,
                                                                                            color: Colors.green,
                                                                                            size: 28,
                                                                                          ),
                                                                                          SizedBox(width: 8),
                                                                                          Text('Request Submitted'),
                                                                                        ],
                                                                                      ),
                                                                                      content: Column(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          const Text(
                                                                                            'Your reference number is:',
                                                                                            style: TextStyle(
                                                                                              fontSize: 14,
                                                                                              color: Colors.black87,
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(height: 12),
                                                                                          Container(
                                                                                            padding: const EdgeInsets.all(16),
                                                                                            decoration: BoxDecoration(
                                                                                              color: lightGreen,
                                                                                              borderRadius: BorderRadius.circular(8),
                                                                                              border: Border.all(
                                                                                                color: green,
                                                                                                width: 2,
                                                                                              ),
                                                                                            ),
                                                                                            child: Center(
                                                                                              child: Text(
                                                                                                refNo,
                                                                                                style: const TextStyle(
                                                                                                  fontSize: 24,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                  color: Color(0xFF1B5E20),
                                                                                                  letterSpacing: 2,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(height: 16),
                                                                                          const Text(
                                                                                            'Take a screenshot of your reference number to check the status of your request later.',
                                                                                            style: TextStyle(
                                                                                              fontSize: 12,
                                                                                              color: Colors.black54,
                                                                                              fontStyle: FontStyle.italic,
                                                                                            ),
                                                                                            textAlign: TextAlign.center,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      actions: [
                                                                                        TextButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(dialogContext).pop();
                                                                                            // Clear form
                                                                                            _lastNameController.clear();
                                                                                            _firstNameController.clear();
                                                                                            _middleInitialController.clear();
                                                                                            _contactController.clear();
                                                                                            _addressController.clear();
                                                                                            _purposeController.clear();
                                                                                            _eduAttainController.clear();
                                                                                            _eduCourseController.clear();
                                                                                            _ageController.clear();
                                                                                            _maritalController.clear();
                                                                                            setState(() {
                                                                                              _selectedImage = null;
                                                                                              _selectedImageName = null;
                                                                                            });
                                                                                          },
                                                                                          child: const Text(
                                                                                            'OK',
                                                                                            style: TextStyle(
                                                                                              fontSize: 16,
                                                                                              fontWeight: FontWeight.w600,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  },
                                                                                );
                                                                              }
                                                                            } catch (e) {
                                                                              if (context.mounted) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
                                                                                    backgroundColor: Colors.red,
                                                                                  ),
                                                                                );
                                                                              }
                                                                            } finally {
                                                                              if (mounted) {
                                                                                setState(() => _isSubmitting = false);
                                                                              }
                                                                            }
                                                                          }
                                                                        },
                                                              child: _isSubmitting
                                                                  ? const SizedBox(
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2,
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                                                      ),
                                                                    )
                                                                  : const Text('Submit'),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.0),
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
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: buttonWidth,
                                  height: isMobile ? 56 : 64,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Show status check dialog
                                      showDialog<void>(
                                        context: context,
                                        builder: (context) {
                                          final TextEditingController
                                              searchController =
                                              TextEditingController();
                                          Map<String, dynamic>? foundRequest;
                                          bool isSearching = false;
                                          String? errorMessage;

                                          return StatefulBuilder(builder:
                                              (context, setDialogState) {
                                            final screenWidth =
                                                MediaQuery.of(context)
                                                    .size
                                                    .width;
                                            final screenHeight =
                                                MediaQuery.of(context)
                                                    .size
                                                    .height;
                                            final isMobile = screenWidth < 600;

                                            return Dialog(
                                              insetPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: isMobile ? 16 : 40,
                                                vertical: isMobile ? 20 : 40,
                                              ),
                                              child: Container(
                                                width: isMobile
                                                    ? screenWidth - 32
                                                    : (screenWidth > 800
                                                        ? 700
                                                        : screenWidth * 0.7),
                                                constraints: BoxConstraints(
                                                  maxHeight: screenHeight -
                                                      (isMobile ? 40 : 80),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      isMobile ? 16.0 : 24.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              'Check Request Status',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    isMobile
                                                                        ? 18
                                                                        : 22,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.close),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height: isMobile
                                                              ? 12
                                                              : 16),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: TextField(
                                                              controller:
                                                                  searchController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    'Enter Reference Number',
                                                                hintText:
                                                                    'e.g., REQ-2025-11-00001',
                                                                border:
                                                                    OutlineInputBorder(),
                                                                prefixIcon:
                                                                    Icon(Icons
                                                                        .search),
                                                              ),
                                                              onSubmitted:
                                                                  (value) async {
                                                                if (value
                                                                    .trim()
                                                                    .isEmpty) {
                                                                  return;
                                                                }

                                                                setDialogState(
                                                                    () {
                                                                  isSearching =
                                                                      true;
                                                                  errorMessage =
                                                                      null;
                                                                  foundRequest =
                                                                      null;
                                                                });

                                                                try {
                                                                  final result =
                                                                      await _requestService
                                                                          .getRequestByRefNo(
                                                                              value.trim());

                                                                  setDialogState(
                                                                      () {
                                                                    foundRequest =
                                                                        result;
                                                                    isSearching =
                                                                        false;
                                                                  });
                                                                } catch (e) {
                                                                  setDialogState(
                                                                      () {
                                                                    errorMessage =
                                                                        'Request not found. Please check the reference number.';
                                                                    foundRequest =
                                                                        null;
                                                                    isSearching =
                                                                        false;
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          ElevatedButton(
                                                            onPressed:
                                                                isSearching
                                                                    ? null
                                                                    : () async {
                                                                        final refNo = searchController
                                                                            .text
                                                                            .trim();

                                                                        if (refNo
                                                                            .isEmpty) {
                                                                          setDialogState(
                                                                              () {
                                                                            errorMessage =
                                                                                'Please enter a reference number';
                                                                          });
                                                                          return;
                                                                        }

                                                                        setDialogState(
                                                                            () {
                                                                          isSearching =
                                                                              true;
                                                                          errorMessage =
                                                                              null;
                                                                          foundRequest =
                                                                              null;
                                                                        });

                                                                        try {
                                                                          final result =
                                                                              await _requestService.getRequestByRefNo(refNo);

                                                                          setDialogState(
                                                                              () {
                                                                            foundRequest =
                                                                                result;
                                                                            isSearching =
                                                                                false;
                                                                          });
                                                                        } catch (e) {
                                                                          setDialogState(
                                                                              () {
                                                                            errorMessage =
                                                                                'Request not found. Please check the reference number.';
                                                                            foundRequest =
                                                                                null;
                                                                            isSearching =
                                                                                false;
                                                                          });
                                                                        }
                                                                      },
                                                            child: isSearching
                                                                ? const SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                    ),
                                                                  )
                                                                : const Text(
                                                                    'Search'),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      Expanded(
                                                        child: isSearching
                                                            ? const Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    CircularProgressIndicator(),
                                                                    SizedBox(
                                                                        height:
                                                                            16),
                                                                    Text(
                                                                        'Searching...'),
                                                                  ],
                                                                ),
                                                              )
                                                            : errorMessage !=
                                                                    null
                                                                ? Center(
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .error_outline,
                                                                          size:
                                                                              48,
                                                                          color:
                                                                              Colors.red,
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                16),
                                                                        Text(
                                                                          errorMessage!,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              const TextStyle(color: Colors.red),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : foundRequest ==
                                                                        null
                                                                    ? Center(
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.search,
                                                                              size: 64,
                                                                              color: Colors.grey[400],
                                                                            ),
                                                                            const SizedBox(height: 16),
                                                                            Text(
                                                                              'Enter your reference number to check status',
                                                                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : Card(
                                                                        elevation:
                                                                            2,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              20.0),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              const Text(
                                                                                'Request Details',
                                                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: green),
                                                                              ),
                                                                              const SizedBox(height: 16),
                                                                              _buildStatusRow('Reference Number', foundRequest!['ref'] ?? '-'),
                                                                              const SizedBox(height: 12),
                                                                              _buildStatusRow('Name', _buildFullName(foundRequest!)),
                                                                              const SizedBox(height: 12),
                                                                              const Text(
                                                                                'Status:',
                                                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                                                              ),
                                                                              const SizedBox(height: 8),
                                                                              Container(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                                decoration: BoxDecoration(
                                                                                  color: _getStatusColor(foundRequest!['status']),
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                ),
                                                                                child: Text(
                                                                                  (foundRequest!['status'] ?? 'pending').toString().toUpperCase(),
                                                                                  style: const TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 16,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 16),
                                                                              const Divider(),
                                                                              const SizedBox(height: 12),
                                                                              Container(
                                                                                padding: const EdgeInsets.all(12),
                                                                                decoration: BoxDecoration(
                                                                                  color: _getStatusColor(foundRequest!['status']).withOpacity(0.1),
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                  border: Border.all(
                                                                                    color: _getStatusColor(foundRequest!['status']).withOpacity(0.3),
                                                                                  ),
                                                                                ),
                                                                                child: Row(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Icon(
                                                                                      _getStatusIcon(foundRequest!['status']),
                                                                                      color: _getStatusColor(foundRequest!['status']),
                                                                                      size: 24,
                                                                                    ),
                                                                                    const SizedBox(width: 12),
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        _getStatusMessage(foundRequest!['status']),
                                                                                        style: TextStyle(
                                                                                          fontSize: 14,
                                                                                          color: Colors.black87,
                                                                                          height: 1.4,
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
                                                      const SizedBox(
                                                          height: 12),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: const Text(
                                                              'Close'),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.0),
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
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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

  Widget _buildStatusRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _buildFullName(Map<String, dynamic> request) {
    final firstName = request['firstName'] ?? '';
    final middleInitial = request['middleInitial'];
    final lastName = request['lastName'] ?? '';

    final middle = middleInitial != null && middleInitial.toString().isNotEmpty
        ? ' ${middleInitial}. '
        : ' ';

    return '$firstName$middle$lastName';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.amber;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.hourglass_empty;
    }
  }

  String _getStatusMessage(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'You may now go and get your Document at the Barangay office.';
      case 'rejected':
        return 'ID does not have enough information that certifies your residency. Please upload a different ID with your full address, name, and birthdate or go to the barangay directly.';
      case 'pending':
      default:
        return 'Your request is still under review. Please wait for the barangay staff to process your application.';
    }
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
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
