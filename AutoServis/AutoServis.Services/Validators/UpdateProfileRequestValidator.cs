using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class UpdateProfileRequestValidator : AbstractValidator<UpdateProfileRequest>
{
    public UpdateProfileRequestValidator()
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

        RuleFor(x => x.PhoneNumber)
            .Matches(@"^\+?[0-9 ()/-]{6,20}$")
            .WithMessage("Unesite ispravan broj telefona, na primjer +38761123456.")
            .When(x => !string.IsNullOrWhiteSpace(x.PhoneNumber));
    }
}