class UserSetting {
  final List<String> sortedPreference;//第0個為最高排序,第1個為第二排序

  UserSetting({required this.sortedPreference});

  Map<String, dynamic> toJson() => {
        'sorted_preference': sortedPreference,
      };

  UserSetting copyWith({
    List<String>? sortedPreference,
  }) {
    return UserSetting(
      sortedPreference: sortedPreference ?? this.sortedPreference,
    );
  }
}
