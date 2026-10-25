using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class ServiceUpsertValidator : AbstractValidator<ServiceUpsertRequest>
{
    public ServiceUpsertValidator()
    {
        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Please select a category.");

        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Service name is required.")
            .MaximumLength(100).WithMessage("Service name cannot be longer than 100 characters.");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Description is required.")
            .MaximumLength(1000).WithMessage("Description cannot be longer than 1000 characters.");

        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("Price must be greater than 0.")
            .LessThanOrEqualTo(100000).WithMessage("Price cannot be greater than 100,000 KM.")
            .Must(price => decimal.Round(price, 2) == price).WithMessage("Price can have at most 2 decimal places.");

        RuleFor(x => x.DurationMinutes)
            .InclusiveBetween(5, 720).WithMessage("Duration must be between 5 and 720 minutes.")
            .Must(minutes => minutes % 5 == 0).WithMessage("Duration must be a multiple of 5 minutes.");

        RuleFor(x => x.WarrantyMonths)
            .InclusiveBetween(0, 60).WithMessage("Warranty must be between 0 and 60 months.");

        RuleFor(x => x.RequiredParts)
            .Cascade(CascadeMode.Stop)
            .NotNull().WithMessage("The list of required parts is missing.")
            .Must(parts => parts.Count <= 30).WithMessage("A service can have at most 30 required parts.")
            .Must(parts => parts.Select(p => p.PartId).Distinct().Count() == parts.Count)
            .WithMessage("The same part cannot be added twice.");

        RuleForEach(x => x.RequiredParts).ChildRules(part =>
        {
            part.RuleFor(p => p.PartId).GreaterThan(0).WithMessage("Please select a part.");
            part.RuleFor(p => p.Quantity).InclusiveBetween(1, 100).WithMessage("Part quantity must be between 1 and 100.");
        });
    }
}
