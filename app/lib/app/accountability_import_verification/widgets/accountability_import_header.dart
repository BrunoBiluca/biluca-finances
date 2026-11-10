import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class AccountabilityImportHeader extends StatelessWidget {
  final String sourceFileName;
  final double netBalance;
  final VoidCallback onClose;

  const AccountabilityImportHeader({
    super.key,
    required this.sourceFileName,
    required this.netBalance,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = _buildTitle(theme);
          final meta = _buildMeta(context, theme);
          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 16),
                meta,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 16),
              meta,
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.account_balance_outlined,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conferência de Importação de Extratos',
                key: const Key('import-verification-title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 2),
              Text(
                'Valide as correspondências, identifique regras de conciliação e descarte duplicidades bancárias.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeta(BuildContext context, ThemeData theme) {
    final balanceColor = _balanceColor(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _infoChip(
          theme: theme,
          key: const Key('import-file-name'),
          icon: Icons.description_outlined,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              sourceFileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        _infoChip(
          theme: theme,
          key: const Key('import-net-balance'),
          borderColor: balanceColor.withValues(alpha: 0.45),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Saldo Líquido',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formattedBalance,
                key: const Key('import-net-balance-value'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: balanceColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('close-import-verification'),
          onPressed: onClose,
          tooltip: 'Fechar janela',
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _infoChip({
    required ThemeData theme,
    required Widget child,
    Key? key,
    Color? borderColor,
    IconData? icon,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ??
              theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
          ],
          child,
        ],
      ),
    );
  }

  String get _formattedBalance {
    final formatted =
        NumberFormat.simpleCurrency(locale: 'pt_BR').format(netBalance);
    return netBalance > 0 ? '+$formatted' : formatted;
  }

  Color _balanceColor(BuildContext context) {
    final colors = GetIt.I<ThemeManager>().getCurrentTheme(context).colors;
    if (netBalance > 0) return colors.positiveYield;
    if (netBalance < 0) return colors.negativeYield;
    return colors.neutralYield;
  }
}
