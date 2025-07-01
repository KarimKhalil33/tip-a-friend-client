class Post {
  final int id;
  final String type;
  final String category;
  final String title;
  final String description;
  final String location;
  final String price;
  final DateTime time;
  final String posterName;
  final String? profileImage;
  final String posterId; // userId of the poster
  final String? acceptedBy; // userId of the accepter
  final bool? confirmedByPoster; // whether the poster confirmed

  Post({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.time,
    required this.posterName,
    required this.posterId,
    this.profileImage,
    this.acceptedBy,
    this.confirmedByPoster,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      type: json['type'],
      category: json['category'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      price: json['price'].toString(),
      time: DateTime.parse(json['time']),
      posterName: json['poster_name'],
      posterId: json['poster_id'],
      profileImage: json['profile_image'],
      acceptedBy: json['accepted_by'],
      confirmedByPoster: json['confirmed_by_poster'],
    );
  }
}
