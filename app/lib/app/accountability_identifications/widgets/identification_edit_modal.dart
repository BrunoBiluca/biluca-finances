import 'package:biluca_financas/app/accountability_identifications/widgets/identification_icon_catalog.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:biluca_financas/core/accountability/validators/identification_hierarchy_rules.dart';
import 'package:biluca_financas/core/accountability/validators/identification_status_rules.dart';
import 'package:biluca_financas/core/accountability/validators/identification_type_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

const Color _modalFieldBorderColor = Color(0xFF272D36);
const Color _modalFocusedFieldBorderColor = Color(0xFF3A424C);

class IdentificationEditModal extends StatefulWidget {
  final List<AccountabilityIdentification> allIdentifications;
  final AccountabilityIdentification? identification;
  final String? initialParentId;
  final void Function(AccountabilityIdentification) onSave;
  final void Function(String identificationId)? onDelete;

  const IdentificationEditModal({
    super.key,
    required this.allIdentifications,
    required this.onSave,
    this.identification,
    this.initialParentId,
    this.onDelete,
  });

  @override
  State<IdentificationEditModal> createState() => _IdentificationEditModalState();
}

class _IdentificationEditModalState extends State<IdentificationEditModal> {
  late final TextEditingController _descriptionController;
  late String? _parentId;
  late bool _discontinued;
  late AccountabilityIdentificationType _type;
  late IconData _icon;
  late Color _color;
  bool _colorInitialized = false;
  String? _nameError;
  String? _parentError;
  String? _statusError;
  String? _typeError;

  bool get _isEditing => widget.identification != null;

