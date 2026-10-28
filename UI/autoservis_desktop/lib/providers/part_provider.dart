import '../models/part.dart';
import 'base_provider.dart';

class PartProvider extends BaseProvider<Part> {
  PartProvider() : super('Parts');

  @override
  Part fromJson(Map<String, dynamic> json) => Part.fromJson(json);
}
