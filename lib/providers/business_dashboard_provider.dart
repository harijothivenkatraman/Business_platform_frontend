import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../models/member.dart';
import '../models/trainer.dart';
import '../models/kyc_record.dart';
import '../repositories/business_repository.dart';
import '../repositories/kyc_repository.dart';

class BusinessDashboardProvider extends ChangeNotifier {
  final IBusinessRepository _businessRepo;
  final IKycRepository _kycRepo;

  BusinessDashboardProvider({
    IBusinessRepository? businessRepo,
    IKycRepository? kycRepo,
  })  : _businessRepo = businessRepo ?? BusinessRepository(),
        _kycRepo = kycRepo ?? KycRepository();

  DashboardStats _stats = const DashboardStats();
  List<Member> _members = [];
  List<Trainer> _trainers = [];
  List<KycRecord> _pendingKyc = [];

  bool _isLoading = false;
  String? _error;

  DashboardStats get stats => _stats;
  List<Member> get members => _members;
  List<Trainer> get trainers => _trainers;
  List<KycRecord> get pendingKyc => _pendingKyc;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard(String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _businessRepo.getStats(businessId).catchError((_) => const DashboardStats()),
        _businessRepo.getMembers(businessId).catchError((_) => <Member>[]),
        _businessRepo.getTrainers(businessId).catchError((_) => <Trainer>[]),
        _kycRepo.getPendingReviews().catchError((_) => <KycRecord>[]),
      ]);

      _stats = results[0] as DashboardStats;
      _members = results[1] as List<Member>;
      _trainers = results[2] as List<Trainer>;
      _pendingKyc = results[3] as List<KycRecord>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reviewKyc(String id, String status, {String? notes}) async {
    try {
      await _kycRepo.reviewKyc(id, status, notes: notes);
      _pendingKyc.removeWhere((k) => k.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
