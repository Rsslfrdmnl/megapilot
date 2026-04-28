// lib/screens/order_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';

class OrderFormScreen extends StatefulWidget {
  final String serviceType;

  const OrderFormScreen({required this.serviceType, super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  String? currentDivision;
  String? currentTier;
  int? currentMarks;

  String? targetDivision;
  String? targetTier;
  int? targetMarks;

  int? hours;
  int displayedTotal = 0;

  // Receipt data
  String? receiptCurrentDivision;
  String? receiptCurrentTier;
  int? receiptCurrentMarks;
  String? receiptTargetDivision;
  String? receiptTargetTier;
  int? receiptTargetMarks;
  int? receiptHours;
  int receiptTotal = 0;

  final List<String> divisions = ['Iron', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Emerald', 'Diamond', 'Master', 'Grandmaster', 'Challenger', 'Sovereign'];
  final List<String> tiers = ['IV', 'III', 'II', 'I'];

  final Map<String, String> rankImageUrls = {
    'Iron': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Firon.png?alt=media&token=813d0e4c-653e-44f1-af46-e3ee735eba42',
    'Bronze': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Fbronze.png?alt=media&token=5ad602fa-9e69-4193-9330-ea283412d7ab',
    'Silver': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Fsilver.png?alt=media&token=039f9d72-772a-4055-ab4c-946bf7b1768b',
    'Gold': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Fgold.png?alt=media&token=abe1d1b5-3d0a-4406-b4c5-541b9ced25f4',
    'Platinum': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Fplatinum.png?alt=media&token=021f0479-b810-440b-a729-b4b3eda83a89',
    'Emerald': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Femerald.png?alt=media&token=863533c1-8777-4f10-ba03-7dfb33b10942',
    'Diamond': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Fdiamond.png?alt=media&token=37e0c7b8-105b-49cf-88ed-b854e0907ea0',
    'Master': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Fmaster.png?alt=media&token=c01765a9-4f5f-4412-932b-fb1dc8f2155f',
    'Grandmaster': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Fgrandmaster.png?alt=media&token=2b1c4dbe-4e1a-4582-8322-ead78ee32915',
    'Challenger': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Fchallenger.png?alt=media&token=73ef3b82-8b4f-4489-a02e-57c6c65b2d6a',
    'Sovereign': 'https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/ranks%2Fsovereign.png?alt=media&token=0ebe8fa6-220c-439d-9f06-a414e9acba2c',
  };

// ==================== FIXED CALCULATION LOGIC + RECEIPT SAVING ====================
int _calculatedAmount() {
    if (widget.serviceType == 'Coach') {
      if (currentDivision == null || hours == null || hours! < 1) {
        _showError("Please select rank and enter hours (1-3)");
        return 0;
    }
    final total = (coachRatePerHour[currentDivision] ?? 150) * hours!;

    // Save receipt
    receiptCurrentDivision = currentDivision;
    receiptHours = hours;
    receiptTotal = total;
    return total;
  }

  // === BOOST MODE ===
  if (currentDivision == null || targetDivision == null || currentMarks == null || targetMarks == null) {
      _showError("Please fill all rank fields");
      return 0;
  }

  int startIndex = divisions.indexOf(currentDivision!);
  int endIndex = divisions.indexOf(targetDivision!);
  if (startIndex > endIndex) {
    return 0;
  }

  int total = 0;

  final bool isHighRankCurr = ['Master', 'Grandmaster', 'Challenger', 'Sovereign'].contains(currentDivision!);
  final bool isHighRankTarg = ['Master', 'Grandmaster', 'Challenger', 'Sovereign'].contains(targetDivision!);

// ====================== SAME DIVISION ======================
if (startIndex == endIndex) {

  final int price = pricePerMark[currentDivision!] ?? 0;
  final int marksPerTier = _getMarksPerTierForBoost(currentDivision!);

  int needed = 0;

  if (currentTier != null && targetTier != null) {
    final int currentTierIndex = tiers.indexOf(currentTier!);
    final int targetTierIndex = tiers.indexOf(targetTier!);


    // Tier indices: 0=IV (lowest), 3=I (highest)
    // We are going UP if targetTierIndex > currentTierIndex

    if (targetTierIndex > currentTierIndex) {
      // Moving to a higher tier (e.g. IV → I)
      int tiersToCross = targetTierIndex - currentTierIndex;           // e.g. 3 - 0 = 3

      // Marks needed to finish current tier + full tiers in between + target marks
      int marksToFinishCurrentTier = marksPerTier - currentMarks!;
      int marksFromFullTiers = (tiersToCross - 1) * marksPerTier;
      needed = marksToFinishCurrentTier + marksFromFullTiers + targetMarks!;
    } 
    else if (targetTierIndex == currentTierIndex) {
      // Same tier
      needed = targetMarks! - currentMarks!;
    } 
    else {
      // Target tier is lower than current → invalid
      needed = -1; // will trigger error below
    }
  } 
  else {
    // No tiers selected (high ranks like Master+)
    needed = targetMarks! - currentMarks!;
  }

  if (needed <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Current rank is already higher or equal to target"),
        backgroundColor: Colors.red,
      ),
    );
    return 0;
  }

  total = needed * price;
}
  // ====================== DIFFERENT DIVISIONS ======================
  else {
    if (isHighRankCurr && isHighRankTarg) {
      int needed = targetMarks! - currentMarks!;
      if (needed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Current rank is already higher or equal to target"), backgroundColor: Colors.red),
        );
        return 0;
      }
      int price = pricePerMark[currentDivision!] ?? 100;
      total = needed * price;
    } else {
      int priceCurr = pricePerMark[currentDivision!] ?? 0;

      if (!isHighRankCurr) {
        int marksPerTier = _getMarksPerTierForBoost(currentDivision!);
        int remainingInCurrentTier = marksPerTier - currentMarks!;

        if (remainingInCurrentTier > 0) {
          total += remainingInCurrentTier * priceCurr;
        }

        if (currentTier != null && currentTier != 'I') {
          int currentTierIndex = tiers.indexOf(currentTier!);
          int fullTiersLeft = 3 - currentTierIndex;
          total += fullTiersLeft * marksPerTier * priceCurr;
        }
      }

      for (int i = startIndex + 1; i < endIndex; i++) {
        String div = divisions[i];
        int mpt = _getMarksPerTierForBoost(div);
        int price = pricePerMark[div] ?? 0;
        int fullMarks = (div == 'Master' || div == 'Grandmaster' || div == 'Challenger') ? mpt : 4 * mpt;
        total += fullMarks * price;
      }

      if (targetMarks! > 0) {
        if (targetDivision == 'Sovereign') {
          int sovereignNeeded = targetMarks! - 60;
          if (sovereignNeeded > 0) {
            total += sovereignNeeded * (pricePerMark['Sovereign'] ?? 160);
          }
        } else {
          total += targetMarks! * (pricePerMark[targetDivision!] ?? 0);
        }
      }
    }
  }

  final finalTotal = total < 0 ? 0 : total;

  // === SAVE RECEIPT DATA ===
  if (finalTotal > 0) {
    receiptCurrentDivision = currentDivision;
    receiptCurrentTier = currentTier;
    receiptCurrentMarks = currentMarks;
    receiptTargetDivision = targetDivision;
    receiptTargetTier = targetTier;
    receiptTargetMarks = targetMarks;
    receiptHours = hours;
    receiptTotal = finalTotal;
  } else {
      _showError("Invalid rank selection. Please check current and target ranks.");
    }

  return finalTotal;
}

void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

// Helper: Marks needed to complete one full tier/division
int _getMarksPerTierForBoost(String division) {
  switch (division) {
    case 'Iron':
    case 'Bronze': return 2;
    case 'Silver':
    case 'Gold': return 3;
    case 'Platinum': return 4;
    case 'Emerald': return 5;
    case 'Diamond': return 6;
    case 'Master':
    case 'Grandmaster':
    case 'Challenger':
    case 'Sovereign': return 30;
    default: return 4;
  }
}

