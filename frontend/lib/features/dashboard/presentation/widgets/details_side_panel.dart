import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';
import 'package:frontend/features/dashboard/presentation/utils/widget_labels.dart';
import 'package:frontend/features/dashboard/presentation/widgets/provider_logo.dart';

enum DetailsPanelPlacement { side, bottom }

class DetailsSidePanel extends StatelessWidget {
  final DashboardWidgetItem item;
  final DetailsPanelPlacement placement;
  final VoidCallback? onClose;
  final bool showCard;
  final VoidCallback? onDelete;

  const DetailsSidePanel({
    super.key,
    required this.item,
    this.placement = DetailsPanelPlacement.side,
    this.onClose,
    this.showCard = true,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final description = item.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    final dynamicDataSection = _buildDynamicDataSection(
      colorScheme: colorScheme,
      textTheme: textTheme,
    );

    final content = SingleChildScrollView(
      primary: false,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colorScheme: colorScheme, textTheme: textTheme),
          const SizedBox(height: AppSpacing.lg),
          _buildPrimaryValueSection(
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildOverviewSection(
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          if (item.status == WidgetStatus.inactive) ...[
            const SizedBox(height: AppSpacing.md),
            _buildMissingDataNotice(
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ],
          if (hasDescription) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildDescriptionSection(
              colorScheme: colorScheme,
              textTheme: textTheme,
              description: description,
            ),
          ],
          if (dynamicDataSection != null) ...[
            const SizedBox(height: AppSpacing.lg),
            dynamicDataSection,
          ],
          if (onDelete != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildDeleteAction(colorScheme: colorScheme),
          ],
        ],
      ),
    );

    if (!showCard) {
      return content;
    }

    return Card(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.50),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 2.5,
        ),
      ),
      child: content,
    );
  }

  Widget _buildHeader({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHeaderLeading(colorScheme: colorScheme),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      WidgetLabels.type(item.type),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildHeaderStatusBadge(
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (onClose != null) ...[
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onClose,
            icon: Icon(_closeIconForPlacement(), size: 28),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderLeading({required ColorScheme colorScheme}) {
    final provider = item.provider?.trim();

    if (provider != null && provider.isNotEmpty) {
      return SizedBox(
        width: 46,
        height: 46,
        child: Center(child: ProviderLogo(provider: provider, size: 36)),
      );
    }

    return SizedBox(
      width: 46,
      height: 46,
      child: Center(
        child: Icon(
          _iconForType(item.type),
          color: AppColors.primary,
          size: 34,
        ),
      ),
    );
  }

  Widget _buildHeaderStatusBadge({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final statusColor = _statusColor(colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        WidgetLabels.status(item.status),
        style: textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPrimaryValueSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final isInactive = item.status == WidgetStatus.inactive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Valor actual',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.primaryValue,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: isInactive
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final provider = _formatLabel(item.provider);
    final dataType = _formatLabel(item.dataType);
    final updatedAt = _formatDateTime(item.updatedAt);
    final ttl = item.ttl;

    return _buildSectionCard(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.info_outline_rounded,
            title: 'Resumen',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (provider != null)
            _buildInfoRow(
              colorScheme: colorScheme,
              textTheme: textTheme,
              label: 'Provider',
              value: provider,
            ),
          if (dataType != null)
            _buildInfoRow(
              colorScheme: colorScheme,
              textTheme: textTheme,
              label: 'Tipo de dato',
              value: dataType,
            ),
          if (item.count != null)
            _buildInfoRow(
              colorScheme: colorScheme,
              textTheme: textTheme,
              label: 'Elementos',
              value: item.count.toString(),
            ),
          if (updatedAt != null)
            _buildInfoRow(
              colorScheme: colorScheme,
              textTheme: textTheme,
              label: 'Actualizado',
              value: updatedAt,
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildDynamicDataSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final rawData = item.rawData;

    if (rawData == null || rawData.isEmpty) {
      return null;
    }

    switch (item.dataType?.toUpperCase().trim()) {
      case 'PROJECTS':
        return _buildProjectsDetails(
          colorScheme: colorScheme,
          textTheme: textTheme,
        );

      case 'ISSUES':
        return _buildIssuesDetails(
          colorScheme: colorScheme,
          textTheme: textTheme,
        );

      case 'MERGE_REQUESTS':
        return _buildMergeRequestsDetails(
          colorScheme: colorScheme,
          textTheme: textTheme,
        );

      case 'VIRTUAL_MACHINES':
        return _buildVirtualMachinesDetails(
          colorScheme: colorScheme,
          textTheme: textTheme,
        );

      case 'KEY_VAULTS':
        return _buildKeyVaultsDetails(
          colorScheme: colorScheme,
          textTheme: textTheme,
        );

      case 'COST_MANAGEMENT':
        return _buildCostManagementDetails(
          colorScheme: colorScheme,
          textTheme: textTheme,
        );

      case 'SYSTEM_DATA':
        return _buildSystemDataDetails(
          colorScheme: colorScheme,
          textTheme: textTheme,
        );

      default:
        return _buildGenericItemsDetails(
          colorScheme: colorScheme,
          textTheme: textTheme,
        );
    }
  }

  Widget _buildProjectsDetails({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return _buildItemsSection(
      colorScheme: colorScheme,
      textTheme: textTheme,
      title: 'Proyectos',
      icon: Icons.folder_copy_outlined,
      emptyText: 'No hay proyectos para mostrar.',
      itemBuilder: (project) {
        final name = _stringOrNull(project['name']) ?? 'Proyecto sin nombre';
        final visibility = _formatLabel(project['visibility']);
        final openIssues = _stringOrNull(project['open_issues']);
        final description = _stringOrNull(project['description']);

        return _buildItemCard(
          colorScheme: colorScheme,
          textTheme: textTheme,
          title: name,
          subtitle: description,
          rows: [
            if (visibility != null) 'Visibilidad: $visibility',
            if (openIssues != null) 'Issues abiertas: $openIssues',
          ],
        );
      },
    );
  }

  Widget _buildIssuesDetails({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return _buildItemsSection(
      colorScheme: colorScheme,
      textTheme: textTheme,
      title: 'Issues',
      icon: Icons.bug_report_outlined,
      emptyText: 'No hay issues para mostrar.',
      itemBuilder: (issue) {
        final title = _stringOrNull(issue['title']) ?? 'Issue sin título';
        final state = _formatLabel(issue['state']);
        final labels = _stringList(issue['labels']);
        final assignees = _stringList(issue['assignees']);
        final milestone = _stringOrNull(issue['milestone']);
        final dueDate = _stringOrNull(issue['due_date']);

        return _buildItemCard(
          colorScheme: colorScheme,
          textTheme: textTheme,
          title: title,
          rows: [
            if (state != null) 'Estado: $state',
            if (labels.isNotEmpty) 'Labels: ${labels.join(', ')}',
            if (assignees.isNotEmpty) 'Asignado: ${assignees.join(', ')}',
            if (milestone != null) 'Milestone: $milestone',
            if (dueDate != null) 'Due date: $dueDate',
          ],
        );
      },
    );
  }

  Widget _buildMergeRequestsDetails({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return _buildItemsSection(
      colorScheme: colorScheme,
      textTheme: textTheme,
      title: 'Merge requests',
      icon: Icons.account_tree_outlined,
      emptyText: 'No hay merge requests para mostrar.',
      itemBuilder: (mergeRequest) {
        final title =
            _stringOrNull(mergeRequest['title']) ?? 'Merge request sin título';
        final state = _formatLabel(mergeRequest['state']);
        final sourceBranch = _stringOrNull(mergeRequest['source_branch']);
        final targetBranch = _stringOrNull(mergeRequest['target_branch']);
        final author = _stringOrNull(mergeRequest['author']);
        final assignees = _stringList(mergeRequest['assignees']);
        final reviewers = _stringList(mergeRequest['reviewers']);

        return _buildItemCard(
          colorScheme: colorScheme,
          textTheme: textTheme,
          title: title,
          rows: [
            if (state != null) 'Estado: $state',
            if (sourceBranch != null && targetBranch != null)
              '$sourceBranch → $targetBranch',
            if (author != null) 'Autor: $author',
            if (assignees.isNotEmpty) 'Asignado: ${assignees.join(', ')}',
            if (reviewers.isNotEmpty) 'Reviewers: ${reviewers.join(', ')}',
          ],
        );
      },
    );
  }

  Widget _buildVirtualMachinesDetails({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return _buildItemsSection(
      colorScheme: colorScheme,
      textTheme: textTheme,
      title: 'Máquinas virtuales',
      icon: Icons.memory_outlined,
      emptyText: 'No hay máquinas virtuales para mostrar.',
      itemBuilder: (vm) {
        final name = _stringOrNull(vm['name']) ?? 'Máquina sin nombre';
        final location = _stringOrNull(vm['location']);
        final sku = _stringOrNull(vm['vm_sku']);
        final osType = _stringOrNull(vm['os_type']);
        final osDistro = _stringOrNull(vm['os_distro']);
        final powerState =
            _stringOrNull(vm['power_state']) ?? _stringOrNull(vm['power_status']);
        final diskSize = _stringOrNull(vm['disk_size']);

        return _buildItemCard(
          colorScheme: colorScheme,
          textTheme: textTheme,
          title: name,
          rows: [
            if (powerState != null) 'Estado: $powerState',
            if (location != null) 'Región: $location',
            if (sku != null) 'SKU: $sku',
            if (osType != null || osDistro != null)
              'Sistema: ${[osType, osDistro].whereType<String>().join(' · ')}',
            if (diskSize != null) 'Disco: $diskSize GB',
          ],
        );
      },
    );
  }

  Widget _buildKeyVaultsDetails({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return _buildItemsSection(
      colorScheme: colorScheme,
      textTheme: textTheme,
      title: 'Key Vaults',
      icon: Icons.vpn_key_outlined,
      emptyText: 'No hay Key Vaults para mostrar.',
      itemBuilder: (vault) {
        final name = _stringOrNull(vault['name']) ?? 'Key Vault sin nombre';
        final location = _stringOrNull(vault['location']);

        return _buildItemCard(
          colorScheme: colorScheme,
          textTheme: textTheme,
          title: name,
          rows: [
            if (location != null) 'Región: $location',
          ],
        );
      },
    );
  }

  Widget _buildCostManagementDetails({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final firstItem = _firstItemFromRawData();
    final currency = _stringOrNull(firstItem?['currency']);
    final resourceCosts = _mapList(firstItem?['resource_cost']);
    final timeframe = _stringOrNull(item.customConfig?['timeframe']);

    return _buildSectionCard(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.euro_outlined,
            title: 'Costes',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (timeframe != null)
            _buildInfoRow(
              colorScheme: colorScheme,
              textTheme: textTheme,
              label: 'Periodo',
              value: timeframe,
            ),
          if (resourceCosts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Desglose',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final resourceCost in resourceCosts)
              _buildInfoRow(
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: _stringOrNull(resourceCost['resource']) ?? 'Recurso',
                value: _formatCurrency(
                  _numberOrNull(resourceCost['cost']) ?? 0,
                  _stringOrNull(resourceCost['currency']) ?? currency,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemDataDetails({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final firstItem = _firstItemFromRawData();
    final agentData = _mapOrNull(firstItem?['agent_data']);

    if (agentData == null) {
      return _buildGenericItemsDetails(
        colorScheme: colorScheme,
        textTheme: textTheme,
      );
    }

    final hardware = _mapOrNull(agentData['hardware']);
    final memory = _mapOrNull(hardware?['memory']);
    final disksUsage = _mapList(hardware?['disks_usage']);
    final network = _mapOrNull(agentData['network']);
    final openPorts = _mapList(network?['open_ports']);
    final powerData = _mapOrNull(agentData['power_data']);
    final systemData = _mapOrNull(agentData['system_data']);
    final users = _stringList(agentData['users']);

    return _buildSectionCard(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.computer_outlined,
            title: 'Datos del agente',
          ),
          const SizedBox(height: AppSpacing.sm),

          if (systemData != null) ...[
            _buildSubsectionLabel(textTheme, colorScheme, 'Sistema'),
            _buildInfoRow(
              colorScheme: colorScheme,
              textTheme: textTheme,
              label: 'SO',
              value: [
                _stringOrNull(systemData['system']),
                _stringOrNull(systemData['release']),
              ].whereType<String>().join(' '),
            ),
            if (_stringOrNull(systemData['version']) != null)
              _buildInfoRow(
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Versión',
                value: _stringOrNull(systemData['version'])!,
              ),
            if (_stringOrNull(systemData['platform']) != null)
              _buildInfoRow(
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Plataforma',
                value: _stringOrNull(systemData['platform'])!,
              ),
          ],

          if (hardware != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildSubsectionLabel(textTheme, colorScheme, 'Hardware'),
            if (_numberOrNull(hardware['cpu_usage']) != null)
              _buildInfoRow(
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'CPU',
                value: '${_numberOrNull(hardware['cpu_usage'])}%',
              ),
            if (memory != null)
              _buildInfoRow(
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'RAM',
                value:
                '${memory['percent']}% · ${memory['used_gb']} / ${memory['total_gb']} GB',
              ),
            if (disksUsage.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              for (final disk in disksUsage)
                _buildInfoRow(
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  label: _stringOrNull(disk['device']) ?? 'Disco',
                  value: '${disk['percent']}% usado',
                ),
            ],
          ],

          if (powerData != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildSubsectionLabel(textTheme, colorScheme, 'Energía'),
            if (_stringOrNull(powerData['uptime']) != null)
              _buildInfoRow(
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Uptime',
                value: _stringOrNull(powerData['uptime'])!,
              ),
            if (_stringOrNull(powerData['boot_time']) != null)
              _buildInfoRow(
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Arranque',
                value: _stringOrNull(powerData['boot_time'])!,
              ),
          ],

          if (network != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildSubsectionLabel(textTheme, colorScheme, 'Red'),
            if (_stringOrNull(network['network_packets_received']) != null)
              _buildInfoRow(
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Recibidos',
                value: _stringOrNull(network['network_packets_received'])!,
              ),
            if (_stringOrNull(network['network_packets_sent']) != null)
              _buildInfoRow(
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Enviados',
                value: _stringOrNull(network['network_packets_sent'])!,
              ),
            _buildInfoRow(
              colorScheme: colorScheme,
              textTheme: textTheme,
              label: 'Puertos',
              value: openPorts.length.toString(),
            ),
          ],

          if (users.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildSubsectionLabel(textTheme, colorScheme, 'Usuarios'),
            Text(
              users.join(', '),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMissingDataNotice({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: colorScheme.tertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Este widget todavía no tiene datos. Conecta un proveedor OAuth o registra un agente para empezar a recibir métricas.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.secondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }

  Widget _buildDescriptionSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String description,
  }) {
    return _buildSectionCard(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Descripción',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericItemsDetails({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return _buildItemsSection(
      colorScheme: colorScheme,
      textTheme: textTheme,
      title: 'Datos',
      icon: Icons.data_object_outlined,
      emptyText: 'No hay datos detallados para mostrar.',
      itemBuilder: (entry) {
        final title =
            _stringOrNull(entry['name']) ??
                _stringOrNull(entry['title']) ??
                _stringOrNull(entry['id']) ??
                'Elemento';

        return _buildItemCard(
          colorScheme: colorScheme,
          textTheme: textTheme,
          title: title,
          rows: entry.entries
              .where((field) => field.value != null)
              .take(4)
              .map((field) => '${_formatLabel(field.key) ?? field.key}: ${field.value}')
              .toList(),
        );
      },
    );
  }

  Widget _buildItemsSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String title,
    required IconData icon,
    required String emptyText,
    required Widget Function(Map<String, dynamic> item) itemBuilder,
  }) {
    final items = _itemsFromRawData();
    final visibleItems = items.take(8).toList();

    return _buildSectionCard(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: icon,
            title: title,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            Text(
              emptyText,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            for (final entry in visibleItems) ...[
              itemBuilder(entry),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (items.length > visibleItems.length)
              Text(
                'Mostrando ${visibleItems.length} de ${items.length} elementos.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String title,
    String? subtitle,
    List<String> rows = const [],
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null && subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (rows.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  row,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubsectionLabel(
      TextTheme textTheme,
      ColorScheme colorScheme,
      String label,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _itemsFromRawData() {
    final items = item.rawData?['items'];

    if (items is! List) {
      return [];
    }

    return items
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  Map<String, dynamic>? _firstItemFromRawData() {
    final items = _itemsFromRawData();

    if (items.isEmpty) {
      return null;
    }

    return items.first;
  }

  Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(value);
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((entry) => entry?.toString().trim())
        .whereType<String>()
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return null;
    }

    return text;
  }

  num? _numberOrNull(dynamic value) {
    if (value is num) {
      return value;
    }

    if (value is String) {
      return num.tryParse(value);
    }

    return null;
  }

  String? _formatLabel(String? value) {
    final text = _stringOrNull(value);

    if (text == null) {
      return null;
    }

    return text
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) {
      final lowerPart = part.toLowerCase();
      return '${lowerPart[0].toUpperCase()}${lowerPart.substring(1)}';
    })
        .join(' ');
  }

  String? _formatDateTime(DateTime? value) {
    if (value == null) {
      return null;
    }

    final local = value.toLocal();

    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  String _formatCurrency(num value, String? currency) {
    final formattedValue = value.toDouble().toStringAsFixed(2);

    if (currency == null || currency.isEmpty) {
      return formattedValue;
    }

    return '$formattedValue $currency';
  }

  Widget _buildDeleteAction({required ColorScheme colorScheme}) {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        label: const Text('Quitar widget'),
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.error,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  IconData _closeIconForPlacement() {
    switch (placement) {
      case DetailsPanelPlacement.side:
        return Icons.keyboard_arrow_right;
      case DetailsPanelPlacement.bottom:
        return Icons.keyboard_arrow_down;
    }
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (item.status) {
      case WidgetStatus.ok:
        return AppColors.success;
      case WidgetStatus.error:
        return AppColors.error;
      case WidgetStatus.inactive:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _iconForType(WidgetType type) {
    switch (type) {
      case WidgetType.status:
        return Icons.check_circle_outline;
      case WidgetType.metric:
        return Icons.speed_outlined;
      case WidgetType.list:
        return Icons.list_alt_outlined;
      case WidgetType.chart:
        return Icons.insert_chart_outlined;
      case WidgetType.service:
        return Icons.dns_outlined;
      case WidgetType.alert:
        return Icons.warning_amber_outlined;
      case WidgetType.pipeline:
        return Icons.account_tree_outlined;
      case WidgetType.issue:
        return Icons.bug_report_outlined;
    }
  }
}
