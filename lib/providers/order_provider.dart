// lib/providers/order_provider.dart
import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  // Game & Service
  String? selectedGame;
  String? serviceType;

  // Rank Details
  String? currentDivision;
  String? currentTier;
  int? currentMarks;
  String? targetDivision;
  String? targetTier;
  int? targetMarks;
  int? hours;
  int? totalAmount;

  // Final Submission
  String? fullName;
  String? ign;
  String? riotUsername;
  String? riotPassword;
  String? proofOfPaymentUrl;

  void selectGame(String game) {
    selectedGame = game;
    notifyListeners();
  }

  void selectService(String service) {
    serviceType = service;
    notifyListeners();
  }

  void updateRankDetails({
    String? currDiv,
    String? currTier,
    int? currMarks,
    String? targDiv,
    String? targTier,
    int? targMarks,
    int? hrs,
    int? total,
  }) {
    currentDivision = currDiv;
    currentTier = currTier;
    currentMarks = currMarks;
    targetDivision = targDiv;
    targetTier = targTier;
    targetMarks = targMarks;
    hours = hrs;
    totalAmount = total;
    notifyListeners();
  }

  void updateFinalDetails({
    required String name,
    required String ignName,
    required String riotUser,
    required String riotPass,
    String? proofUrl,
  }) {
    fullName = name;
    ign = ignName;
    riotUsername = riotUser;
    riotPassword = riotPass;
    proofOfPaymentUrl = proofUrl;
    notifyListeners();
  }

  void clearOrder() {
    selectedGame = null;
    serviceType = null;
    currentDivision = null;
    currentTier = null;
    currentMarks = null;
    targetDivision = null;
    targetTier = null;
    targetMarks = null;
    hours = null;
    totalAmount = null;
    fullName = null;
    ign = null;
    riotUsername = null;
    riotPassword = null;
    proofOfPaymentUrl = null;
    notifyListeners();
  }

  String get orderId {
    return "WR${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'game': selectedGame,
      'serviceType': serviceType,
      'currentDivision': currentDivision,
      'currentTier': currentTier,
      'currentMarks': currentMarks,
      'targetDivision': targetDivision,
      'targetTier': targetTier,
      'targetMarks': targetMarks,
      'hours': hours,
      'totalAmount': totalAmount,
      'fullName': fullName,
      'ign': ign,
      'riotUsername': riotUsername,
      'riotPassword': riotPassword,
      'proofOfPaymentUrl': proofOfPaymentUrl,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}