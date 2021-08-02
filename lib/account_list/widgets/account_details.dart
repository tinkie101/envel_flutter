import 'package:envel_flutter/enums/transaction_type.dart';
import 'package:envel_flutter/models/acount_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails(this.account, {Key? key}) : super(key: key);

  final AccountModel account;

  @override
  State createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _amount = 0;
  TransactionType _transactionType = TransactionType.deposit;

  String withdraw = """
    mutation withdraw(\$accountId: UUID, \$amount: BigDecimal) {
      withdraw(withdrawalAccount: {accountId: \$accountId, amount: \$amount})
    }
  """;

  String deposit = """
    mutation deposit(\$accountId: UUID, \$amount: BigDecimal) {
      BigDecimal: deposit(depositAccount: {accountId: \$accountId, amount: \$amount})
    }
  """;

  _submitForm(context, method) async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await method({'accountId': widget.account.id, 'amount': _amount});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Submitted"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Amount',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              try {
                                final text = newValue.text;
                                if (text.isNotEmpty) double.parse(text);
                                return newValue;
                              } catch (e) {}
                              return oldValue;
                            }),
                          ],
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'required';
                            }
                          },
                          onSaved: (value) {
                            _amount = double.parse(value!);
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: const Text("Withdraw"),
                        leading: Radio<TransactionType>(
                          value: TransactionType.withdraw,
                          groupValue: _transactionType,
                          onChanged: (TransactionType? value) {
                            setState(() {
                              _transactionType = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: const Text("Deposit"),
                        leading: Radio<TransactionType>(
                          value: TransactionType.deposit,
                          groupValue: _transactionType,
                          onChanged: (TransactionType? value) {
                            setState(() {
                              _transactionType = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    if(_transactionType == TransactionType.withdraw)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Mutation(
                          options: MutationOptions(
                              document: gql(withdraw),
                              onError: (OperationException? error) => SnackBar(
                                content: Text(error.toString()),
                                duration: const Duration(seconds: 3),
                              ),
                              onCompleted: (dynamic resultData) => const SnackBar(
                                content: Text("Created new account"),
                                duration: Duration(seconds: 3),
                              )),
                          builder: (RunMutation _mutate, QueryResult? addResult) {
                            return ElevatedButton(
                              onPressed: () => _submitForm(context, _mutate),
                              child: const Text('Submit Withdrawal'),
                            );
                          },
                        ),
                      ),
                    if(_transactionType == TransactionType.deposit)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Mutation(
                          options: MutationOptions(
                              document: gql(deposit),
                              onError: (OperationException? error) => SnackBar(
                                content: Text(error.toString()),
                                duration: const Duration(seconds: 3),
                              ),
                              onCompleted: (dynamic resultData) => const SnackBar(
                                content: Text("Created new account"),
                                duration: Duration(seconds: 3),
                              )),
                          builder: (RunMutation _mutate, QueryResult? addResult) {
                            return ElevatedButton(
                              onPressed: () => _submitForm(context, _mutate),
                              child: const Text('Submit Deposit'),
                            );
                          },
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
