import 'package:envel_flutter/account_list/widgets/account_details.dart';
import 'package:envel_flutter/account_list/widgets/account_list.dart';
import 'package:envel_flutter/models/acount_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage(this.accounts, this.onRefresh, {Key? key}) : super(key: key);

  final List<AccountModel> accounts;
  final VoidCallback? onRefresh;

  @override
  State createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  AccountModel? _selectedAccount;

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(
          key: const ValueKey("accounts_list"),
          child: AccountList(
              widget.accounts,
              (account) => setState(() {
                    _selectedAccount = account;
                    print("Account ${account.id}");
                  },
              ),
              widget.onRefresh
          ),
        ),
        if (_selectedAccount != null)
          MaterialPage(
            key: const ValueKey("account_details"),
            child: AccountDetails(_selectedAccount!),
          )
      ],
      onPopPage: (route, result) {
        _selectedAccount = null;
        return route.didPop(result);
      },
    );
  }
}
