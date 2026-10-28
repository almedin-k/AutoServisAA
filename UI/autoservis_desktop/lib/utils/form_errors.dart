import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'api_client_exception.dart';

// Puts the validation messages returned by the API under the matching form controls
// Returns the messages that do not belong to a single control, to be shown in a banner.
List<String> applyServerErrors(GlobalKey<FormBuilderState> formKey, ApiClientException error) {
  if (error.fieldErrors.isEmpty) {
    return [error.message];
  }

  final leftovers = <String>[];
  final fields = formKey.currentState?.fields;
  error.fieldErrors.forEach((property, messages) {
    final name = property.isEmpty ? property : property[0].toLowerCase() + property.substring(1);
    final field = fields?[name];
    if (field != null) {
      field.invalidate(messages.join('\n'));
    } else {
      leftovers.addAll(messages);
    }
  });

  return leftovers;
}