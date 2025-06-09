import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend//controllers/settings_controller.dart';
import '../../frontend/widgets/NavigationBar.dart';
import '../../frontend/widgets/section_title.dart';
import '../../frontend/widgets/customDropdown.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsController(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SettingsController>(context);
    final yellowColor = HSLColor.fromAHSL(0.5, 47, 0.92, 0.66).toColor();

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
            icon: Icon(controller.isEditing ? Icons.save : Icons.edit),
            onPressed: controller.isEditing
                ? () => controller.saveUserData(context)
                : controller.toggleEditing,
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(title: "My Account"),
            const SizedBox(height: 8),
            customTextField("Name", controller.nameController, Icons.edit, enabled: controller.isEditing, color: yellowColor, obscurePassword: false),
            customTextField("Email", controller.emailController, Icons.email, keyboardType: TextInputType.emailAddress, enabled: controller.isEditing, color: yellowColor, obscurePassword: false),
            customTextField("Bio", controller.bioController, Icons.text_fields, keyboardType: TextInputType.multiline, enabled: controller.isEditing, color: yellowColor, obscurePassword: false),
            customTextField("Password", controller.passwordController, Icons.lock, obscureText: true, enabled: controller.isEditing, color: yellowColor, obscurePassword: controller.obscurePassword, toggleVisibility: controller.togglePasswordVisibility),
            const SizedBox(height: 24),
            SectionTitle(title: "Personal information"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomDropdown(
                    label: "Age",
                    items: List.generate(83, (index) => (1 + index).toString()),
                    selectedValue: controller.selectedAge,
                    onChanged: controller.isEditing ? (val) => controller.selectedAge = val : null,
                    backgroundColor: yellowColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDropdown(
                    label: "Weight",
                    items: List.generate(100, (index) => (1 + index).toString()),
                    selectedValue: controller.selectedWeight,
                    onChanged: controller.isEditing ? (val) => controller.selectedWeight = val : null,
                    backgroundColor: yellowColor,
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
                    selectedValue: controller.selectedGender,
                    onChanged: controller.isEditing ? (val) => controller.selectedGender = val : null,
                    backgroundColor: yellowColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDropdown(
                    label: "Height",
                    items: List.generate(150, (index) => (100 + index).toString()),
                    selectedValue: controller.selectedHeight,
                    onChanged: controller.isEditing ? (val) => controller.selectedHeight = val : null,
                    backgroundColor: yellowColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomDropdown(
              label: "Diseases",
              items: ['None', 'Diabetes', 'Celiac Disease'],
              selectedValue: controller.selectedDisease,
              onChanged: controller.isEditing ? (val) => controller.selectedDisease = val : null,
              backgroundColor: yellowColor,
            ),
            const SizedBox(height: 10),
            CustomDropdown(
              label: "Specific allergies",
              items: ['None', 'Peanuts', 'Gluten'],
              selectedValue: controller.selectedAllergy,
              onChanged: controller.isEditing ? (val) => controller.selectedAllergy = val : null,
              backgroundColor: yellowColor,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Are you a vegetarian?", style: TextStyle(fontSize: 16)),
                Switch(
                  value: controller.isVegetarian,
                  onChanged: controller.isEditing ? (val) => controller.isVegetarian = val : null,
                ),
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
        bool enabled = true,
        required Color color,
        bool obscurePassword = false,
        VoidCallback? toggleVisibility,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        obscureText: obscureText ? obscurePassword : false,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: obscureText
              ? IconButton(
            icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleVisibility,
          )
              : Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