  final Map<String, int> pricePerMark = {
    'Iron': 10, 'Bronze': 20, 'Silver': 30, 'Gold': 60,
    'Platinum': 70, 'Emerald': 80, 'Diamond': 90, 'Master': 100,
    'Grandmaster': 120, 'Challenger': 140, 'Sovereign': 160,
  };

  final Map<String, int> coachRatePerHour = {
    'Iron': 150, 'Bronze': 150, 'Silver': 150, 'Gold': 150,
    'Platinum': 300, 'Emerald': 300, 'Diamond': 300,
    'Master': 500, 'Grandmaster': 500, 'Challenger': 600, 'Sovereign': 600,
  };

@override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final bool isCoach = widget.serviceType == 'Coach';
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          isCoach ? "COACHING SESSION" : "FILL UP THE FOLLOWING",
                          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.4, end: 0),

                        const SizedBox(height: 24),

                        // Main Form Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),  // Updated (fixed, no mobile condition)
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.12)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRankSelector("Current Rank", currentDivision, currentTier, currentMarks, true),
                              const SizedBox(height: 16),  // Updated

                              if (!isCoach)
                                _buildRankSelector("Target Rank", targetDivision, targetTier, targetMarks, false)
                              else
                                _buildHoursInput(),

                              const SizedBox(height: 24),  // Updated

                              const Text(
                                "RECEIPT",
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),  // Updated
                              _buildReceipt(isMobile: isMobile),

                              const SizedBox(height: 20),  // Updated

                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "TOTAL TO PAY",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "₱$displayedTotal",
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.cyan,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),  // Updated

                              // Calculate Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final bool isCoach = widget.serviceType == 'Coach';

                                    if (isCoach) {
                                      // Coach only needs Division + Hours
                                      if (currentDivision == null || hours == null || hours! < 1) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Please select a rank and enter hours (1-3)"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                    } else {
                                      // Boost validation with smart tier check
                                      if (currentDivision == null || currentMarks == null ||
                                          targetDivision == null || targetMarks == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Please fill in all fields"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      // Check tiers only for ranks that have them (Diamond and below)
                                      final bool currentNeedsTier = currentTier == null && 
                                          !['Master', 'Grandmaster', 'Challenger', 'Sovereign'].contains(currentDivision!);

                                      final bool targetNeedsTier = targetTier == null && 
                                          !['Master', 'Grandmaster', 'Challenger', 'Sovereign'].contains(targetDivision!);

                                      if (currentNeedsTier || targetNeedsTier) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Please select tier (IV, III, II, I) for Diamond and below"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                    }

                                    final total = _calculatedAmount();
                                    setState(() {
                                      displayedTotal = total;

                                      if (total > 0) {
                                        currentDivision = null;
                                        currentTier = null;
                                        currentMarks = null;
                                        targetDivision = null;
                                        targetTier = null;
                                        targetMarks = null;
                                        hours = null;
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyan,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 16),  // Updated
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    "CALCULATE TOTAL",
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),  // Updated

                        // Proceed to Payment Button
                        ElevatedButton(
                          onPressed: displayedTotal > 0
                              ? () {
                                  provider.updateRankDetails(
                                    currDiv: receiptCurrentDivision,
                                    currTier: receiptCurrentTier,
                                    currMarks: receiptCurrentMarks,
                                    targDiv: receiptTargetDivision,
                                    targTier: receiptTargetTier,
                                    targMarks: receiptTargetMarks,
                                    hrs: receiptHours,
                                    total: receiptTotal,
                                  );
                                  context.push('/payment');
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            "PROCEED TO PAYMENT",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(top: 20, left: 20, child: _buildNavButton(icon: Icons.arrow_back_ios_new, onTap: () => context.pop())),
              Positioned(top: 20, right: 20, child: _buildNavButton(icon: Icons.home, onTap: () => context.go('/choose-game'))),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildRankSelector(
    String label, 
    String? division, 
    String? tier, 
    int? marks, 
    bool isCurrent
  ) {
    final bool isHighRank = division != null && ['Master', 'Grandmaster', 'Challenger', 'Sovereign'].contains(division);
    final bool showTier = !isHighRank && division != null;

    int minMark = 1;
    int maxMark = 100;
    if (division != null) {
      if (division == 'Master') {
        minMark = isCurrent ? 0 : 1;
        maxMark = isCurrent ? 29 : 30;
      } else if (division == 'Grandmaster') {
        minMark = isCurrent ? 30 : 30;
        maxMark = isCurrent ? 59 : 60;
      } else if (division == 'Challenger') {
        minMark = isCurrent ? 60 : 60;
        maxMark = isCurrent ? 99 : 100;
      } else if (division == 'Sovereign') {
        // handled as TextField
      } else {
        maxMark = _getMarksPerTierForBoost(division);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 17)),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: division,
                    hint: const Text("Division", style: TextStyle(color: Colors.white54)),
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1A2E),
                    items: divisions.map((d) {
                      if (!isCurrent && currentDivision != null) {
                        if (divisions.indexOf(d) < divisions.indexOf(currentDivision!)) return null;
                      }
                      if (isCurrent && targetDivision != null) {
                        if (divisions.indexOf(d) > divisions.indexOf(targetDivision!)) return null;
                      }
                      return DropdownMenuItem(
                        value: d,
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: rankImageUrls[d] ?? '',
                              width: 36,
                              height: 36,
                              placeholder: (context, url) => const CircularProgressIndicator(color: Colors.cyan, strokeWidth: 3),
                              errorWidget: (context, url, error) => const Icon(Icons.emoji_events, color: Colors.white54, size: 36),
                            ),
                            const SizedBox(width: 12),
                            Text(d, style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      );
                    }).whereType<DropdownMenuItem<String>>().toList(),
                    onChanged: (val) {
                      setState(() {
                        if (isCurrent) {
                          currentDivision = val;
                          currentTier = showTier ? currentTier : null;
                          currentMarks = null;

                          if (targetDivision != null && val != null) {
                            if (divisions.indexOf(val) > divisions.indexOf(targetDivision!)) {
                              targetDivision = null;
                              targetTier = null;
                              targetMarks = null;
                            }
                          }
                        } else {
                          targetDivision = val;
                          targetTier = showTier ? targetTier : null;
                          targetMarks = null;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            if (showTier) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: tier,
                      hint: const Text("Tier", style: TextStyle(color: Colors.white54)),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1A1A2E),
                      items: tiers.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) {
                        setState(() {
                          if (isCurrent) currentTier = val;
                          else targetTier = val;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),

        Text(isCurrent ? "Current Marks" : "Target Marks", style: const TextStyle(color: Colors.white70, fontSize: 17)),
        const SizedBox(height: 8),

        if (division == 'Sovereign')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(border: InputBorder.none, hintText: "Enter marks", hintStyle: TextStyle(color: Colors.white54)),
              onChanged: (value) {
                setState(() {
                  if (isCurrent) currentMarks = int.tryParse(value);
                  else targetMarks = int.tryParse(value);
                });
              },
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: marks,
                hint: const Text("Select marks", style: TextStyle(color: Colors.white54)),
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1A2E),
                items: List.generate(maxMark - minMark + 1, (i) => minMark + i)
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text("$m marks", style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    if (isCurrent) currentMarks = val;
                    else targetMarks = val;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

    Widget _buildHoursInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("How many hours? (max 3)", style: TextStyle(color: Colors.white70, fontSize: 17)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 19),
            decoration: const InputDecoration(border: InputBorder.none, hintText: "1 - 3", hintStyle: TextStyle(color: Colors.white54)),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null && parsed > 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Maximum 3 hours allowed only"),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() => hours = 3);   // Force to max
                return;
              }
              setState(() => hours = parsed);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReceipt({required bool isMobile}) {
    if (receiptCurrentDivision == null || receiptTotal == 0) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),           // Same style as main form
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12)),  // Consistent border
        ),
        child: const Text(
          "Click CALCULATE TOTAL to see detailed receipt.",
          style: TextStyle(color: Colors.white70, height: 1.6, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      );
    }

    final bool isCoach = widget.serviceType == 'Coach';

    if (isCoach) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "RECEIPT - COACHING SESSION",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyan),
            ),
            const Divider(color: Colors.white24, height: 30),

            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: rankImageUrls[receiptCurrentDivision!] ?? '',
                  width: 52,
                  height: 52,
                  errorWidget: (context, url, error) => const Icon(Icons.emoji_events, color: Colors.white54, size: 52),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Coach Rank", style: TextStyle(color: Colors.white70, fontSize: 15)),
                      Text("$receiptCurrentDivision", 
                        style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text("$receiptHours hours", 
                        style: const TextStyle(fontSize: 18, color: Colors.cyan)),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(color: Colors.white24, height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TOTAL TO PAY", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  "₱$receiptTotal",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.cyan),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final bool showCurrentTier = receiptCurrentTier != null && 
        !['Master', 'Grandmaster', 'Challenger', 'Sovereign'].contains(receiptCurrentDivision!);
    final bool showTargetTier = receiptTargetTier != null && 
        !['Master', 'Grandmaster', 'Challenger', 'Sovereign'].contains(receiptTargetDivision!);

    String currentRankText = "$receiptCurrentDivision";
    if (showCurrentTier) currentRankText += " ${receiptCurrentTier}";
    currentRankText += " → $receiptCurrentMarks marks";

    String targetRankText = "$receiptTargetDivision";
    if (showTargetTier) targetRankText += " ${receiptTargetTier}";
    targetRankText += " → $receiptTargetMarks marks";

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DETAILS",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyan),
          ),
          const Divider(color: Colors.white24, height: 30),

          // Current Rank
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: rankImageUrls[receiptCurrentDivision!] ?? '',
                width: 48,
                height: 48,
                errorWidget: (context, url, error) => const Icon(Icons.emoji_events, color: Colors.white54, size: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Current Rank", style: TextStyle(color: Colors.white70, fontSize: 15)),
                    Text(currentRankText, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Target Rank
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: rankImageUrls[receiptTargetDivision!] ?? '',
                width: 48,
                height: 48,
                errorWidget: (context, url, error) => const Icon(Icons.emoji_events, color: Colors.white54, size: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Target Rank", style: TextStyle(color: Colors.white70, fontSize: 15)),
                    Text(targetRankText, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white24, height: 40),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TOTAL TO PAY", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(
                "₱$receiptTotal",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.cyan),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation Button with Hover Effect (same as ChooseServiceScreen)
  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return _NavButton(
      icon: icon,
      onTap: onTap,
    );
  }
}

// Navigation Button with Hover Effect (Reusable)
class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap, super.key});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(_isHovered ? 1.15 : 1.0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered 
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon, 
            color: Colors.white, 
            size: 28,
          ),
        ),
      ),
    );
  }
}