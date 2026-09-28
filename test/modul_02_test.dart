import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poliwangi_mobile_starter/modul_02/models/course.dart';
import 'package:poliwangi_mobile_starter/modul_02/widgets/course_card.dart';
import 'package:poliwangi_mobile_starter/modul_02/academic_dashboard_screen.dart';

void main() {
  group('Modul 02 Autograding: Declarative UI & Responsive Layout', () {
    test('1. Model Course mengembalikan daftar data sample valid', () {
      final sample = Course.getSampleCourses();

      expect(sample.length, greaterThanOrEqualTo(4));

      expect(sample.first.name, isNotEmpty);
      expect(sample.first.room, isNotEmpty);
      expect(sample.first.status, isNotEmpty);
      expect(sample.first.waktu, isNotEmpty);
    });

    testWidgets(
      '2. CourseCard merender informasi mata kuliah',
      (WidgetTester tester) async {
        final course = Course(
          name: 'Algoritma Pemrograman',
          room: 'Lab Komputer',
          status: 'Berlangsung',
          waktu: '08:00 - 10:00',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CourseCard(course: course),
            ),
          ),
        );

        expect(
          find.text('Algoritma Pemrograman'),
          findsOneWidget,
        );

        expect(
          find.text('Lab Komputer'),
          findsOneWidget,
        );

        expect(
          find.text('Berlangsung'),
          findsOneWidget,
        );

        expect(
          find.text('08:00 - 10:00'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '3. AcademicDashboardScreen adaptif: 1 kolom di mobile (<600dp), 2 kolom di tablet (>=600dp)',
      (WidgetTester tester) async {
        // Test mobile size (400 x 800)
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: AcademicDashboardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(ListView),
          findsOneWidget,
        );

        expect(
          find.byType(GridView),
          findsNothing,
        );

        // Test tablet/desktop size (800 x 600)
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: AcademicDashboardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(GridView),
          findsOneWidget,
        );

        addTearDown(
          tester.view.resetPhysicalSize,
        );

        addTearDown(
          tester.view.resetDevicePixelRatio,
        );
      },
    );
  });
}