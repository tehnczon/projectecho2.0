import 'package:flutter/material.dart';

class FilterCriteria {
  final bool showTreatmentHubs;
  final bool showPrepSites;
  final bool showTestingSites;
  final bool showLaboratory;
  final bool showMultiService;

  const FilterCriteria({
    this.showTreatmentHubs = true,
    this.showPrepSites = true,
    this.showTestingSites = true,
    this.showLaboratory = true,
    this.showMultiService = true,
  });

  FilterCriteria copyWith({
    bool? showTreatmentHubs,
    bool? showPrepSites,
    bool? showTestingSites,
    bool? showLaboratory,
    bool? showMultiService,
  }) {
    return FilterCriteria(
      showTreatmentHubs: showTreatmentHubs ?? this.showTreatmentHubs,
      showPrepSites: showPrepSites ?? this.showPrepSites,
      showTestingSites: showTestingSites ?? this.showTestingSites,
      showLaboratory: showLaboratory ?? this.showLaboratory,
      showMultiService: showMultiService ?? this.showMultiService,
    );
  }

  bool get hasAnyFilterEnabled =>
      showTreatmentHubs ||
      showPrepSites ||
      showTestingSites ||
      showLaboratory ||
      showMultiService;

  static const FilterCriteria all = FilterCriteria();
  static const FilterCriteria none = FilterCriteria(
    showTreatmentHubs: false,
    showPrepSites: false,
    showTestingSites: false,
    showLaboratory: false,
    showMultiService: false,
  );
}

class FilterProvider extends ChangeNotifier {
  FilterCriteria _criteria = FilterCriteria.all;

  FilterCriteria get criteria => _criteria;

  void updateCriteria(FilterCriteria newCriteria) {
    if (_criteria != newCriteria) {
      _criteria = newCriteria;
      notifyListeners();
    }
  }

  void toggleTreatmentHubs() {
    _criteria = _criteria.copyWith(
      showTreatmentHubs: !_criteria.showTreatmentHubs,
    );
    notifyListeners();
  }

  void togglePrepSites() {
    _criteria = _criteria.copyWith(showPrepSites: !_criteria.showPrepSites);
    notifyListeners();
  }

  void toggleTestingSites() {
    _criteria = _criteria.copyWith(
      showTestingSites: !_criteria.showTestingSites,
    );
    notifyListeners();
  }

  void toggleLaboratory() {
    _criteria = _criteria.copyWith(showLaboratory: !_criteria.showLaboratory);
    notifyListeners();
  }

  void toggleMultiService() {
    _criteria = _criteria.copyWith(
      showMultiService: !_criteria.showMultiService,
    );
    notifyListeners();
  }

  void selectAll() {
    updateCriteria(FilterCriteria.all);
  }

  void selectNone() {
    updateCriteria(FilterCriteria.none);
  }

  void reset() {
    updateCriteria(FilterCriteria.all);
  }
}
