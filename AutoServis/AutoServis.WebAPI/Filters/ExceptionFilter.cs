using AutoServis.Model.Exceptions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace AutoServis.WebAPI.Filters;

// Maps exceptions to HTTP responses with a standard body: { message, errors, traceId }.
public class ExceptionFilter : IExceptionFilter
{
    private const string ClientErrorKey = "clientError";
    private const string ServerErrorKey = "serverError";

    private readonly ILogger<ExceptionFilter> _logger;

    public ExceptionFilter(ILogger<ExceptionFilter> logger)
    {
        _logger = logger;
    }

    public void OnException(ExceptionContext context)
    {
        var request = context.HttpContext.Request;
        var traceId = context.HttpContext.TraceIdentifier;

        int statusCode;
        Dictionary<string, string[]> errors;

        switch (context.Exception)
        {
            case FluentValidation.ValidationException validationException:
                statusCode = StatusCodes.Status400BadRequest;
                errors = validationException.Errors
                    .GroupBy(e => e.PropertyName)
                    .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorMessage).Distinct().ToArray());
                break;

            case BusinessException businessException:
                statusCode = StatusCodes.Status400BadRequest;
                errors = Single(ClientErrorKey, businessException.Message);
                break;

            case NotFoundException notFoundException:
                statusCode = StatusCodes.Status404NotFound;
                errors = Single(ClientErrorKey, notFoundException.Message);
                break;

            case AuthenticationFailedException authException:
                statusCode = StatusCodes.Status401Unauthorized;
                errors = Single(ClientErrorKey, authException.Message);
                break;

            default:
                statusCode = StatusCodes.Status500InternalServerError;
                errors = Single(ServerErrorKey, "An unexpected error occurred. Please try again later.");
                break;
        }

        var message = errors.Values.SelectMany(v => v).First();

        if (statusCode == StatusCodes.Status500InternalServerError)
        {
            _logger.LogError(
                context.Exception,
                "Unhandled exception for {Method} {Path} (trace {TraceId})",
                request.Method, request.Path, traceId);
        }
        else
        {
            _logger.LogWarning(
                "{Method} {Path} returned {StatusCode} (trace {TraceId}): {Message}",
                request.Method, request.Path, statusCode, traceId, message);
        }

        context.Result = new ObjectResult(new { message, errors, traceId })
        {
            StatusCode = statusCode
        };
        context.ExceptionHandled = true;
    }

    private static Dictionary<string, string[]> Single(string key, string message)
        => new() { [key] = new[] { message } };
}
