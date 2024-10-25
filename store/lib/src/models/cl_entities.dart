abstract class CLEntity {
  bool get isMarkedDeleted;
  bool get isMarkedEditted;
  //int? get getServerUID;
  bool isContentSame(covariant CLEntity other);

  bool get hasServerUID;
  bool isChangedAfter(CLEntity other);
}