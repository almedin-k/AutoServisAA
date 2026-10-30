// Small reusable form validators.
typedef FieldValidator = String? Function(String?);

class Validators {
  Validators._();
  static const String requiredMessage = 'Ovo polje je obavezno.';
  static final RegExp _usernamePattern = RegExp(r'^[a-zA-Z0-9._-]{3,50}$');
  static final RegExp _passwordPattern = RegExp(r'^(?=.*[A-Za-z])(?=.*[0-9]).{8,100}$');
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9 ()/-]{6,20}$');
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _vinPattern = RegExp(r'^[A-HJ-NPR-Za-hj-npr-z0-9]{17}$');
  static FieldValidator required([String message = requiredMessage]) {
    return (value) => (value == null || value.trim().isEmpty) ? message : null;
  }
  static FieldValidator maxLength(int max, [String? message]) {
    return (value) {
      if (value != null && value.trim().length > max) {
        return message ?? 'Ne može imati više od $max znakova.';
      }
      return null;
    };
  }

  static FieldValidator username() {
    return (value) {
      final text = (value ?? '').trim();
      if (text.isEmpty) {
        return 'Korisničko ime je obavezno.';
      }
      if (!_usernamePattern.hasMatch(text)) {
        return 'Korisničko ime mora imati 3-50 znakova: slova, brojeve, tačke, donje crte ili crtice.';
      }
      return null;
    };
  }

  static FieldValidator email() {
    return (value) {
      final text = (value ?? '').trim();
      if (text.isEmpty) {
        return 'E-mail adresa je obavezna.';
      }
      if (!_emailPattern.hasMatch(text)) {
        return 'Unesite ispravnu e-mail adresu, na primjer ime@primjer.ba.';
      }
      if (text.length > 100) {
        return 'E-mail adresa ne može imati više od 100 znakova.';
      }
      return null;
    };
  }

  static FieldValidator password() {
    return (value) {
      final text = value ?? '';
      if (text.isEmpty) {
        return 'Lozinka je obavezna.';
      }
      if (!_passwordPattern.hasMatch(text)) {
        return 'Lozinka mora imati najmanje 8 znakova, uključujući barem jedno slovo i jedan broj.';
      }
      return null;
    };
  }
  static FieldValidator sameAs(String? Function() other, String message) {
    return (value) => (value ?? '') == (other() ?? '') ? null : message;
  }

  static FieldValidator optionalPhone() {
    return (value) {
      final text = (value ?? '').trim();
      if (text.isEmpty) {
        return null;
      }
      return _phonePattern.hasMatch(text) ? null : 'Unesite ispravan broj telefona, na primjer +38761123456.';
    };
  }

  static FieldValidator differentFrom(String? Function() other, String message) {
    return (value) => (value ?? '') != (other() ?? '') ? null : message;
  }

  static FieldValidator vin() {
    return (value) {
      final text = (value ?? '').trim();
      if (text.isEmpty) {
        return 'Broj šasije je obavezan.';
      }
      if (!_vinPattern.hasMatch(text)) {
        return 'Broj šasije mora imati tačno 17 znakova: slova i brojeve, bez slova I, O i Q.';
      }
      return null;
    };
  }

  static FieldValidator integerInRange({
    required int min,
    required int max,
    required String requiredMessage,
    required String rangeMessage,
  }) {
    return (value) {
      final text = (value ?? '').trim();
      if (text.isEmpty) {
        return requiredMessage;
      }
      final number = int.tryParse(text);
      if (number == null || number < min || number > max) {
        return rangeMessage;
      }
      return null;
    };
  }

  static FieldValidator compose(List<FieldValidator> validators) {
    return (value) {
      for (final validator in validators) {
        final message = validator(value);
        if (message != null) {
          return message;
        }
      }
      return null;
    };
  }
}