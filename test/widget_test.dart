import 'package:communityops_agent/app/community_ops_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows CommunityOps Agent shell', (tester) async {
    await tester.pumpWidget(const CommunityOpsApp());

    expect(find.text('CommunityOps Agent'), findsOneWidget);
    expect(find.text('Planificar meetup'), findsOneWidget);
  });
}
