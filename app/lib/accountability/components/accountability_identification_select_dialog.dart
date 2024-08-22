import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:biluca_financas/components/text_ballon.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AccountabilityIdentificationSelectDialog extends StatelessWidget {
  const AccountabilityIdentificationSelectDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Texto'),
      content: FutureBuilder(
        future: GetIt.I<AccountabilityRepo>().getIdentifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          var identifications = snapshot.data!;

          return Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  ...identifications.map(
                    (identification) => GestureDetector(
                      onTap: () {
                        Navigator.pop(context, identification);
                      },
                      child: TextBallon(
                        text: identification.description,
                        color: identification.color,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
