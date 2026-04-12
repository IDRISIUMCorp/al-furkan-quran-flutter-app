import 'package:flutter/material.dart';

class SunnahWuduPage extends StatelessWidget {
  const SunnahWuduPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سنن الوضوء')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('سنن الوضوء من الكتب الموثوقة:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('1. التسمية في أوله.\n2. غسل الكفين ثلاثاً في أول الوضوء.\n3. السواك.\n4. المضمضة والاستنشاق.\n5. تخليل اللحية.\n6. تخليل الأصابع.\n7. التيامن (البدء باليمين).\n8. التثليث (الغسل ثلاثاً).\n9. الموالاة.\n10. الدلك.', style: TextStyle(fontSize: 16, height: 1.8)),
        ],
      ),
    );
  }
}
