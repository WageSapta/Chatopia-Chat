import 'package:chatopia/widgets/my_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../provider/add_provider.dart';
import 'heading.dart';

class AddBottomSheet extends StatefulWidget {
  const AddBottomSheet({super.key});

  @override
  State<AddBottomSheet> createState() => _AddBottomSheetState();
}

class _AddBottomSheetState extends State<AddBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddProvider>(
      builder: (context, search, child) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(10.0),
                height: 5,
                width: 60,
                decoration: ShapeDecoration(
                  color: Colors.grey.withOpacity(.5),
                  shape: const StadiumBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: H3("Add Friend"),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Visibility(
                      visible: search.loading || search.textError != "",
                      child: Column(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: search.loading,
                                child: const SizedBox(
                                  height: 23,
                                  width: 23,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              Visibility(
                                  visible:
                                      search.textError != "" && !search.loading,
                                  child: H5(search.textError)),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 15),
                          SizedBox(width: 5),
                          Text(
                            "check in activity",
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                    ),
                    Form(
                      key: search.formKey,
                      child: MyTextField(
                        textInputFormatter:
                            FilteringTextInputFormatter.digitsOnly,
                        textInputAction: TextInputAction.done,
                        controller: search.searchController,
                        keyboardType: TextInputType.number,
                        hintText: "Search ID",
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          search.textError = "";
                          if (search.searchController.text.isNotEmpty) {
                            search.addFriend();
                          }
                        },
                        child: const Text('Search'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    context.read<AddProvider>().disposeValues();
    super.didChangeDependencies();
  }
}
