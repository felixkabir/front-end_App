// First, let's define our data models
class Post {
  final String id;
  final String userId;
  final String userImage;
  final String userName;
  final String userType; // 'model', 'photographer', 'agency'
  final String timeAgo;
  final String content;
  final List<String> images;
  final int likes;
  final int comments;
  final int shares;
  final String eventDate; // For future events
  final bool isPastEvent;
  final String location;
  final List<Comment> commentsList;

  Post({
    required this.id,
    required this.userId,
    required this.userImage,
    required this.userName,
    required this.userType,
    required this.timeAgo,
    required this.content,
    required this.images,
    required this.likes,
    required this.comments,
    required this.shares,
    this.eventDate = '',
    this.isPastEvent = false,
    this.location = '',
    this.commentsList = const [],
  });
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String content;
  final String timeAgo;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.content,
    required this.timeAgo,
  });
}

// Sample data
final List<Post> samplePosts = [
  Post(
    id: '1',
    userId: 'user1',
    userImage: 'assets/img1.jpg',
    userName: 'Isabella Model',
    userType: 'model',
    timeAgo: '2h ago',
    content: 'Just finished an amazing photoshoot for Summer Collection 2024! 🌟',
    images: ['assets/img2.jpg', 'assets/img4.jpg'],
    likes: 234,
    comments: 45,
    shares: 12,
    commentsList: [
      Comment(
        id: 'c1',
        userId: 'user2',
        userName: 'John Photographer',
        userImage: 'assets/img2.jpg',
        content: 'Amazing work! The lighting is perfect.',
        timeAgo: '1h ago',
      ),
    ],
  ),
  Post(
    id: '2',
    userId: 'user2',
    userImage: 'assets/img4.jpg',
    userName: 'Fashion Agency Pro',
    userType: 'agency',
    timeAgo: '5h ago',
    content: 'Looking for models for our upcoming winter collection showcase!',
    images: ['assets/img1.jpg'],
    likes: 567,
    comments: 89,
    shares: 34,
    eventDate: 'March 15, 2024',
    location: 'Milan Fashion Studio',
    isPastEvent: false,
    commentsList: [],
  ),
];