import 'package:ai_edge_model_dl/ai_edge_model_dl.dart';
import 'package:flutter/material.dart';

import '../models/gemma_model.dart';
import '../models/rag_model.dart';
import '../services/config_service.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ModelDownloader _downloader;
  final ConfigService _configService = ConfigService();
  final Map<String, bool> _downloadedModels = {};
  final Map<String, ModelDownloadProgress?> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};
  final Map<String, bool> _downloadedRagModels = {};
  final Map<String, ModelDownloadProgress?> _ragDownloadProgress = {};
  final Map<String, bool> _isDownloadingRag = {};

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    // Get authorization headers from config service
    final authHeaders = await _configService.getAuthorizationHeader();

    // Create download service with auth headers
    _downloader = ModelDownloader(
      config: ModelDownloaderConfig(headers: authHeaders),
    );

    // Check downloaded models after service is initialized
    await _checkDownloadedModels();
  }

  Future<void> _checkDownloadedModels() async {
    for (final model in GemmaModel.availableModels) {
      final isDownloaded = await _downloader.isModelDownloaded(model.fileName);
      setState(() {
        _downloadedModels[model.id] = isDownloaded;
      });
    }

    // Check RAG models
    for (final model in RagModel.requiredModels) {
      final isDownloaded = await _downloader.isModelDownloaded(model.fileName);
      setState(() {
        _downloadedRagModels[model.id] = isDownloaded;
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
      // Re-initialize service with latest auth headers
      final authHeaders = await _configService.getAuthorizationHeader();
      _downloader = ModelDownloader(
        config: ModelDownloaderConfig(headers: authHeaders),
      );

      await _downloader.downloadModel(
        Uri.parse(model.downloadUrl),
        fileName: model.fileName,
        onProgress: (progress) {
          setState(() {
            _downloadProgress[model.id] = progress;
          });
        },
      );

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
      await _downloader.deleteModel(model.fileName);
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

  Future<void> _downloadRagModel(RagModel model) async {
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
      _isDownloadingRag[model.id] = true;
      _ragDownloadProgress[model.id] = null;
    });

    try {
      // Re-initialize service with latest auth headers
      final authHeaders = await _configService.getAuthorizationHeader();
      _downloader = ModelDownloader(
        config: ModelDownloaderConfig(headers: authHeaders),
      );

      await _downloader.downloadModel(
        Uri.parse(model.downloadUrl),
        fileName: model.fileName,
        onProgress: (progress) {
          setState(() {
            _ragDownloadProgress[model.id] = progress;
          });
        },
      );

      setState(() {
        _downloadedRagModels[model.id] = true;
        _isDownloadingRag[model.id] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${model.name} downloaded successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloadingRag[model.id] = false;
        _ragDownloadProgress[model.id] = null;
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

  Future<void> _deleteRagModel(RagModel model) async {
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
      await _downloader.deleteModel(model.fileName);
      setState(() {
        _downloadedRagModels[model.id] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${model.name} deleted')));
      }
    }
  }

  void _openChat(GemmaModel model) async {
    // Check if all RAG models are downloaded
    bool allRagModelsDownloaded = true;
    final missingModels = <String>[];

    for (final ragModel in RagModel.requiredModels) {
      if (_downloadedRagModels[ragModel.id] != true) {
        allRagModelsDownloaded = false;
        missingModels.add(ragModel.name);
      }
    }

    if (!allRagModelsDownloaded) {
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Required Models Missing'),
          content: Text(
            'Please download the following RAG models first:\n\n'
            '${missingModels.map((name) => '• $name').join('\n')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final modelPath = await _downloader.getModelPath(model.fileName);
    final tokenizerModelPath = await _downloader.getModelPath(RagModel.tokenizerModel.fileName);
    final embeddingModelPath = await _downloader.getModelPath(RagModel.embeddingModel.fileName);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            model: model,
            modelPath: modelPath,
            tokenizerModelPath: tokenizerModelPath,
            embeddingModelPath: embeddingModelPath,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Edge RAG Chat'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // RAG Models Section
          Text(
            'RAG Models (Required)',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'These models are required for RAG functionality',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          ...RagModel.requiredModels.map((model) {
            final isDownloaded = _downloadedRagModels[model.id] ?? false;
            final isDownloading = _isDownloadingRag[model.id] ?? false;
            final downloadProgress = _ragDownloadProgress[model.id];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDownloaded ? Icons.check_circle : Icons.error_outline,
                          color: isDownloaded ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            model.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Size: ${model.fileSizeMB.toStringAsFixed(1)} MB',
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
                            onPressed: null,
                            icon: const Icon(Icons.check),
                            label: const Text('Downloaded'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _deleteRagModel(model),
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete model',
                          ),
                        ],
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: () => _downloadRagModel(model),
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
          // LLM Models Section
          Text(
            'Language Models',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a language model for chat',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          ...GemmaModel.availableModels.map((model) {
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
          }),
        ],
      ),
    );
  }
}
