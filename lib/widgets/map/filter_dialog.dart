import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';
import '../../models/service_type.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({Key? key}) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late bool _showTreatmentHubs;
  late bool _showPrepSites;
  late bool _showTestingSites;
  late bool _showLaboratory;
  late bool _showMultiService;

  @override
  void initState() {
    super.initState();
    final mapProvider = context.read<MapProvider>();
    _showTreatmentHubs = mapProvider.showTreatmentHubs;
    _showPrepSites = mapProvider.showPrepSites;
    _showTestingSites = mapProvider.showTestingSites;
    _showLaboratory = mapProvider.showLaboratory;
    _showMultiService = mapProvider.showMultiService;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter HIV Centers'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterTile(
              'Multi-Service Centers',
              'Centers offering multiple services',
              _showMultiService,
              Colors.purple,
              (value) => setState(() => _showMultiService = value!),
            ),
            const Divider(),
            _buildFilterTile(
              'HIV Treatment Hubs',
              'Comprehensive treatment centers',
              _showTreatmentHubs,
              ServiceType.treatment.color,
              (value) => setState(() => _showTreatmentHubs = value!),
            ),
            _buildFilterTile(
              'HIV PrEP Sites',
              'Pre-exposure prophylaxis',
              _showPrepSites,
              ServiceType.prep.color,
              (value) => setState(() => _showPrepSites = value!),
            ),
            _buildFilterTile(
              'HIVST Sites',
              'HIV self-testing locations',
              _showTestingSites,
              ServiceType.testing.color,
              (value) => setState(() => _showTestingSites = value!),
            ),
            _buildFilterTile(
              'RHIVDA Sites',
              'Laboratory services',
              _showLaboratory,
              ServiceType.laboratory.color,
              (value) => setState(() => _showLaboratory = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: _selectAll, child: const Text('Select All')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTile(
    String title,
    String subtitle,
    bool value,
    Color activeColor,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _selectAll() {
    setState(() {
      _showTreatmentHubs = true;
      _showPrepSites = true;
      _showTestingSites = true;
      _showLaboratory = true;
      _showMultiService = true;
    });
  }

  void _applyFilters() {
    context.read<MapProvider>().updateFilters(
      showTreatmentHubs: _showTreatmentHubs,
      showPrepSites: _showPrepSites,
      showTestingSites: _showTestingSites,
      showLaboratory: _showLaboratory,
      showMultiService: _showMultiService,
    );
    Navigator.of(context).pop();
  }
}
