using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
    public RegisterRequestValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("First name is required.")
            .MaximumLength(50).WithMessage("First name cannot be longer than 50 characters.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Last name is required.")
            .MaximumLength(50).WithMessage("Last name cannot be longer than 50 characters.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .EmailAddress().WithMessage("Enter a valid email address, for example name@example.com.")
            .MaximumLength(100).WithMessage("Email cannot be longer than 100 characters.");

        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("Username is required.")
            .Matches("^[a-zA-Z0-9._-]{3,50}$")
            .WithMessage("Username must have 3-50 characters: letters, numbers, dots, underscores or hyphens.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.")
            .Matches("^(?=.*[A-Za-z])(?=.*[0-9]).{8,100}$")
            .WithMessage("Password must have at least 8 characters, including at least one letter and one number.");

        RuleFor(x => x.ConfirmPassword)
            .Equal(x => x.Password).WithMessage("Password confirmation does not match the password.");

        RuleFor(x => x.PhoneNumber)
            .Matches(@"^\+?[0-9 ()/-]{6,20}$")
            .WithMessage("Enter a valid phone number, for example +38761123456.")
            .When(x => !string.IsNullOrWhiteSpace(x.PhoneNumber));
    }
}
