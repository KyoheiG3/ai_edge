import 'package:flutter/material.dart';
import '../services/config_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ConfigService _configService = ConfigService();
  final TextEditingController _tokenController = TextEditingController();
  bool _isTokenEnabled = false;
  bool _showToken = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final token = await _configService.getHuggingFaceToken();
    final isEnabled = await _configService.isTokenEnabled();
    
    setState(() {
      _tokenController.text = token ?? '';
      _isTokenEnabled = isEnabled;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final token = _tokenController.text.trim();
    
    if (token.isNotEmpty) {
      await _configService.saveHuggingFaceToken(token);
    } else {
      await _configService.removeHuggingFaceToken();
    }
    
    await _configService.setTokenEnabled(_isTokenEnabled);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HuggingFace Authentication',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Enable Authentication'),
                            subtitle: const Text(
                              'Use Bearer token for model downloads',
                            ),
                            value: _isTokenEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isTokenEnabled = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          AnimatedOpacity(
                            opacity: _isTokenEnabled ? 1.0 : 0.5,
                            duration: const Duration(milliseconds: 200),
                            child: AbsorbPointer(
                              absorbing: !_isTokenEnabled,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'API Token',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _tokenController,
                                    obscureText: !_showToken,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your HuggingFace token',
                                      helperText: 'Get your token from huggingface.co/settings/tokens',
                                      helperMaxLines: 2,
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _showToken
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showToken = !_showToken;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Authentication',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Some models may require authentication to download\n'
                            '• Your token is stored securely on this device\n'
                            '• Token is never shared with third parties\n'
                            '• You can disable authentication at any time',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}