  bool get _hasChildren =>
      widget.identification != null &&
      IdentificationHierarchyRules.hasChildren(
        widget.identification!.id,
        widget.allIdentifications,
      );

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.identification?.description ?? '');
    _parentId = widget.identification?.parentId ?? widget.initialParentId;
    _discontinued = widget.identification?.discontinued ?? false;
    _type = IdentificationTypeRules.inheritedType(
          parentId: _parentId,
          identifications: widget.allIdentifications,
        ) ??
        widget.identification?.type ??
        AccountabilityIdentificationType.expense;
    _icon = widget.identification?.icon ?? Icons.help_outline;
    _color = widget.identification?.color ?? const Color(0xFF38BDF8);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_colorInitialized) {
      _colorInitialized = true;
      if (!_isEditing) {
        _color = Theme.of(context).colorScheme.primary;
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  List<AccountabilityIdentification> get _availableParents {
    return IdentificationHierarchyRules.availableParents(
      editedId: widget.identification?.id,
      editedDiscontinued: _discontinued,
      identifications: widget.allIdentifications,
    );
  }

  void _selectStatus(bool discontinued) {
    setState(() {
      _discontinued = discontinued;
      _statusError = null;
      if (_parentId != null && !_availableParents.any((parent) => parent.id == _parentId)) {
        _parentId = null;
      }
    });
  }

  void _selectParent(String? parentId) {
    setState(() {
      _parentId = parentId;
      _parentError = null;
      _typeError = null;
      final inheritedType = IdentificationTypeRules.inheritedType(
        parentId: parentId,
        identifications: widget.allIdentifications,
      );
      if (inheritedType != null) {
        _type = inheritedType;
      }
    });
  }

  void _save() {
    final description = _descriptionController.text.trim();
    final nameError = description.isEmpty ? 'Informe o nome da categoria' : null;
    final parentError = IdentificationHierarchyRules.validateParent(
      parentId: _parentId,
      editedId: widget.identification?.id,
      editedDiscontinued: _discontinued,
      identifications: widget.allIdentifications,
    );
    String? statusError;
    if (widget.identification != null) {
      statusError = IdentificationStatusRules.validateTransition(
        identification: widget.identification!,
        nextDiscontinued: _discontinued,
        identifications: widget.allIdentifications,
      );
    }
    final typeError = IdentificationTypeRules.validateType(
      parentId: _parentId,
      type: _type,
      identifications: widget.allIdentifications,
    );

    setState(() {
      _nameError = nameError;
      _parentError = parentError;
      _statusError = statusError;
      _typeError = typeError;
    });

    if (nameError != null || parentError != null || statusError != null || typeError != null) {
      return;
    }

    final AccountabilityIdentification saved;
    if (widget.identification == null) {
      saved = AccountabilityIdentification(
        description,
        _color,
        parentId: _parentId,
        discontinued: _discontinued,
        type: _type,
      )..icon = _icon;
    } else {
      saved = widget.identification!.copyWith(
        description: description,
        color: _color,
        icon: _icon,
        type: _type,
        parentId: _parentId,
        clearParent: _parentId == null,
        discontinued: _discontinued,
      );
    }

    widget.onSave(saved);
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final identification = widget.identification;
    if (identification == null || widget.onDelete == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: const Text(
          'Os lançamentos vinculados ficarão sem identificação e as subcategorias serão promovidas a categorias raiz. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            key: const Key('identification-delete-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('identification-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete!(identification.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _pickIcon() async {
    final theme = Theme.of(context);
    final newIcon = await showIconPicker(
      context,
      configuration: SinglePickerConfiguration(
        title: const Text("Selecionar ícone"),
        adaptiveDialog: true,
        showTooltips: true,
        searchHintText: "Procure pelo ícone",
        showSearchBar: true,
        noResultsText: "Sem resultados para:",
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        iconSize: 24,
        iconColor: theme.colorScheme.onSurface,
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        selectedIconBackgroundColor: theme.colorScheme.surfaceContainerHigh,
        constraints: const BoxConstraints(
          maxHeight: 420,
          minWidth: 320,
          maxWidth: 520,
        ),
        iconPickerShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        iconPackModes: const [],
        customIconPack: identificationIconCatalog,
        searchComparator: (String search, IconPickerIcon icon) =>
            search.toLowerCase().contains(icon.name.replaceAll('_', ' ').toLowerCase()) ||
            icon.name.toLowerCase().contains(search.toLowerCase()),
      ),
    );

    if (newIcon != null) {
      setState(() => _icon = newIcon.data);
    }
  }

  Future<void> _pickColor() async {
    final selected = await showDialog<Color>(
      context: context,
      builder: (context) => _ColorPickerDialog(initialColor: _color),
    );

    if (selected != null) {
      setState(() => _color = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 620, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNameField(context),
                    const SizedBox(height: 16),
                    _buildParentField(context),
                    const SizedBox(height: 16),
                    _buildStatusField(context),
                    const SizedBox(height: 16),
                    _buildTypeField(context),
                    const SizedBox(height: 16),
                    _buildIconAndColorFields(context),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _discontinued ? theme.colorScheme.tertiary : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withValues(alpha: 0.35)),
            ),
            child: Icon(_icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Editar identificação' : 'Nova identificação',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _isEditing ? widget.identification!.description : 'Configure os dados da nova categoria',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('identification-modal-close'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      key: const Key('identification-name-field'),
      controller: _descriptionController,
      autofocus: !_isEditing,
      onChanged: (_) {
        if (_nameError != null) setState(() => _nameError = null);
      },
      decoration: InputDecoration(
        labelText: 'Nome da identificação',
        errorText: _nameError,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _modalFieldBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _modalFieldBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _modalFocusedFieldBorderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
      ),
    );
  }

  Widget _parentOption(
    BuildContext context,
    AccountabilityIdentification? parent, {
    Key? key,
  }) {
    final theme = Theme.of(context);
    final color = parent?.color ?? theme.colorScheme.onSurfaceVariant;
    final description = parent == null
        ? 'Nenhuma (categoria pai)'
        : '${parent.description}${parent.discontinued ? ' (descontinuada)' : ''}';

    return Row(
      key: key,
      children: [
        Icon(parent?.icon ?? Icons.help_outline, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParentField(BuildContext context) {
    final theme = Theme.of(context);
    final parents = _availableParents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Categoria pai',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '1 nível máximo',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          key: const Key('identification-parent-container'),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _parentError != null ? theme.colorScheme.error : _modalFieldBorderColor,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              key: const Key('identification-parent-field'),
              value: _parentId,
              isExpanded: true,
              onChanged: _hasChildren ? null : _selectParent,
              selectedItemBuilder: (context) => [
                _parentOption(
                  context,
                  null,
                  key: const Key('identification-parent-selected-none'),
                ),
                ...parents.map(
                  (parent) => _parentOption(
                    context,
                    parent,
                    key: Key(
                      'identification-parent-selected-${parent.id}',
                    ),
                  ),
                ),
              ],
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: _parentOption(
                    context,
                    null,
                    key: const Key('identification-parent-option-none'),
                  ),
                ),
                ...parents.map(
                  (parent) => DropdownMenuItem<String?>(
                    value: parent.id,
                    child: _parentOption(
                      context,
                      parent,
                      key: Key(
                        'identification-parent-option-${parent.id}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_hasChildren)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Esta categoria possui subcategorias e não pode ser filha de outra categoria.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (_parentError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _parentError!,
              key: const Key('identification-parent-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusField(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status de operação',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _StatusOption(
                key: const Key('identification-status-active'),
                label: 'Ativa',
                description: 'Disponível para novos lançamentos',
                icon: Icons.check_circle_outline,
                color: theme.colorScheme.secondary,
                selected: !_discontinued,
                hasError: _statusError != null,
                onTap: () => _selectStatus(false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatusOption(
                key: const Key('identification-status-discontinued'),
                label: 'Descontinuada',
                description: 'Somente leitura no histórico',
                icon: Icons.archive_outlined,
                color: theme.colorScheme.tertiary,
                selected: _discontinued,
                hasError: _statusError != null,
                onTap: () => _selectStatus(true),
              ),
            ),
          ],
        ),
        if (_statusError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _statusError!,
              key: const Key('identification-status-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeField(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          key: const Key('identification-type-container'),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _typeError != null ? theme.colorScheme.error : _modalFieldBorderColor,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AccountabilityIdentificationType>(
              key: const Key('identification-type-field'),
              value: _type,
              isExpanded: true,
              onChanged: _parentId == null
                  ? (value) {
                      if (value == null) return;
                      setState(() {
                        _type = value;
                        _typeError = null;
                      });
                    }
                  : null,
              items: AccountabilityIdentificationType.values
                  .map(
                    (type) => DropdownMenuItem<AccountabilityIdentificationType>(
                      value: type,
                      child: Text(type.label),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        if (_parentId != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'O tipo é herdado da categoria pai.',
              key: const Key('identification-type-helper'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (_typeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _typeError!,
              key: const Key('identification-type-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIconAndColorFields(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ícone',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                key: const Key('identification-icon-button'),
                onTap: _pickIcon,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  key: const Key('identification-icon-container'),
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _modalFieldBorderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(_icon, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alterar ícone',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cor',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                key: const Key('identification-color-button'),
                onTap: _pickColor,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  key: const Key('identification-color-container'),
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _modalFieldBorderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '#${_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_isEditing && widget.onDelete != null)
            IconButton(
              key: const Key('identification-delete'),
              onPressed: _confirmDelete,
              tooltip: 'Excluir categoria',
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
            ),
          const Spacer(),
          TextButton(
            key: const Key('identification-cancel'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            key: const Key('identification-save'),
            onPressed: _save,
            child: Text(_isEditing ? 'Salvar alterações' : 'Criar categoria'),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool selected;
  final bool hasError;
  final VoidCallback onTap;

  const _StatusOption({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasError ? theme.colorScheme.error : _modalFieldBorderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: selected ? color : theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: selected ? color : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _color;
  late final TextEditingController _hexController;
  String? _hexError;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
    _hexController = TextEditingController(text: _hex(_color));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _hex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
    return '#$value';
  }

  Color? _parseHex(String value) {
    final normalized = value.replaceAll('#', '').trim();
    if (normalized.length != 6) return null;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return null;
    return Color(0xFF000000 | parsed);
  }

  void _onHexChanged(String value) {
    final parsed = _parseHex(value);
    setState(() {
      _hexError = parsed == null ? 'Informe uma cor no formato #RRGGBB' : null;
      if (parsed != null) _color = parsed;
    });
  }

  void _save() {
    final parsed = _parseHex(_hexController.text);
    if (parsed == null) {
      setState(() => _hexError = 'Informe uma cor no formato #RRGGBB');
      return;
    }
    Navigator.of(context).pop(_color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Cor da categoria'),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorPicker(
                pickerColor: _color,
                onColorChanged: (color) {
                  setState(() {
                    _color = color;
                    _hexController.text = _hex(color);
                    _hexController.selection = TextSelection.collapsed(
                      offset: _hexController.text.length,
                    );
                  });
                },
                enableAlpha: false,
                portraitOnly: true,
                pickerAreaHeightPercent: 0.45,
                hexInputBar: false,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('identification-color-hex-field'),
                controller: _hexController,
                onChanged: _onHexChanged,
                decoration: InputDecoration(
                  labelText: 'Cor hexadecimal',
                  hintText: '#RRGGBB',
                  errorText: _hexError,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _modalFieldBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _modalFieldBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: _modalFocusedFieldBorderColor,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          key: const Key('identification-color-save'),
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
