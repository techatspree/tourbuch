part of 'person_bloc.dart';

@freezed
class PersonEvent with _$PersonEvent {
  const factory PersonEvent.initial() = _InitialEvent;
  const factory PersonEvent.reloadData(bool? shouldReload) = _ReloadDataEvent;
  const factory PersonEvent.orderClicked(ProductOrder productOrder, bool clickAllowed) = _OrderClickedEvent;
  const factory PersonEvent.commentDelete(int commentId) = _CommentDeleteEvent;
  const factory PersonEvent.commentEdited(String? content, int? commentId) = _CommentEditedEvent;
  const factory PersonEvent.commentStatusChanged(Comment comment, bool newValue) = _CommentStatusChangedEvent;
  const factory PersonEvent.deletePerson(bool? shouldDelete) = _DeletePersonEvent;
  const factory PersonEvent.magnifyOrder(ProductOrderWithSymbol? productOrder) = _MagnifyOrderEvent;
}
