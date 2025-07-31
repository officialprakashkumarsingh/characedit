import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prakashai/features/characters/domain/character.dart';
import 'package:prakashai/features/characters/presentation/character_card.dart';
import 'package:prakashai/features/characters/providers/characters_provider.dart';
import 'package:prakashai/utils/constants.dart';

class CharactersPage extends ConsumerWidget {
  const CharactersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(charactersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PrakashAI Characters'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: charactersAsync.when(
        data: (characters) => _buildCharacterList(context, characters),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.createCharacter);
        },
        child: const Icon(Icons.add),
        tooltip: 'Create New Character',
      ),
    );
  }

  Widget _buildCharacterList(BuildContext context, List<Character> characters) {
    if (characters.isEmpty) {
      return const Center(
        child: Text(
          'No characters found. Create your first character!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return CharacterCard(
          character: character,
          onTap: () {
            context.push(
              AppRoutes.chat.replaceFirst(':characterId', character.id),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load characters: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Retry loading characters
                context.refresh(charactersProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}