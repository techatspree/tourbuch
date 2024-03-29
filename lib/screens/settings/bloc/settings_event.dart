part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class LoadOrdersEvent extends SettingsEvent {
  LoadOrdersEvent();
}

class AddProductTypeEvent extends SettingsEvent {
  AddProductTypeEvent();
}

class DeleteProductTypeEvent extends SettingsEvent {
  final int productTypeId;
  final bool? shouldDelete;

  DeleteProductTypeEvent(this.productTypeId, this.shouldDelete);
}

class DeleteFAQQuestionEvent extends SettingsEvent {
  final int faqQuestionId;
  final bool? shouldDelete;

  DeleteFAQQuestionEvent(this.faqQuestionId, this.shouldDelete);
}

class OpenProductTypeDialogEvent extends SettingsEvent {
  final ProductType? productType;

  OpenProductTypeDialogEvent(this.productType);
}

class OpenFAQQuestionDialogEvent extends SettingsEvent {
  final FAQQuestion? faqQuestion;

  OpenFAQQuestionDialogEvent(this.faqQuestion);
}

class DialogClosedEvent extends SettingsEvent {
  final bool saveClicked;

  DialogClosedEvent(this.saveClicked);
}

class FormChangedEvent extends SettingsEvent {
  final bool? validate;

  FormChangedEvent(this.validate);
}