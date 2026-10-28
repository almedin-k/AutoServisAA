using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
    public RegisterRequestValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("Ime je obavezno.")
            .MaximumLength(50).WithMessage("Ime ne može imati više od 50 znakova.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Prezime je obavezno.")
            .MaximumLength(50).WithMessage("Prezime ne može imati više od 50 znakova.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail adresa je obavezna.")
            .EmailAddress().WithMessage("Unesite ispravnu e-mail adresu, na primjer ime@primjer.ba.")
            .MaximumLength(100).WithMessage("E-mail adresa ne može imati više od 100 znakova.");

        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("Korisničko ime je obavezno.")
            .Matches("^[a-zA-Z0-9._-]{3,50}$")
            .WithMessage("Korisničko ime mora imati 3-50 znakova: slova, brojeve, tačke, donje crte ili crtice.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Lozinka je obavezna.")
            .Matches("^(?=.*[A-Za-z])(?=.*[0-9]).{8,100}$")
            .WithMessage("Lozinka mora imati najmanje 8 znakova, uključujući barem jedno slovo i jedan broj.");

        RuleFor(x => x.ConfirmPassword)
            .Equal(x => x.Password).WithMessage("Potvrđena lozinke se ne podudara s lozinkom.");

        RuleFor(x => x.PhoneNumber)
            .Matches(@"^\+?[0-9 ()/-]{6,20}$")
            .WithMessage("Unesite ispravan broj telefona, na primjer +38761123456.")
            .When(x => !string.IsNullOrWhiteSpace(x.PhoneNumber));
    }
}
