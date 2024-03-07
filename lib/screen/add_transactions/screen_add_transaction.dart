import 'package:flutter/material.dart';
import 'package:money_management/db/category/category_db.dart';
import 'package:money_management/db/transaction/transaction_db.dart';
import 'package:money_management/model/category/category_model.dart';
import 'package:money_management/model/transaction/transactions_model.dart';



class ScreenAddTransaction extends StatefulWidget {
  static const routeName = 'add_transaction';

  const ScreenAddTransaction({super.key});

  @override
  State<ScreenAddTransaction> createState() => _ScreenAddTransactionState();
}

class _ScreenAddTransactionState extends State<ScreenAddTransaction> {
  DateTime? _selectedDate;
  CategoryType? _selectedCategoryType;
  CategoryModel? _selectedCategoryModel;

  String? _categoryID;

  final _purposeTextEditingController = TextEditingController();
  final _amountTextEditingController = TextEditingController();

  @override
  void initState() {
    _selectedCategoryType = CategoryType.income;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _purposeTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration:  InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Purpose',
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                          const BorderSide(color: Colors.indigo, width: 2),
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                         BorderSide(color: Colors.indigo.shade300, width: 2),
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _amountTextEditingController,
                    keyboardType: TextInputType.number,
                    decoration:InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Amount',
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                          const BorderSide(color: Colors.indigo, width: 2),
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.indigo.shade300, width: 2),
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),


                TextButton.icon(
                  onPressed: () async {
                    final _selectedDateTemp = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (_selectedDateTemp == null) {
                      return;
                    } else {
                      print(_selectedDateTemp.toString());
                      setState(() {
                        _selectedDate = _selectedDateTemp;
                      });
                    }
                  },
                  icon:  Icon(Icons.calendar_today,color: Colors.indigo.shade700,),
                  label: Text(_selectedDate == null
                      ? 'Select Date'
                      : _selectedDate!.toString(),style: TextStyle(color:Colors.indigo.shade800 ),),
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Radio(
                          activeColor: Colors.indigo.shade900,
                          value: CategoryType.income,
                          groupValue: _selectedCategoryType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCategoryType = CategoryType.income;
                              _categoryID = null;
                            });
                          },
                        ),
                        const Text('Income'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          activeColor: Colors.indigo.shade900,
                          value: CategoryType.expense,
                          groupValue: _selectedCategoryType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCategoryType = CategoryType.expense;
                              _categoryID = null;
                            });
                          },
                        ),
                        const Text('Expense'),
                      ],
                    ),
                  ],
                ),
                DropdownButton<String>(
                  hint: const Text('Select Category'),
                  value: _categoryID,
                  items: (_selectedCategoryType == CategoryType.income
                      ? CategoryDB().incomeCategoryListListener
                      : CategoryDB().expenseCategoryListListener)
                      .value
                      .map((e) {
                    return DropdownMenuItem(
                      value: e.id,
                      child: Text(e.name),
                      onTap: () {
                        print(e.toString());
                        _selectedCategoryModel = e;
                      },
                    );
                  }).toList(),
                  onChanged: (selectedValue) {
                    print(selectedValue);
                    setState(() {
                      _categoryID = selectedValue;
                    });
                  },
                ),
                //submit
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Colors.indigo.shade900)),

                    onPressed: () {
                      addTransaction();
                    },
                    child: const Text('Submit',style: TextStyle(color: Colors.white),),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Future<void> addTransaction() async {
    final _purposeText = _purposeTextEditingController.text;
    final _amountText = _amountTextEditingController.text;

    if (_purposeText.isEmpty) {
      return;
    }
    if (_amountText.isEmpty) {
      return;
    }

    if (_selectedDate == null) {
      return;
    }

    if (_selectedCategoryModel == null) {
      return;
    }
    final _parsedAmount = double.tryParse(_amountText);
    if (_parsedAmount == null) {
      return;
    }
    final _model=  TransactionModel(
      purpose: _purposeText,
      amount: _parsedAmount,
      date: _selectedDate!,
      type: _selectedCategoryType!,
      category: _selectedCategoryModel!,
    );

    TransactionDB.instance.addTransaction(_model);
    Navigator.of(context).pop();
    TransactionDB.instance.refresh();
  }
}