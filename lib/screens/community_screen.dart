import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manor/blocs/announcements/announcements_bloc.dart';
import 'package:manor/core/di/injection.dart';
import 'package:manor/core/theme/app_colors.dart';
import '../blocs/auth/auth_bloc.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final estateId = context.select<AuthBloc, String?>((bloc) => bloc.state.user?.estateId);
    return BlocProvider<AnnouncementsBloc>(
      create: (_) => getIt<AnnouncementsBloc>()..add(AnnouncementsStarted(estateId)),
      child: const _FeedScreenContent(),
    );
  }
}

class _FeedScreenContent extends StatefulWidget {
  const _FeedScreenContent();

  @override
  State<_FeedScreenContent> createState() => _FeedScreenContentState();
}

class _FeedScreenContentState extends State<_FeedScreenContent> {
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Liking posts is coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComposeModal(BuildContext context) {
    final bloc = context.read<AnnouncementsBloc>();
    String postText = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Text(
                      'New Post',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: postText.isNotEmpty
                            ? () {
                                bloc.add(AnnouncementCreateRequested(postText));
                                Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: postText.isNotEmpty
                                ? Colors.white
                                : Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Compose Body
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.official, Color(0xFF15803D)],
                        ),
                      ),
                      child: const Center(
                        child: Text('🏢', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        onChanged: (value) =>
                            setModalState(() => postText = value),
                        maxLines: 5,
                        minLines: 3,
                        maxLength: 280,
                        decoration: const InputDecoration(
                          hintText: 'What\'s happening in the estate?',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          counterStyle: TextStyle(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        autofocus: true,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // Footer Actions
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.image_outlined),
                      color: AppColors.textSecondary,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.location_on_outlined),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only estate admins can post to the feed — residents are read-only.
    // Admin management happens outside this app, but the check is
    // role-based rather than hard-removed in case that ever changes.
    final canCompose = context.select<AuthBloc, bool>(
      (bloc) => bloc.state.user?.role == 'admin',
    );
    final posts = context
        .watch<AnnouncementsBloc>()
        .state
        .posts
        .where((p) => p.isOfficial)
        .toList();
    final pinnedPosts = posts.where((p) => p.isPinned).toList();
    final regularPosts = posts.where((p) => !p.isPinned).toList();

    return Column(
      children: [
        // Header with Compose Button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Community Feed',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (canCompose)
                GestureDetector(
                  onTap: () => _showComposeModal(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Posts List
        Expanded(
          child: posts.isEmpty
              ? const Center(
                  child: Text(
                    'No announcements yet.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    // Pinned Posts
                    ...pinnedPosts.map(
                      (post) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PostCard(
                          post: post,
                          onLike: () => _showComingSoon(context),
                        ),
                      ),
                    ),

                    // Regular Posts
                    ...regularPosts.map(
                      (post) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PostCard(
                          post: post,
                          onLike: () => _showComingSoon(context),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
