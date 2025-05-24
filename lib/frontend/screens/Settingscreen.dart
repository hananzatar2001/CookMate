import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../backend/models/user_model.dart';
import '../../backend/services/user_service.dart';
import '../../frontend/widgets/NavigationBar.dart';
import '../../frontend/widgets/section_title.dart';
import '../../frontend/widgets/customDropdown.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color _yellowColor = Colors.yellow;
  final UserService _userService = UserService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();


  String? userId;
  String? selectedAge;
  String? selectedWeight;
  String? selectedHeight;
  String? selectedGender;
  String? selectedDisease;
  String? selectedAllergy;
  bool isVegetarian = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _oldPasswordHash;

  @override
  void initState() {
    super.initState();
    //final original = HSLColor.fromColor(Color(0xFFF8D558));
    final original = HSLColor.fromAHSL(0.5, 47, 0.92, 0.66);
    setState(() {
      _yellowColor = original.toColor();
    });
  }

  Future<void> loadUserId() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID missing. Please login again.')),
      );
      setState(() => _isLoading = false);
    } else {
      setState(() => userId = id);
      await fetchUser();
    }
  }

  Future<void> fetchUser() async {
    if (userId == null) return;
    try {
      final fetchedUser = await _userService.getUserById(userId!);
      if (fetchedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
        return;
      }

      final ageList = List.generate(83, (index) => (18 + index).toString());
      final weightList = List.generate(100, (index) => (40 + index).toString());
      final heightList = List.generate(61, (index) => (140 + index).toString());

      setState(() {
        _nameController.text = fetchedUser.name;
        _emailController.text = fetchedUser.email;
        _oldPasswordHash = fetchedUser.passwordHash;
        _bioController.text = fetchedUser.Bio;

        final age = fetchedUser.Age.toString();
        selectedAge = ageList.contains(age) ? age : null;

        final weight = fetchedUser.Weight.toString();
        selectedWeight = weightList.contains(weight) ? weight : null;

        final height = fetchedUser.Height.toString();
        selectedHeight = heightList.contains(height) ? height : null;

        selectedGender = ['female', 'male'].contains(fetchedUser.Gender) ? fetchedUser.Gender : null;
        selectedDisease = ['None', 'Diabetes', 'Heart Disease'].contains(fetchedUser.Diseases) ? fetchedUser.Diseases : null;
        selectedAllergy = ['None', 'Peanuts', 'Gluten'].contains(fetchedUser.specificAllergies) ? fetchedUser.specificAllergies : null;
        isVegetarian = fetchedUser.isVegetarian;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String hashPassword(String password) {
    return password;
  }

  Future<void> _saveUserData() async {
    if (userId == null) return;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Save"),
        content: const Text("Are you sure you want to save changes?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Save")),
        ],
      ),
    ) ?? false;

    if (!shouldSave) return;

    setState(() => _isLoading = true);

    try {
      String newPasswordHash;

      if (_passwordController.text.isNotEmpty) {
        newPasswordHash = hashPassword(_passwordController.text);
      } else {
        newPasswordHash = _oldPasswordHash ?? '';
      }

      final user = UserModel(
        userId: userId!,
        name: _nameController.text,
        email: _emailController.text,
        Bio: _bioController.text,
        Gender: selectedGender ?? '',
        Age: int.tryParse(selectedAge ?? '0') ?? 0,
        Height: int.tryParse(selectedHeight ?? '0') ?? 0,
        Weight: int.tryParse(selectedWeight ?? '0') ?? 0,
        Diseases: selectedDisease ?? '',
        specificAllergies: selectedAllergy ?? '',
        isVegetarian: isVegetarian,
        passwordHash: newPasswordHash,
      );

      await _userService.updateUser(user);
      await _userService.saveUserCalories(user);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changes saved successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save changes: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUserData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(title: "My Account"),
            const SizedBox(height: 8),
            customTextField("Name", _nameController, Icons.edit),
            customTextField("Email", _emailController, Icons.edit, keyboardType: TextInputType.emailAddress),
            customTextField("Bio", _bioController, Icons.edit, keyboardType: TextInputType.multiline),
            customTextField("Password", _passwordController, Icons.edit, obscureText: true),

            const SizedBox(height: 24),
            SectionTitle(title: "Personal information"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomDropdown(
                    label: "Age",
                    items: List.generate(83, (index) => (18 + index).toString()),
                    selectedValue: selectedAge,
                    onChanged: (val) => setState(() => selectedAge = val),
                    backgroundColor: _yellowColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDropdown(
                    label: "Weight",
                    items: List.generate(100, (index) => (40 + index).toString()),
                    selectedValue: selectedWeight,
                    onChanged: (val) => setState(() => selectedWeight = val),
                    backgroundColor: _yellowColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomDropdown(
                    label: "Gender",
                    items: ['female', 'male'],
                    selectedValue: selectedGender,
                    onChanged: (val) => setState(() => selectedGender = val),
                    backgroundColor: _yellowColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDropdown(
                    label: "Height",
                    items: List.generate(61, (index) => (140 + index).toString()),
                    selectedValue: selectedHeight,
                    onChanged: (val) => setState(() => selectedHeight = val),
                    backgroundColor: _yellowColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomDropdown(
              label: "Diseases",
              items: ['None', 'Diabetes', 'Heart Disease'],
              selectedValue: selectedDisease,
              onChanged: (val) => setState(() => selectedDisease = val),
              backgroundColor: _yellowColor,
            ),
            const SizedBox(height: 10),
            CustomDropdown(
              label: "Specific allergies",
              items: ['None', 'Peanuts', 'Gluten'],
              selectedValue: selectedAllergy,
              onChanged: (val) => setState(() => selectedAllergy = val),
              backgroundColor: _yellowColor,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Are you a vegetarian?", style: TextStyle(fontSize: 16)),
                Switch(
                    value: isVegetarian,
                    onChanged: (val) => setState(() => isVegetarian = val,
                    )),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget customTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool obscureText = false,
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _yellowColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        obscureText: obscureText && label == "Password" ? _obscurePassword : false,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,  // <--- set max lines here
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: label == "Password"
              ? IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          )
              : Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
