import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const DashboardCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffB8C9C0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          child,
        ],
      ),
    );
  }
}