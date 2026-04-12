import 'package:flutter/material.dart';

class SunnahPrayerPage extends StatelessWidget {
  const SunnahPrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سنن الصلاة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('سنن الصلاة المذكورة في كتب السلف:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('1. رفع اليدين عند تكبيرة الإحرام، والركوع، والرفع منه.\n2. وضع اليد اليمنى على اليسرى على الصدر.\n3. النظر إلى موضع السجود.\n4. دعاء الاستفتاح.\n5. الاستعاذة والبسملة.\n6. التأمين (قول آمين).\n7. قراءة سورة بعد الفاتحة في الركعتين الأوليين.\n8. الجهر بالقراءة في صلاة الفجر، والركعتين الأوليين من المغرب والعشاء.\n9. الإسرار في الظهر والعصر.\n10. ما زاد على تسبيحة واحدة في الركوع والسجود.', style: TextStyle(fontSize: 16, height: 1.8)),
        ],
      ),
    );
  }
}
