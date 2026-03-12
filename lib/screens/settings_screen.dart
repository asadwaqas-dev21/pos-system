import 'package:flutter/material.dart';
import 'package:pos_app/theme.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _storeNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _storeNameController = TextEditingController(text: settings.storeName);
    _addressController = TextEditingController(text: settings.storeAddress);
    _phoneController = TextEditingController(text: settings.storePhone);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color:
                      theme.textTheme.displayLarge?.color ??
                      AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Store Information'),
              _buildTextField('Store Name', _storeNameController, Icons.store),
              _buildTextField('Address', _addressController, Icons.location_on),
              _buildTextField('Phone Number', _phoneController, Icons.phone),
              const SizedBox(height: 24),

              _buildSectionHeader('Preferences'),
              SwitchListTile(
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Enable dark theme for the application'),
                secondary: const Icon(
                  Icons.dark_mode,
                  color: AppTheme.primaryColor,
                ),
                value: settings.isDarkMode,
                onChanged: (val) {
                  settings.isDarkMode = val;
                },
                activeColor: AppTheme.primaryColor,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text(
                  'Auto-Print Receipt',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Automatically print receipt after checkout',
                ),
                secondary: const Icon(
                  Icons.print,
                  color: AppTheme.primaryColor,
                ),
                value: settings.autoPrintReceipt,
                onChanged: (val) {
                  settings.autoPrintReceipt = val;
                },
                activeColor: AppTheme.primaryColor,
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'Default Tax Rate (%)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Currently set to ${settings.defaultTaxRate}%'),
                leading: const Icon(
                  Icons.percent,
                  color: AppTheme.primaryColor,
                ),
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Rate',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      settings.defaultTaxRate = double.tryParse(val) ?? 0.0;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 48),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    settings.storeName = _storeNameController.text;
                    settings.storeAddress = _addressController.text;
                    settings.storePhone = _phoneController.text;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings saved successfully!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
      ),
    );
  }
}
