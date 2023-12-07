import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../models/faq_question.dart';
import '../../models/product_type.dart';
import '../../widgets/binary_choice_dialog/binary_choice_dialog.dart';
import '../../widgets/edit_faq_question_dialog/edit_faq_question_dialog.dart';
import '../../widgets/edit_product_type_dialog/edit_product_type_dialog.dart';
import 'bloc/settings_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsBloc _settingsBloc;

  @override
  void initState() {
    _settingsBloc = SettingsBloc()..add(LoadOrdersEvent());
    super.initState();
  }

  @override
  void dispose() {
    _settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
        bloc: _settingsBloc,
        listener: (context, state) async {
          if (state is OpenDialog) {
            openDialog(state.dialogType, state.productType, state.faqQuestion);
          }
        },
        builder: (context, state) {
          if (state is SettingsInitial) {
            return getScaffold(const CircularProgressIndicator());
          } else if (state is DataLoaded) {
            return getScaffold(
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ExpansionPanelList.radio(
                    materialGapSize: 1,
                    children: [getProductTypePanel(state), getFAQPanel(state)],
                  ),
                ),
              ),
            );
          }
          return getScaffold(Container());
        });
  }

  void openDialog(DialogType dialogType, ProductType? productType,
      FAQQuestion? faqQuestion) async {
    _settingsBloc.add(
      DialogClosedEvent(
        await showDialog<bool>(
              barrierDismissible: false,
              context: context,
              builder: (context) => dialogType == DialogType.product
                  ? EditProductTypeDialog(productType: productType)
                  : EditFAQQuestionDialog(faqQuestion: faqQuestion),
            ) ==
            true,
      ),
    );
  }

  ExpansionPanel getProductTypePanel(DataLoaded state) {
    return ExpansionPanelRadio(
      value: 0,
      canTapOnHeader: true,
      headerBuilder: (context, isOpen) => const ListTile(
        title: Text(
          'Produkttypen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: state.productTypes.length,
        itemBuilder: (context, index) {
          final product = state.productTypes[index];

          return ListTile(
            title: Text(product.symbol == null ? product.name : '${product.symbol} ${product.name}'),
            subtitle: Text(
                'Sperrung von ${product.daysBlocked} Tagen'),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  IconButton(
                      onPressed: product.deletable
                          ? () async => _settingsBloc.add(DeleteProductTypeEvent(
                              product.id,
                              await BinaryChoiceDialog.open(
                                  context,
                                  '${product.name} löschen',
                                  'Soll ${product.name} gelöscht werden? Alle zugehörigen Bestellungen werden unwiderruflich gelöscht.')))
                          : null,
                      icon: const Icon(Icons.delete)),
                IconButton(
                    onPressed: () => _settingsBloc.add(
                        OpenProductTypeDialogEvent(state.productTypes[index])),
                    icon: const Icon(Icons.edit)),
                if (product.image != null) Image.memory(product.image),
              ],
            ),
          );
        },
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
      ),
    );
  }

  ExpansionPanelRadio getFAQPanel(DataLoaded state) {
    return ExpansionPanelRadio(
        value: 1,
        canTapOnHeader: true,
        headerBuilder: (context, isOpen) => const ListTile(
              title: Text(
                'FAQ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        body: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.faqQuestions.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                title: Text(
                  state.faqQuestions[index].question,
                ),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () async => _settingsBloc.add(
                            DeleteFAQQuestionEvent(
                                state.faqQuestions[index].id,
                                await BinaryChoiceDialog.open(
                                    context,
                                    'FAQ Frage löschen',
                                    'Soll "${state.faqQuestions[index].question}" gelöscht werden?'))),
                        icon: const Icon(Icons.delete)),
                    IconButton(
                        onPressed: () => _settingsBloc.add(
                            OpenFAQQuestionDialogEvent(
                                state.faqQuestions[index])),
                        icon: const Icon(Icons.edit))
                  ],
                ));
          },
        ));
  }

  Scaffold getScaffold(Widget body) {
    return Scaffold(
        appBar: AppBar(title: const Text('Einstellungen')),
        body: body,
        floatingActionButton: SpeedDial(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          buttonSize: const Size(100, 100),
          icon: Icons.add,
          elevation: 1,
          activeIcon: Icons.close,
          childMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            SpeedDialChild(
              child: const Icon(Icons.shopping_basket),
              label: 'Produkttyp',
              foregroundColor: Theme.of(context).primaryColor,
              labelStyle: const TextStyle(fontSize: 24),
              onTap: () => _settingsBloc.add(OpenProductTypeDialogEvent(null)),
            ),
            SpeedDialChild(
              child: const Icon(Icons.question_answer),
              label: 'FAQ',
              foregroundColor: Theme.of(context).primaryColor,
              labelStyle: const TextStyle(fontSize: 24),
              onTap: () => _settingsBloc.add(OpenFAQQuestionDialogEvent(null)),
            )
          ],
        ));
  }
}
