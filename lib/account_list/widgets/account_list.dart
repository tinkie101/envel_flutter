import 'package:envel_flutter/models/acount_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AccountList extends StatelessWidget {
  const AccountList(this.accounts, this.onSelected, this.onRefresh, {Key? key}) : super(key: key);

  final List<AccountModel> accounts;
  final Function(AccountModel)? onSelected;
  final VoidCallback? onRefresh;

  final String createAccount = """
      mutation createAccount {
        createAccount {
          id
        }
      }
    """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getDisplayWidget(),
      floatingActionButton: Mutation(
        options: MutationOptions(
            document: gql(createAccount),
            onError: (OperationException? error) => SnackBar(
                  content: Text(error.toString()),
                  duration: const Duration(seconds: 3),
                ),
            onCompleted: (dynamic resultData) => const SnackBar(
                  content: Text("Created new account"),
                  duration: Duration(seconds: 3),
                )),
        builder: (RunMutation _mutate, QueryResult? addResult) {
          mutate() => _mutate({}, optimisticResult: false);
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: () {
                    print("mutate");
                    mutate();
                  },
                  tooltip: 'Create Account',
                  child: const Icon(Icons.add),
                ),
              ),
              if (onRefresh != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    backgroundColor: Colors.lightBlueAccent,
                    onPressed: () {
                      print("refresh");
                      onRefresh!();
                    },
                    tooltip: 'Refresh',
                    child: const Icon(Icons.refresh),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  getDisplayWidget() {
    if (accounts.isEmpty) {
      return const Text("No accounts found");
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          var account = accounts[index];
          return Container(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Card(
                child: InkWell(
                  splashColor: Theme.of(context).colorScheme.secondary,
                  splashFactory: InkRipple.splashFactory,
                  onTap: () {
                    if (onSelected != null) {
                      onSelected!(account);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              account.id,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text("\$${account.balance.toString()}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  )),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
