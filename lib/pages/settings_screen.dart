import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import '../widgets/app_bar.dart';
import '../widgets/base/text_input_field.dart';
import '../widgets/base/number_dropdown.dart';
import '../widgets/base/select_dropdown.dart';
import '../widgets/base/switch_field.dart';
import '../widgets/base/section_title.dart';

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

  late int _age;
  late int _weight;
  late String _gender;
  late int _height;
  late String? _selectedDisease;
  late String? _selectedAllergy;
  late bool _isVegetarian;

  late int _dailyCalorieTarget;
  late int _dailyProteinTarget;
  late int _dailyCarbsTarget;
  late int _dailyFatTarget;

  bool _isLoading = true;
  bool _hasChanges = false;

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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool hasChanged, {
    bool isPassword = false,
  }) {
    return Container(
      decoration:
          hasChanged
              ? BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              )
              : null,
      child: Stack(
        children: [
          TextInputField(
            label: label,
            controller: controller,
            isPassword: isPassword,
          ),
          if (hasChanged)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
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
      _selectedAllergy = user.allergy;
      _isVegetarian = user.isVegetarian;

      _dailyCalorieTarget = user.dailyCalorieTarget;
      _dailyProteinTarget = user.dailyProteinTarget;
      _dailyCarbsTarget = user.dailyCarbsTarget;
      _dailyFatTarget = user.dailyFatTarget;

      _caloriesController.text = _dailyCalorieTarget.toString();
      _proteinController.text = _dailyProteinTarget.toString();
      _carbsController.text = _dailyCarbsTarget.toString();
      _fatController.text = _dailyFatTarget.toString();
    } else {
      _nameController.text = '';
      _emailController.text = '';
      _passwordController.text = '';

      _age = 18;
      _weight = 180;
      _gender = 'female';
      _height = 180;
      _selectedDisease = null;
      _selectedAllergy = null;
      _isVegetarian = false;

      _dailyCalorieTarget = 2000;
      _dailyProteinTarget = 100;
      _dailyCarbsTarget = 250;
      _dailyFatTarget = 65;

      _caloriesController.text = '2000';
      _proteinController.text = '100';
      _carbsController.text = '250';
      _fatController.text = '65';
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
      if (_changedFields.contains('disease'))
        changedItems.add("health conditions");
      if (_changedFields.contains('allergy')) changedItems.add("allergies");
      if (_changedFields.contains('isVegetarian'))
        changedItems.add("diet preferences");
      if (_changedFields.contains('calories') ||
          _changedFields.contains('protein') ||
          _changedFields.contains('carbs') ||
          _changedFields.contains('fat')) {
        changedItems.add("nutrition targets");
      }

      String changesSummary =
          changedItems.isEmpty ? "" : "Updated: ${changedItems.join(', ')}.";

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
          age: _age,
          weight: _weight,
          gender: _gender,
          height: _height,
          disease: _selectedDisease,
          allergy: _selectedAllergy,
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
          age: _age,
          weight: _weight,
          gender: _gender,
          height: _height,
          disease: _selectedDisease,
          allergy: _selectedAllergy,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_hasChanges) {
              _showUnsavedChangesDialog(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_hasChanges)
            TextButton.icon(
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _saveSettings,
            ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none),
                if (_appDatabase.unreadNotificationsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '${_appDatabase.unreadNotificationsCount}',
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {},
          ),
        ],
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
                      _buildTextField(
                        'Name',
                        _nameController,
                        _changedFields.contains('name'),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'Email',
                        _emailController,
                        _changedFields.contains('email'),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'Password',
                        _passwordController,
                        _changedFields.contains('password'),
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Personal information'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: NumberDropdown(
                              label: 'Age',
                              value: _age,
                              onChanged: (value) {
                                setState(() {
                                  _age = value;
                                  _hasChanges = true;
                                });
                              },
                              items: List.generate(100, (index) => index + 1),
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
                                });
                              },
                              items: List.generate(300, (index) => index + 50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SelectDropdown(
                              label: 'Gender',
                              value: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                  _hasChanges = true;
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
                                });
                              },
                              items: List.generate(120, (index) => index + 100),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectDropdown(
                        label: 'Diseases',
                        value: _selectedDisease,
                        onChanged: (value) {
                          setState(() {
                            _selectedDisease = value;
                            _changedFields.add('disease');
                            _hasChanges = true;
                          });
                        },
                        items: const ['None', 'A', 'B', 'C', 'Other'],
                      ),
                      const SizedBox(height: 8),
                      SelectDropdown(
                        label: 'Specific allergies',
                        value: _selectedAllergy,
                        onChanged: (value) {
                          setState(() {
                            _selectedAllergy = value;
                            _changedFields.add('allergy');
                            _hasChanges = true;
                          });
                        },
                        items: const ['None', 'A', 'B', 'C', 'Other'],
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
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'Nutrition Targets'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Calories',
                              _caloriesController,
                              _changedFields.contains('calories'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Protein (g)',
                              _proteinController,
                              _changedFields.contains('protein'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Carbs (g)',
                              _carbsController,
                              _changedFields.contains('carbs'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Fat (g)',
                              _fatController,
                              _changedFields.contains('fat'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _hasChanges ? _saveSettings : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                          if (_hasChanges)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: FloatingActionButton(
                                backgroundColor: Colors.white,
                                onPressed: _saveSettings,
                                child: const Icon(
                                  Icons.save,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
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
