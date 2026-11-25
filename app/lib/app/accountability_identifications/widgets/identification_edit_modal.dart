import 'package:biluca_financas/app/accountability_identifications/widgets/identification_color_picker_dialog.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_edit_footer.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_edit_header.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_icon_color_fields.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_icon_catalog.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_parent_field.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_status_field.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_text_field.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_type_field.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:biluca_financas/core/accountability/validators/identification_hierarchy_rules.dart';
import 'package:biluca_financas/core/accountability/validators/identification_status_rules.dart';
import 'package:biluca_financas/core/accountability/validators/identification_type_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

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
  State<IdentificationEditModal> createState() =>
      _IdentificationEditModalState();
}

class _IdentificationEditModalState extends State<IdentificationEditModal> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _descriptionDetailController;
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

  List<AccountabilityIdentification> get _availableParents =>
      IdentificationHierarchyRules.availableParents(
        editedId: widget.identification?.id,
        editedDiscontinued: _discontinued,
        identifications: widget.allIdentifications,
      );

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.identification?.description ?? '');
    _descriptionDetailController = TextEditingController(
      text: widget.identification?.descriptionDetail ?? '',
    );
    _parentId = widget.identification?.parentId ?? widget.initialParentId;
    _discontinued = widget.identification?.discontinued ?? false;
    _type = IdentificationTypeRules.inheritedType(
          parentId: _parentId,
          identifications: widget.allIdentifications,
        ) ??
        widget.identification?.type ??
        AccountabilityIdentificationType.expense;
    _icon = widget.identification?.icon ?? Icons.help_outline;
    _color = widget.identification?.color ?? Colors.transparent;
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
    _descriptionDetailController.dispose();
    super.dispose();
  }

  void _selectStatus(bool discontinued) {
    setState(() {
      _discontinued = discontinued;
      _statusError = null;
      if (_parentId != null &&
          !_availableParents.any((parent) => parent.id == _parentId)) {
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

  void _selectType(AccountabilityIdentificationType type) {
    setState(() {
      _type = type;
      _typeError = null;
    });
  }

  void _save() {
    final description = _descriptionController.text.trim();
    final descriptionDetail = _descriptionDetailController.text.trim();
    final nameError =
        description.isEmpty ? 'Informe o nome da categoria' : null;
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

    if (nameError != null ||
        parentError != null ||
        statusError != null ||
        typeError != null) {
      return;
    }

    final AccountabilityIdentification saved;
    if (widget.identification == null) {
      saved = AccountabilityIdentification(
        description,
        _color,
        descriptionDetail: descriptionDetail,
        parentId: _parentId,
        discontinued: _discontinued,
        type: _type,
      )..icon = _icon;
    } else {
      saved = widget.identification!.copyWith(
        description: description,
        descriptionDetail: descriptionDetail,
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
        iconPickerShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        iconPackModes: const [],
        customIconPack: identificationIconCatalog,
        searchComparator: (String search, IconPickerIcon icon) =>
            search.toLowerCase().contains(
                  icon.name.replaceAll('_', ' ').toLowerCase(),
                ) ||
            icon.name.toLowerCase().contains(search.toLowerCase()),
      ),
    );

    if (newIcon != null) {
      setState(() => _icon = newIcon.data);
    }
  }

  Future<void> _pickColor() async {
    final selected =
        await IdentificationColorPickerDialog.show(context, _color);
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
            IdentificationEditHeader(
              icon: _icon,
              isEditing: _isEditing,
              discontinued: _discontinued,
              description: widget.identification?.description,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IdentificationTextField(
                      fieldKey: const Key('identification-name-field'),
                      controller: _descriptionController,
                      label: 'Nome da identificação',
                      autofocus: !_isEditing,
                      errorText: _nameError,
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    IdentificationTextField(
                      fieldKey: const Key(
                        'identification-description-detail-field',
                      ),
                      controller: _descriptionDetailController,
                      label: 'Descrição',
                      hintText:
                          'Informações adicionais sobre esta identificação',
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    IdentificationParentField(
                      parents: _availableParents,
                      parentId: _parentId,
                      error: _parentError,
                      hasChildren: _hasChildren,
                      onChanged: _selectParent,
                    ),
                    const SizedBox(height: 16),
                    IdentificationStatusField(
                      discontinued: _discontinued,
                      error: _statusError,
                      onChanged: _selectStatus,
                    ),
                    const SizedBox(height: 16),
                    IdentificationTypeField(
                      type: _type,
                      parentId: _parentId,
                      error: _typeError,
                      onChanged: _selectType,
                    ),
                    const SizedBox(height: 16),
                    IdentificationIconColorFields(
                      icon: _icon,
                      color: _color,
                      onPickIcon: _pickIcon,
                      onPickColor: _pickColor,
                    ),
                  ],
                ),
              ),
            ),
            IdentificationEditFooter(
              isEditing: _isEditing,
              canDelete: widget.onDelete != null,
              onSave: _save,
              onDelete: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }
}
