class Post {
  final int id;
  final String author;
  final String handle;
  final String avatar;
  final bool isOfficial;
  final bool isPinned;
  final bool isMe;
  final String content;
  final String time;
  int likes;
  final int comments;
  bool liked;

  Post({
    required this.id,
    required this.author,
    required this.handle,
    required this.avatar,
    this.isOfficial = false,
    this.isPinned = false,
    this.isMe = false,
    required this.content,
    required this.time,
    required this.likes,
    required this.comments,
    this.liked = false,
  });

  Post copyWith({
    int? id,
    String? author,
    String? handle,
    String? avatar,
    bool? isOfficial,
    bool? isPinned,
    bool? isMe,
    String? content,
    String? time,
    int? likes,
    int? comments,
    bool? liked,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      handle: handle ?? this.handle,
      avatar: avatar ?? this.avatar,
      isOfficial: isOfficial ?? this.isOfficial,
      isPinned: isPinned ?? this.isPinned,
      isMe: isMe ?? this.isMe,
      content: content ?? this.content,
      time: time ?? this.time,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      liked: liked ?? this.liked,
    );
  }

  void toggleLike() {
    if (liked) {
      likes--;
    } else {
      likes++;
    }
    liked = !liked;
  }

  static List<Post> getSamplePosts() {
    return [
      Post(
        id: 1,
        author: 'Estate Management',
        handle: '@management',
        avatar: '🏢',
        isOfficial: true,
        isPinned: true,
        content: '🚨 IMPORTANT: Water supply will be interrupted tomorrow (Dec 16) from 10AM - 2PM for tank maintenance. Please store water accordingly.',
        time: '2h ago',
        likes: 24,
        comments: 8,
      ),
      Post(
        id: 2,
        author: 'Mrs. Okonkwo',
        handle: '@unit_15a',
        avatar: '👩🏾',
        content: 'Has anyone seen a brown tabby cat? She went missing yesterday around Block C. Answers to "Mimi". Please contact me if found! 🐱',
        time: '3h ago',
        likes: 12,
        comments: 15,
        liked: true,
      ),
      Post(
        id: 3,
        author: 'Estate Management',
        handle: '@management',
        avatar: '🏢',
        isOfficial: true,
        content: '📋 Reminder: December service charge is due by Dec 20th. Late payments will attract a 5% penalty. Pay via the Bills section in this app.',
        time: '5h ago',
        likes: 8,
        comments: 3,
      ),
      Post(
        id: 4,
        author: 'Mr. Adewale',
        handle: '@unit_8b',
        avatar: '👨🏿',
        content: 'Good morning neighbors! I have some extra plantain suckers if anyone wants to start a small garden. First come, first served! 🌱',
        time: '6h ago',
        likes: 31,
        comments: 12,
      ),
      Post(
        id: 5,
        author: 'Security Post',
        handle: '@security',
        avatar: '🛡️',
        isOfficial: true,
        content: '⚠️ Security Alert: Please ensure all vehicles are parked in designated areas only. Vehicles parked on walkways will be towed.',
        time: '8h ago',
        likes: 15,
        comments: 4,
      ),
      Post(
        id: 6,
        author: 'Mrs. Chen',
        handle: '@unit_3c',
        avatar: '👩🏻',
        content: 'Thank you to whoever returned my son\'s bicycle to the security post! Faith in humanity restored 🙏',
        time: '1d ago',
        likes: 45,
        comments: 8,
        liked: true,
      ),
      Post(
        id: 7,
        author: 'Estate Management',
        handle: '@management',
        avatar: '🏢',
        isOfficial: true,
        content: '🎄 Season\'s Greetings! The annual Christmas decoration competition starts Dec 18th. Register your unit at the management office. Prizes for top 3!',
        time: '1d ago',
        likes: 52,
        comments: 21,
      ),
      Post(
        id: 8,
        author: 'James Anderson',
        handle: '@unit_12b',
        avatar: 'JA',
        isMe: true,
        content: 'Just moved in last week. Happy to be part of this community! Looking forward to meeting everyone. 👋',
        time: '2d ago',
        likes: 38,
        comments: 14,
      ),
    ];
  }
}