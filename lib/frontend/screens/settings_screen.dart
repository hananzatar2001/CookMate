import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../backend/services/database_service.dart';
import '../../backend/models/models.dart';
import '../widgets/app_bar.dart';
import '../widgets/base/number_dropdown.dart';
import '../widgets/base/select_dropdown.dart';
import '../widgets/base/switch_field.dart';
import '../widgets/base/section_title.dart';

import '../widgets/base/highlighted_text_field.dart';
import '../widgets/base/option_selector.dart';
import '../widgets/base/save_button.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppDatabase _appDatabase = DatabaseService().database;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _fiberController;

  late TextEditingController _customDiseaseController;

  late TextEditingController _customAllergyController;

  late int _age;
  late int _weight;
  late String _gender;
  late int _height;
  late String? _selectedDisease;
  late bool _hasAllergies = false;
  late List<String> _selectedAllergies = [];
  late bool _isVegetarian;

  bool _isCustomDiseaseSelected = false;

  bool _hasCustomAllergy = false;
  String _customAllergyValue = "";

  String _themeMode = 'light';

  String _language = 'English';

  late int _dailyCalorieTarget;
  late int _dailyProteinTarget;
  late int _dailyCarbsTarget;
  late int _dailyFatTarget;
  late int _dailyFiberTarget;

  bool _isLoading = true;
  bool _hasChanges = false;

  final List<String> _diseaseOptions = [
    'None',
    'Diabetes',
    'Juvenile Diabetes',
    'Hypertension',
    'Atherosclerosis',
    'Marasmus',
    'Rickets',
    'Osteoporosis',
    'Scurvy',
    'Beriberi',
    'Other',
  ];

  final List<String> _allergyOptions = [
    'Cow\'s milk',
    'Wheat',
    'Gluten',
    'Eggs',
    'Fish/Seafood',
    'Soy',
    'Nuts/Peanuts',
    'Barley',
    'Rice',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _appDatabase.addListener(_updateUI);
    _loadUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _caloriesController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatController = TextEditingController();
    _fiberController = TextEditingController();
    _customDiseaseController = TextEditingController();
    _customAllergyController = TextEditingController();

    _nameController.addListener(() {
      _markFieldAsChanged('name');
    });
    _emailController.addListener(() {
      _markFieldAsChanged('email');
    });
    _passwordController.addListener(() {
      _markFieldAsChanged('password');
    });
    _caloriesController.addListener(() {
      _markFieldAsChanged('calories');
    });
    _proteinController.addListener(() {
      _markFieldAsChanged('protein');
    });
    _carbsController.addListener(() {
      _markFieldAsChanged('carbs');
    });
    _fatController.addListener(() {
      _markFieldAsChanged('fat');
    });
    _fiberController.addListener(() {
      _markFieldAsChanged('fiber');
    });
    _customDiseaseController.addListener(() {
      _markFieldAsChanged('disease');
    });
    _customAllergyController.addListener(() {
      _markFieldAsChanged('allergy');
      _customAllergyValue = _customAllergyController.text;
    });
  }

  final Set<String> _changedFields = {};

  void _markFieldAsChanged(String fieldName) {
    if (!_isLoading) {
      setState(() {
        _changedFields.add(fieldName);
        _hasChanges = true;
      });
    }
  }

  void _markAsChanged() {
    if (!_isLoading && !_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _updateUI() {
    if (mounted && !_isLoading) {
      _loadUserData();
    }
  }

  void _loadUserData() async {
    setState(() {
      _isLoading = true;
      _changedFields.clear();
    });

    final user = _appDatabase.currentUser;

    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _passwordController.text = '******';

      _age = user.age;
      _weight = user.weight;
      _gender = user.gender;
      _height = user.height;
      _selectedDisease = user.disease;
      _isVegetarian = user.isVegetarian;

      _themeMode = 'light';

      if (_selectedDisease != null &&
          !_diseaseOptions.contains(_selectedDisease)) {
        _isCustomDiseaseSelected = true;
        _customDiseaseController.text = _selectedDisease!;
        _selectedDisease = 'Other';
      } else {
        _isCustomDiseaseSelected = _selectedDisease == 'Other';
        if (_isCustomDiseaseSelected) {
          _customDiseaseController.text = '';
        }
      }

      if (user.allergy != null) {
        try {
          final List<dynamic> allergiesList = jsonDecode(user.allergy!);
          _selectedAllergies =
              allergiesList.map((item) => item.toString()).toList();
          _hasAllergies = _selectedAllergies.isNotEmpty;

          if (_selectedAllergies.contains('Other')) {
            int otherIndex = _selectedAllergies.indexOf('Other');
            if (otherIndex < _selectedAllergies.length - 1 &&
                !_allergyOptions.contains(_selectedAllergies[otherIndex + 1])) {
              _customAllergyValue = _selectedAllergies[otherIndex + 1];
              _customAllergyController.text = _customAllergyValue;
              _hasCustomAllergy = true;

              _selectedAllergies.removeAt(otherIndex + 1);
            }
          }
        } catch (e) {
          if (user.allergy == "None" || user.allergy!.isEmpty) {
            _hasAllergies = false;
            _selectedAllergies = [];
          } else {
            _hasAllergies = true;
            _selectedAllergies = [user.allergy!];

            if (!_allergyOptions.contains(user.allergy)) {
              _customAllergyValue = user.allergy!;
              _customAllergyController.text = _customAllergyValue;
              _hasCustomAllergy = true;
              _selectedAllergies = ['Other'];
            }
          }
        }
      } else {
        _hasAllergies = false;
        _selectedAllergies = [];
      }

      _dailyCalorieTarget = user.dailyCalorieTarget;
      _dailyProteinTarget = user.dailyProteinTarget;
      _dailyCarbsTarget = user.dailyCarbsTarget;
      _dailyFatTarget = user.dailyFatTarget;
      _dailyFiberTarget = user.dailyFiberTarget;

      _caloriesController.text = _dailyCalorieTarget.toString();
      _proteinController.text = _dailyProteinTarget.toString();
      _carbsController.text = _dailyCarbsTarget.toString();
      _fatController.text = _dailyFatTarget.toString();
      _fiberController.text = _dailyFiberTarget.toString();
    } else {
      _nameController.text = '';
      _emailController.text = '';
      _passwordController.text = '';

      _age = 18;
      _weight = 180;
      _gender = 'female';
      _height = 180;
      _selectedDisease = null;
      _hasAllergies = false;
      _selectedAllergies = [];
      _hasCustomAllergy = false;
      _customAllergyValue = '';
      _customAllergyController.text = '';
      _isVegetarian = false;
      _isCustomDiseaseSelected = false;
      _customDiseaseController.text = '';
      _themeMode = 'light';
      _language = 'English';

      _dailyCalorieTarget = 2000;
      _dailyProteinTarget = 100;
      _dailyCarbsTarget = 250;
      _dailyFatTarget = 65;
      _dailyFiberTarget = 25;

      _caloriesController.text = '2000';
      _proteinController.text = '100';
      _carbsController.text = '250';
      _fatController.text = '65';
      _fiberController.text = '25';
    }

    setState(() {
      _isLoading = false;
      _hasChanges = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _dailyCalorieTarget =
          int.tryParse(_caloriesController.text) ?? _dailyCalorieTarget;
      _dailyProteinTarget =
          int.tryParse(_proteinController.text) ?? _dailyProteinTarget;
      _dailyCarbsTarget =
          int.tryParse(_carbsController.text) ?? _dailyCarbsTarget;
      _dailyFatTarget = int.tryParse(_fatController.text) ?? _dailyFatTarget;
      _dailyFiberTarget =
          int.tryParse(_fiberController.text) ?? _dailyFiberTarget;

      final String? diseaseToSave =
          _selectedDisease == 'Other' &&
                  _customDiseaseController.text.isNotEmpty
              ? _customDiseaseController.text
              : _selectedDisease;

      String? allergiesToSave;
      if (!_hasAllergies) {
        allergiesToSave = null;
      } else {
        List<String> allergiesList = List.from(_selectedAllergies);

        if (_hasCustomAllergy && _customAllergyController.text.isNotEmpty) {
          if (!allergiesList.contains('Other')) {
            allergiesList.add('Other');
          }
          allergiesList.add(_customAllergyController.text);
        }
        allergiesToSave = jsonEncode(allergiesList);
      }

      final currentUser = _appDatabase.currentUser;
      User updatedUser;

      List<String> changedItems = [];
      if (_changedFields.contains('name')) changedItems.add("name");
      if (_changedFields.contains('email')) changedItems.add("email");
      if (_changedFields.contains('password')) changedItems.add("password");
      if (_changedFields.contains('age')) changedItems.add("age");
      if (_changedFields.contains('weight')) changedItems.add("weight");
      if (_changedFields.contains('height')) changedItems.add("height");
      if (_changedFields.contains('gender')) changedItems.add("gender");
      if (_changedFields.contains('disease')) {
        changedItems.add("health conditions");
      }
      if (_changedFields.contains('allergy')) changedItems.add("allergies");
      if (_changedFields.contains('isVegetarian')) {
        changedItems.add("diet preferences");
      }
      if (_changedFields.contains('theme')) changedItems.add("theme");
      if (_changedFields.contains('language')) changedItems.add("language");
      if (_changedFields.contains('calories') ||
          _changedFields.contains('protein') ||
          _changedFields.contains('carbs') ||
          _changedFields.contains('fat') ||
          _changedFields.contains('fiber')) {
        changedItems.add("nutrition targets");
      }

      String changesSummary =
          changedItems.isEmpty ? "" : "Updated: ${changedItems.join(', ')}.";

      bool isDarkMode = _themeMode == 'dark';

      if (currentUser == null) {
        final newUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          email: _emailController.text,
          password:
              _passwordController.text == '******'
                  ? null
                  : _passwordController.text,
          dailyCalorieTarget: _dailyCalorieTarget,
          dailyProteinTarget: _dailyProteinTarget,
          dailyCarbsTarget: _dailyCarbsTarget,
          dailyFatTarget: _dailyFatTarget,
          dailyFiberTarget: _dailyFiberTarget,
          age: _age,
          weight: _weight,
          gender: _gender,
          height: _height,
          disease: diseaseToSave,
          allergy: allergiesToSave,
          isVegetarian: _isVegetarian,
        );

        await _appDatabase.setUser(newUser);

        final notification = AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: 'Your account has been created successfully!',
          time: DateTime.now(),
          type: 'profileUpdate',
          isRead: false,
        );

        await _appDatabase.addNotification(notification);
      } else {
        final updatedUser = User(
          id: currentUser.id,
          name: _nameController.text,
          email: _emailController.text,
          password:
              _passwordController.text == '******'
                  ? currentUser.password
                  : _passwordController.text,
          dailyCalorieTarget: _dailyCalorieTarget,
          dailyProteinTarget: _dailyProteinTarget,
          dailyCarbsTarget: _dailyCarbsTarget,
          dailyFatTarget: _dailyFatTarget,
          dailyFiberTarget: _dailyFiberTarget,
          age: _age,
          weight: _weight,
          gender: _gender,
          height: _height,
          disease: diseaseToSave,
          allergy: allergiesToSave,
          isVegetarian: _isVegetarian,
        );

        await _appDatabase.setUser(updatedUser);

        final notification = AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message:
              changesSummary.isEmpty
                  ? 'Your profile settings have been updated.'
                  : 'Your profile settings have been updated. $changesSummary',
          time: DateTime.now(),
          type: 'profileUpdate',
          isRead: false,
        );

        await _appDatabase.addNotification(notification);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Settings saved successfully',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      setState(() {
        _isLoading = false;
        _hasChanges = false;
        _changedFields.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Error saving settings: $e',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _appDatabase.removeListener(_updateUI);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _customDiseaseController.dispose();

    _customAllergyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool useColumnLayout = screenWidth < 480;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Settings',
        showBackButton: true,
        notificationCount: _appDatabase.unreadNotificationsCount,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'My Account'),
                      const SizedBox(height: 16),

                      HighlightedTextField(
                        label: 'Name',
                        controller: _nameController,
                        highlight: _changedFields.contains('name'),
                      ),
                      const SizedBox(height: 8),
                      HighlightedTextField(
                        label: 'Email',
                        controller: _emailController,
                        highlight: _changedFields.contains('email'),
                      ),
                      const SizedBox(height: 8),
                      HighlightedTextField(
                        label: 'Password',
                        controller: _passwordController,
                        highlight: _changedFields.contains('password'),
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Personal information'),
                      const SizedBox(height: 16),

                      useColumnLayout
                          ? Column(
                            children: [
                              NumberDropdown(
                                label: 'Age',
                                value: _age,
                                onChanged: (value) {
                                  setState(() {
                                    _age = value;
                                    _hasChanges = true;
                                    _changedFields.add('age');
                                  });
                                },
                                items: List.generate(100, (index) => index + 1),
                              ),
                              const SizedBox(height: 8),
                              NumberDropdown(
                                label: 'Weight',
                                value: _weight,
                                onChanged: (value) {
                                  setState(() {
                                    _weight = value;
                                    _hasChanges = true;
                                    _changedFields.add('weight');
                                  });
                                },
                                items: List.generate(
                                  300,
                                  (index) => index + 50,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: NumberDropdown(
                                  label: 'Age',
                                  value: _age,
                                  onChanged: (value) {
                                    setState(() {
                                      _age = value;
                                      _hasChanges = true;
                                      _changedFields.add('age');
                                    });
                                  },
                                  items: List.generate(
                                    100,
                                    (index) => index + 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: NumberDropdown(
                                  label: 'Weight',
                                  value: _weight,
                                  onChanged: (value) {
                                    setState(() {
                                      _weight = value;
                                      _hasChanges = true;
                                      _changedFields.add('weight');
                                    });
                                  },
                                  items: List.generate(
                                    300,
                                    (index) => index + 50,
                                  ),
                                ),
                              ),
                            ],
                          ),

                      const SizedBox(height: 8),

                      useColumnLayout
                          ? Column(
                            children: [
                              SelectDropdown(
                                label: 'Gender',
                                value: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value!;
                                    _hasChanges = true;
                                    _changedFields.add('gender');
                                  });
                                },
                                items: const ['male', 'female'],
                              ),
                              const SizedBox(height: 8),
                              NumberDropdown(
                                label: 'Height',
                                value: _height,
                                onChanged: (value) {
                                  setState(() {
                                    _height = value;
                                    _hasChanges = true;
                                    _changedFields.add('height');
                                  });
                                },
                                items: List.generate(
                                  120,
                                  (index) => index + 100,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SelectDropdown(
                                  label: 'Gender',
                                  value: _gender,
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = value!;
                                      _hasChanges = true;
                                      _changedFields.add('gender');
                                    });
                                  },
                                  items: const ['male', 'female'],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: NumberDropdown(
                                  label: 'Height',
                                  value: _height,
                                  onChanged: (value) {
                                    setState(() {
                                      _height = value;
                                      _hasChanges = true;
                                      _changedFields.add('height');
                                    });
                                  },
                                  items: List.generate(
                                    120,
                                    (index) => index + 100,
                                  ),
                                ),
                              ),
                            ],
                          ),

                      const SizedBox(height: 8),

                      SelectDropdown(
                        label: 'Health Conditions',
                        value: _selectedDisease,
                        onChanged: (value) {
                          setState(() {
                            _selectedDisease = value;
                            _isCustomDiseaseSelected = value == 'Other';
                            _changedFields.add('disease');
                            _hasChanges = true;
                          });
                        },
                        items: _diseaseOptions,
                      ),

                      if (_isCustomDiseaseSelected)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: HighlightedTextField(
                            label: 'Specify',
                            controller: _customDiseaseController,
                            highlight: _changedFields.contains('disease'),
                          ),
                        ),

                      const SizedBox(height: 16),

                      SwitchField(
                        label: 'Do you have allergies?',
                        value: _hasAllergies,
                        onChanged: (value) {
                          setState(() {
                            _hasAllergies = value;
                            if (!value) {
                              _selectedAllergies = [];
                              _hasCustomAllergy = false;
                            }
                            _changedFields.add('allergy');
                            _hasChanges = true;
                          });
                        },
                      ),

                      if (_hasAllergies)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select your allergies:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),

                              ...List.generate(_allergyOptions.length, (index) {
                                final allergyOption = _allergyOptions[index];

                                if (allergyOption == 'Other') {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CheckboxListTile(
                                        title: const Text('Other'),
                                        value: _hasCustomAllergy,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (value) {
                                          setState(() {
                                            _hasCustomAllergy = value ?? false;
                                            _changedFields.add('allergy');
                                            _hasChanges = true;
                                          });
                                        },
                                      ),
                                      if (_hasCustomAllergy)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                            top: 4.0,
                                            bottom: 8.0,
                                          ),
                                          child: HighlightedTextField(
                                            label: 'Specify',
                                            controller:
                                                _customAllergyController,
                                            highlight: _changedFields.contains(
                                              'allergy',
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }

                                return CheckboxListTile(
                                  title: Text(allergyOption),
                                  value: _selectedAllergies.contains(
                                    allergyOption,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        if (!_selectedAllergies.contains(
                                          allergyOption,
                                        )) {
                                          _selectedAllergies.add(allergyOption);
                                        }
                                      } else {
                                        _selectedAllergies.remove(
                                          allergyOption,
                                        );
                                      }
                                      _changedFields.add('allergy');
                                      _hasChanges = true;
                                    });
                                  },
                                );
                              }),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),
                      SwitchField(
                        label: 'Are you a vegetarian?',
                        value: _isVegetarian,
                        onChanged: (value) {
                          setState(() {
                            _isVegetarian = value;
                            _changedFields.add('isVegetarian');
                            _hasChanges = true;
                          });
                        },
                      ),

                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Application Settings'),
                      const SizedBox(height: 16),

                      OptionSelector(
                        label: 'Theme Mode',
                        selectedValue: _themeMode,
                        options: const {'light': 'Light', 'dark': 'Dark'},
                        primaryColor: buttonsPrimaryColor,
                        onChanged: (value) {
                          setState(() {
                            _themeMode = value;
                            _changedFields.add('theme');
                            _hasChanges = true;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      OptionSelector(
                        label: 'Language',
                        selectedValue: _language,
                        options: const {
                          'English': 'English',
                          'Arabic': 'العربية',
                        },
                        primaryColor: buttonsPrimaryColor,
                        onChanged: (value) {
                          setState(() {
                            _language = value;
                            _changedFields.add('language');
                            _hasChanges = true;
                          });
                        },
                      ),

                      const SizedBox(height: 16),
                      const SectionTitle(title: 'Nutrition Targets'),

                      HighlightedTextField(
                        label: 'Calories',
                        controller: _caloriesController,
                        highlight: _changedFields.contains('calories'),
                      ),
                      const SizedBox(height: 8),
                      HighlightedTextField(
                        label: 'Protein (g)',
                        controller: _proteinController,
                        highlight: _changedFields.contains('protein'),
                      ),
                      const SizedBox(height: 8),
                      HighlightedTextField(
                        label: 'Carbs (g)',
                        controller: _carbsController,
                        highlight: _changedFields.contains('carbs'),
                      ),
                      const SizedBox(height: 8),
                      HighlightedTextField(
                        label: 'Fat (g)',
                        controller: _fatController,
                        highlight: _changedFields.contains('fat'),
                      ),
                      const SizedBox(height: 8),
                      HighlightedTextField(
                        label: 'Fiber (g)',
                        controller: _fiberController,
                        highlight: _changedFields.contains('fiber'),
                      ),
                      const SizedBox(height: 32),

                      SaveButton(
                        isEnabled: _hasChanges,
                        primaryColor: buttonsPrimaryColor,
                        onPressed: _saveSettings,
                      ),

                      if (_hasChanges)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'You have unsaved changes',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  void _showUnsavedChangesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Do you want to save them before leaving?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('DISCARD'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _saveSettings();
                Navigator.of(context).pop();
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }
}
