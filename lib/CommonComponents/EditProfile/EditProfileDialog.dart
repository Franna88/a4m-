import 'dart:typed_data';
import 'package:a4m/CommonComponents/buttons/CustomButton.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_network/image_network.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditProfileDialog extends StatefulWidget {
  final String userId;
  final String userType;

  const EditProfileDialog({
    super.key,
    required this.userId,
    required this.userType,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _idController = TextEditingController();

  bool _isLoading = true;
  bool _isUploading = false;
  Map<String, dynamic> _userData = {};

  // For image upload
  Uint8List? _selectedImageBytes;
  String? _profileImageUrl;

  // For CV upload
  File? _cvFile; // Mobile/Desktop
  Uint8List? _cvFileBytes; // Web
  String? _cvFileName;
  String? _currentCvUrl;
  bool _isUploadingCv = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _userData = docSnapshot.data() ?? {};
          _nameController.text = _userData['name'] ?? '';
          _phoneController.text = _userData['phoneNumber'] ?? '';
          _emailController.text = _userData['email'] ?? '';
          _descriptionController.text = _userData['description'] ?? '';
          _idController.text = _userData['idNumber'] ?? '';
          _profileImageUrl = _userData['profileImageUrl'];
          _currentCvUrl = _userData['cvUrl'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = imageBytes;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_selectedImageBytes == null) return _profileImageUrl;

    setState(() {
      _isUploading = true;
    });

    try {
      final storage = FirebaseStorage.instance;
      final fileRef =
          storage.ref().child('profile_pictures/${widget.userId}.jpg');

      // Upload the image
      await fileRef.putData(
        _selectedImageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get the download URL
      final downloadUrl = await fileRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile image')),
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _pickCVFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          final fileBytes = result.files.single.bytes;
          if (fileBytes != null) {
            setState(() {
              _cvFileBytes = fileBytes;
              _cvFileName = result.files.single.name;
            });
            print('CV file picked successfully (web): $_cvFileName');
          }
        } else {
          final filePath = result.files.single.path;
          if (filePath != null) {
            setState(() {
              _cvFile = File(filePath);
              _cvFileName = result.files.single.name;
            });
            print('CV file picked successfully (mobile): $_cvFileName');
          }
        }
      }
    } catch (e) {
      print('Error picking CV file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick CV file')),
      );
    }
  }

  Future<String?> _uploadCV() async {
    if (_cvFileBytes == null && _cvFile == null) return _currentCvUrl;

    setState(() {
      _isUploadingCv = true;
    });

    try {
      final storage = FirebaseStorage.instance;
      final fileRef = storage.ref().child('CVs/${widget.userId}.pdf');

      if (kIsWeb && _cvFileBytes != null) {
        await fileRef.putData(_cvFileBytes!);
      } else if (_cvFile != null) {
        await fileRef.putFile(_cvFile!);
      }

      final downloadUrl = await fileRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading CV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload CV')),
      );
      return null;
    } finally {
      setState(() {
        _isUploadingCv = false;
      });
    }
  }

  Future<void> _saveProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Upload profile image if changed
      final imageUrl = await _uploadProfileImage();

      // Upload CV if changed (only for lecturers)
      String? cvUrl;
      if (widget.userType == 'lecturer') {
        cvUrl = await _uploadCV();
      }

      // Update Firestore document
      Map<String, dynamic> updateData = {
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
        'description': _descriptionController.text,
        'idNumber': _idController.text,
      };

      if (imageUrl != null) {
        updateData['profileImageUrl'] = imageUrl;
      }

      if (cvUrl != null) {
        updateData['cvUrl'] = cvUrl;
      }

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .update(updateData);

      // Update email if changed
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && _emailController.text != currentUser.email) {
        await currentUser.updateEmail(_emailController.text);

        // Also update the email in Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .update({
          'email': _emailController.text,
        });
      }

      // Update password if provided
      if (_passwordController.text.isNotEmpty) {
        await currentUser?.updatePassword(_passwordController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        height: 700,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: _isLoading || _isUploading || _isUploadingCv
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header section with user info and profile pic
                    Container(
                      padding: EdgeInsets.all(20),
                      color: Colors.grey.shade200,
                      child: Row(
                        children: [
                          // Profile image with edit button
                          Stack(
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _selectedImageBytes != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          _selectedImageBytes!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : _profileImageUrl != null &&
                                            _profileImageUrl!.isNotEmpty
                                        ? ImageNetwork(
                                            image: _profileImageUrl!,
                                            height: 150,
                                            width: 150,
                                            duration: 1500,
                                            curve: Curves.easeIn,
                                            onPointer: true,
                                            debugPrint: false,
                                            fitAndroidIos: BoxFit.cover,
                                            fitWeb: BoxFitWeb.cover,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            onError: Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                              size: 50,
                                            ),
                                            onLoading:
                                                CircularProgressIndicator(
                                              color: Mycolors().blue,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.grey[600],
                                              size: 50,
                                            ),
                                          ),
                              ),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Mycolors().blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.white, size: 20),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          // User info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nameController.text,
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  _capitalizeFirstLetter(widget.userType),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 10),
                                // Stats section - only displayed for relevant user types
                                if (_userData['courseCount'] != null ||
                                    _userData['studentCount'] != null ||
                                    _userData['rating'] != null)
                                  Wrap(
                                    spacing: 20,
                                    children: [
                                      if (_userData['courseCount'] != null)
                                        _buildStatItem(
                                          Icons.book,
                                          '${_userData['courseCount']} Course${_userData['courseCount'] != 1 ? 's' : ''}',
                                        ),
                                      if (_userData['studentCount'] != null)
                                        _buildStatItem(
                                          Icons.people,
                                          '${_userData['studentCount']} Student${_userData['studentCount'] != 1 ? 's' : ''}',
                                        ),
                                      if (_userData['rating'] != null)
                                        _buildStatItem(
                                          Icons.star,
                                          '${_userData['rating']} Rating',
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          // Save button
                          CustomButton(
                            buttonText: 'Save',
                            buttonColor: Mycolors().blue,
                            onPressed: _saveProfileData,
                            width: 100,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    // Personal information fields
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: MyTextFields(
                                  inputController: _nameController,
                                  headerText: "Full Name",
                                  hintText: 'Enter your full name',
                                  keyboardType: 'text',
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: MyTextFields(
                                  inputController: _idController,
                                  headerText: "ID Number",
                                  hintText: 'Enter your ID number',
                                  keyboardType: 'intType',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: MyTextFields(
                                  inputController: _phoneController,
                                  headerText: "Phone Number",
                                  hintText: 'Enter your phone number',
                                  keyboardType: 'phone',
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: MyTextFields(
                                  inputController: _emailController,
                                  headerText: "Email",
                                  hintText: 'Enter your email',
                                  keyboardType: 'email',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          MyTextFields(
                            inputController: _passwordController,
                            headerText: "Password",
                            hintText:
                                'Enter new password (leave blank to keep current)',
                            keyboardType: 'password',
                          ),
                          SizedBox(height: 20),
                          MyTextFields(
                            inputController: _descriptionController,
                            headerText: "Description",
                            hintText: 'Tell us about yourself',
                            keyboardType: 'multiline',
                          ),
                          // CV Upload section for lecturers and facilitators
                          if (widget.userType == 'lecturer' ||
                              widget.userType == 'facilitator') ...[
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CV Document',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _cvFileName ??
                                            (_currentCvUrl != null
                                                ? 'Current CV'
                                                : 'No CV uploaded'),
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed:
                                            _isUploadingCv ? null : _pickCVFile,
                                        icon: Icon(_cvFileName != null
                                            ? Icons.check
                                            : Icons.upload_file),
                                        label: Text(_cvFileName != null
                                            ? 'CV Selected'
                                            : 'Update CV'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Mycolors().blue,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Mycolors().green),
        SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}
