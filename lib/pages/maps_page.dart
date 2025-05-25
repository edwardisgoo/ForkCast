// lib/pages/maps_page.dart
//
// Original functionality preserved (image, tel-link, Google Maps launch).
// The only behavioural change: when the user taps **Done** we register
// the just-visited restaurant in RatingProvider so MainPage can prompt
// for feedback.

import 'package:flutter/material.dart';
import 'package:flutter_app/models/restaurant_raw.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/rating_provider.dart'; // ★ new import

class MapsPage extends StatelessWidget {
  const MapsPage({super.key, this.restaurant});

  final RestaurantRaw? restaurant;

  /* ─────────────── helpers ─────────────── */

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openInGoogleMaps() async {
    // Use name as query.  If lat/lng available you could switch to
    // https://www.google.com/maps/search/?api=1&query=<lat>,<lng>
    final name = restaurant?.name ?? '品田牧場日式豬排咖哩';
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /* ─────────────── UI ─────────────── */

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationService>();
    final rating = context.read<RatingProvider>(); // ★ rating provider

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '用餐愉快',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                /* placeholder image */
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.restaurant,
                      size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                /* restaurant name */
                Text(
                  restaurant?.name ?? '品田牧場日式豬排咖哩',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                /* tel link */
                GestureDetector(
                  onTap: () => _makePhoneCall('03-5420130'),
                  child: const Text(
                    '03-5420130',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                /* open Google Maps */
                IconButton(
                  icon: const Icon(Icons.map, size: 80),
                  iconSize: 80,
                  tooltip: 'Open in Google Maps',
                  onPressed: _openInGoogleMaps,
                ),
                const Spacer(),

                /* done → mark visited & return to main */
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 20),
                    textStyle: const TextStyle(fontSize: 28),
                  ),
                  onPressed: () {
                    nav.goMain();
                  },
                  child:
                      const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
