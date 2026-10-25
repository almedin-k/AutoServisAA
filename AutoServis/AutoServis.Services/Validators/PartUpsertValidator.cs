using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class PartUpsertValidator : AbstractValidator<PartUpsertRequest>
{
    public PartUpsertValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Part name is required.")
            .MaximumLength(100).WithMessage("Part name cannot be longer than 100 characters.");

        RuleFor(x => x.Sku)
            .MaximumLength(50).WithMessage("SKU cannot be longer than 50 characters.")
            .Matches("^[A-Za-z0-9._-]+$").WithMessage("SKU can contain only letters, numbers, dots, dashes and underscores.")
            .When(x => !string.IsNullOrWhiteSpace(x.Sku));

        RuleFor(x => x.UnitPrice)
            .GreaterThanOrEqualTo(0).WithMessage("Unit price cannot be negative.")
            .LessThanOrEqualTo(100000).WithMessage("Unit price cannot be greater than 100,000 KM.")
            .Must(price => decimal.Round(price, 2) == price).WithMessage("Unit price can have at most 2 decimal places.");
    }
}
