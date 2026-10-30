using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class ChangePasswordRequestValidator : AbstractValidator<ChangePasswordRequest>
{
    public ChangePasswordRequestValidator()
    {
        RuleFor(x => x.CurrentPassword)
            .NotEmpty().WithMessage("Unesite trenutnu lozinku.");

        RuleFor(x => x.NewPassword)
            .NotEmpty().WithMessage("Nova lozinka je obavezna.")
            .Matches("^(?=.*[A-Za-z])(?=.*[0-9]).{8,100}$")
            .WithMessage("Lozinka mora imati najmanje 8 znakova, uključujući barem jedno slovo i jedan broj.")
            .NotEqual(x => x.CurrentPassword)
            .WithMessage("Nova lozinka mora biti različita od trenutne.");

        RuleFor(x => x.ConfirmNewPassword)
            .Equal(x => x.NewPassword).WithMessage("Potvrdjena lozinka se ne podudara s novom lozinkom.");
    }
}