import 'package:flutter/material.dart';
import 'package:manor/core/theme/app_colors.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> posts = Post.getSamplePosts();
  String feedFilter = 'all';

  List<Post> get filteredPosts {
    switch (feedFilter) {
      case 'official':
        return posts.where((p) => p.isOfficial).toList();
      case 'residents':
        return posts.where((p) => !p.isOfficial).toList();
      default:
        return posts;
    }
  }

  List<Post> get pinnedPosts => filteredPosts.where((p) => p.isPinned).toList();
  List<Post> get regularPosts => filteredPosts.where((p) => !p.isPinned).toList();

  void _toggleLike(int postId) {
    setState(() {
      final post = posts.firstWhere((p) => p.id == postId);
      post.toggleLike();
    });
  }

  void _showComposeModal() {
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
                                final newPost = Post(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  author: 'James Anderson',
                                  handle: '@unit_12b',
                                  avatar: 'JA',
                                  isMe: true,
                                  content: postText,
                                  time: 'Just now',
                                  likes: 0,
                                  comments: 0,
                                );
                                setState(() => posts.insert(0, newPost));
                                Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: postText.isNotEmpty ? Colors.white : Colors.white54,
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Center(
                        child: Text(
                          'JA',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => setModalState(() => postText = value),
                        maxLines: 5,
                        minLines: 3,
                        maxLength: 280,
                        decoration: const InputDecoration(
                          hintText: 'What\'s happening in the estate?',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          counterStyle: TextStyle(color: AppColors.textTertiary),
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
              GestureDetector(
                onTap: _showComposeModal,
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

        // Filter Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildFilterTab('All Posts', 'all'),
              const SizedBox(width: 8),
              _buildFilterTab('🏢 Official', 'official'),
              const SizedBox(width: 8),
              _buildFilterTab('👥 Residents', 'residents'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Posts List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              // Pinned Posts
              ...pinnedPosts.map((post) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PostCard(
                  post: post,
                  onLike: () => _toggleLike(post.id),
                ),
              )),

              // Regular Posts
              ...regularPosts.map((post) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PostCard(
                  post: post,
                  onLike: () => _toggleLike(post.id),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String label, String filter) {
    final isSelected = feedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => feedFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}