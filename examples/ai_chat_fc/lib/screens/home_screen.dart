import 'package:flutter/material.dart';

import '../models/download_progress.dart';
import '../models/gemma_model.dart';
import '../services/config_service.dart';
import '../services/model_download_service.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ModelDownloadService _downloadService = ModelDownloadService();
  final ConfigService _configService = ConfigService();
  final Map<String, bool> _downloadedModels = {};
  final Map<String, DownloadProgress?> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};

  @override
  void initState() {
    super.initState();
    _checkDownloadedModels();
  }

  Future<void> _checkDownloadedModels() async {
    for (final model in GemmaModel.availableModels) {
      final isDownloaded = await _downloadService.isModelDownloaded(model);
      setState(() {
        _downloadedModels[model.id] = isDownloaded;
      });
    }
  }

  Future<void> _downloadModel(GemmaModel model) async {
    // Check if authentication is required
    final isTokenEnabled = await _configService.isTokenEnabled();
    if (isTokenEnabled) {
      final hasToken = await _configService.hasToken();
      if (!hasToken) {
        if (!mounted) return;

        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Authentication Required'),
            content: const Text(
              'Authentication is enabled but no token is configured. '
              'Would you like to configure your HuggingFace token?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );

        if (shouldOpenSettings == true && mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }
        return;
      }
    }

    setState(() {
      _isDownloading[model.id] = true;
      _downloadProgress[model.id] = null;
    });

    try {
      await for (final progress in _downloadService.downloadModelWithProgress(
        model,
      )) {
        setState(() {
          _downloadProgress[model.id] = progress;
        });
      }

      setState(() {
        _downloadedModels[model.id] = true;
        _isDownloading[model.id] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${model.name} downloaded successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading[model.id] = false;
        _downloadProgress[model.id] = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download ${model.name}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteModel(GemmaModel model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model'),
        content: Text('Are you sure you want to delete ${model.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _downloadService.deleteModel(model);
      setState(() {
        _downloadedModels[model.id] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${model.name} deleted')));
      }
    }
  }

  void _openChat(GemmaModel model) async {
    final modelPath = await _downloadService.getModelPath(model);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(model: model, modelPath: modelPath),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Edge Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: GemmaModel.availableModels.length,
        itemBuilder: (context, index) {
          final model = GemmaModel.availableModels[index];
          final isDownloaded = _downloadedModels[model.id] ?? false;
          final isDownloading = _isDownloading[model.id] ?? false;
          final downloadProgress = _downloadProgress[model.id];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    model.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Size: ${model.fileSizeGB.toStringAsFixed(2)} GB',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (isDownloading) ...[
                    LinearProgressIndicator(
                      value: downloadProgress?.progress ?? 0,
                    ),
                    const SizedBox(height: 8),
                    if (downloadProgress != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(downloadProgress.progress * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${downloadProgress.downloadedSize} / ${downloadProgress.totalSize}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Speed: ${downloadProgress.speed}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Time left: ${downloadProgress.remainingTime}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ] else if (isDownloaded) ...[
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _openChat(model),
                          icon: const Icon(Icons.chat),
                          label: const Text('Open Chat'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _deleteModel(model),
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete model',
                        ),
                      ],
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () => _downloadModel(model),
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
