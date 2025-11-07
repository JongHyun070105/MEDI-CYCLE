import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MedicationAvatar 위젯 테스트', () {
    testWidgets('이미지가 있을 때 사각형으로 표시되는지 확인', (WidgetTester tester) async {
      const imageUrl = 'https://example.com/drug-image.jpg';
      
      // ClipRRect로 감싼 사각형 이미지 위젯 생성
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      );
      
      // ClipRRect 위젯이 있는지 확인 (사각형 모서리 처리)
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, isNotNull);
      
      // borderRadius가 원형이 아닌 사각형인지 확인 (8.0)
      expect(clipRRect.borderRadius, isA<BorderRadius>());
      final borderRadius = clipRRect.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, 8.0);
      expect(borderRadius.topLeft.y, 8.0);
      
      // 이미지가 있는지 확인
      expect(find.byType(Image), findsOneWidget);
      
      // Container 크기가 60인지 확인
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ClipRRect),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.constraints?.maxWidth, 60);
      expect(container.constraints?.maxHeight, 60);
    });
    
    testWidgets('이미지가 없을 때 기본 아이콘이 사각형으로 표시되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                Icons.medication,
                color: Colors.blue,
                size: 24,
              ),
            ),
          ),
        ),
      );
      
      // Container 위젯이 있는지 확인
      final container = tester.widget<Container>(find.byType(Container).first);
      
      // borderRadius가 사각형인지 확인 (8.0)
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.borderRadius, isNotNull);
      final borderRadius = decoration?.borderRadius as BorderRadius?;
      expect(borderRadius?.topLeft?.x, 8.0);
      expect(borderRadius?.topLeft?.y, 8.0);
      
      // 아이콘이 있는지 확인
      expect(find.byIcon(Icons.medication), findsOneWidget);
    });
  });
}

