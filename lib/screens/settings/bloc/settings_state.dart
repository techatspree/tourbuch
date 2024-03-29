part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class DataLoaded extends SettingsState {
  final List<ProductType> productTypes;
  final List<FAQQuestion> faqQuestions;

  DataLoaded(this.productTypes, this.faqQuestions);
}

class OpenDialog extends SettingsState {
  final ProductType? productType;
  final FAQQuestion? faqQuestion;
  final DialogType dialogType;

  OpenDialog(this.dialogType, {this.productType, this.faqQuestion});
}

enum DialogType {product, faq}