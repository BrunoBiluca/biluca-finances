import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Obsidian Wealth',
      theme: AppTheme.darkTheme(),
      // theme: AppTheme.lightTheme(), // Descomente para usar o tema light
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título da seção
              Text(
                'Visão Geral',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.02,
                ),
              ),
              SizedBox(height: 24),

              // Grid de KPIs
              Row(
                children: [
                  Expanded(child: KPICard(
                    title: 'Saldo Total',
                    value: 'R$ 847.532,40',
                    change: '+12.5%',
                    isPositive: true,
                    icon: Icons.account_balance_wallet_outlined,
                  )),
                  SizedBox(width: 16),
                  Expanded(child: KPICard(
                    title: 'Receitas (Mês)',
                    value: 'R$ 32.450,00',
                    change: '+8.3%',
                    isPositive: true,
                    icon: Icons.trending_up_outlined,
                  )),
                  SizedBox(width: 16),
                  Expanded(child: KPICard(
                    title: 'Despesas (Mês)',
                    value: 'R$ 18.230,00',
                    change: '-3.1%',
                    isPositive: false,
                    icon: Icons.trending_down_outlined,
                  )),
                  SizedBox(width: 16),
                  Expanded(child: KPICard(
                    title: 'ROI (Último Ano)',
                    value: '22.8%',
                    change: '+4.2%',
                    isPositive: true,
                    icon: Icons.analytics_outlined,
                  )),
                ],
              ),
              SizedBox(height: 32),

              // Tabela de Transações
              Text(
                'Transações Recentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.015,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: TransactionsTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Card de KPI
class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  const KPICard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título com ícone
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
                // Badge de variação
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive 
                        ? AppTheme.positiveYield.withOpacity(0.12)
                        : AppTheme.expenseRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isPositive ? AppTheme.positiveYield : AppTheme.expenseRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        change,
                        style: TextStyle(
                          fontFamily: AppTheme.fontJetBrainsMono,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? AppTheme.positiveYield : AppTheme.expenseRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontFamily: AppTheme.fontGeist,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textHigh,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isPositive 
                    ? AppTheme.positiveYield.withOpacity(0.08)
                    : AppTheme.expenseRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isPositive ? '↑ Acima da meta' : '↓ Abaixo da meta',
                style: TextStyle(
                  fontFamily: AppTheme.fontInter,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isPositive ? AppTheme.positiveYield : AppTheme.expenseRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tabela de Transações
class TransactionsTable extends StatelessWidget {
  const TransactionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      Transaction(
        category: 'Alimentação',
        description: 'Supermercado Semanal',
        date: 'Hoje, 14:30',
        amount: -452.90,
        icon: Icons.shopping_basket_outlined,
        categoryColor: AppTheme.secondaryIndigo,
      ),
      Transaction(
        category: 'Salário',
        description: 'Pagamento Mensal',
        date: 'Ontem, 09:00',
        amount: 12500.00,
        icon: Icons.attach_money_outlined,
        categoryColor: AppTheme.positiveYield,
      ),
      Transaction(
        category: 'Utilidades',
        description: 'Conta de Luz - Junho',
        date: '02/06/2026, 10:15',
        amount: -287.50,
        icon: Icons.flash_on_outlined,
        categoryColor: AppTheme.accentCyan,
      ),
      Transaction(
        category: 'Investimento',
        description: 'Ações - Vale SA',
        date: '01/06/2026, 16:45',
        amount: 3450.00,
        icon: Icons.trending_up_outlined,
        categoryColor: AppTheme.positiveYield,
      ),
      Transaction(
        category: 'Saúde',
        description: 'Plano de Saúde',
        date: '01/06/2026, 08:30',
        amount: -189.90,
        icon: Icons.health_and_safety_outlined,
        categoryColor: AppTheme.expenseRed,
      ),
      Transaction(
        category: 'Transporte',
        description: 'Uber - Viagens',
        date: '31/05/2026, 22:00',
        amount: -45.80,
        icon: Icons.directions_car_outlined,
        categoryColor: AppTheme.secondaryIndigo,
      ),
    ];

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da tabela
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 40), // Espaço para o ícone
                Expanded(
                  flex: 2,
                  child: Text(
                    'DESCRIÇÃO',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textLow,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'CATEGORIA',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textLow,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'DATA',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textLow,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    'VALOR',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textLow,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 0.5),
          // Linhas da tabela
          ...transactions.map((t) => TransactionRow(transaction: t)),
        ],
      ),
    );
  }
}

class Transaction {
  final String category;
  final String description;
  final String date;
  final double amount;
  final IconData icon;
  final Color categoryColor;

  const Transaction({
    required this.category,
    required this.description,
    required this.date,
    required this.amount,
    required this.icon,
    required this.categoryColor,
  });
}

class TransactionRow extends StatefulWidget {
  final Transaction transaction;

  const TransactionRow({super.key, required this.transaction});

  @override
  State<TransactionRow> createState() => _TransactionRowState();
}

class _TransactionRowState extends State<TransactionRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.transaction.amount > 0;
    final absAmount = widget.transaction.amount.abs();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: 52,
        color: _isHovered 
            ? const Color(0xFF172138) 
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Ícone da categoria
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.transaction.categoryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.transaction.icon,
                size: 18,
                color: widget.transaction.categoryColor,
              ),
            ),
            const SizedBox(width: 12),
            // Descrição
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.transaction.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textHigh,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Categoria
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.transaction.categoryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  widget.transaction.category,
                  style: TextStyle(
                    fontFamily: AppTheme.fontInter,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: widget.transaction.categoryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Data
            Expanded(
              flex: 1,
              child: Text(
                widget.transaction.date,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            // Valor
            SizedBox(
              width: 120,
              child: Text(
                '${isPositive ? '+' : '-'} R\$ ${absAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: AppTheme.fontJetBrainsMono,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isPositive ? AppTheme.positiveYield : AppTheme.expenseRed,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}