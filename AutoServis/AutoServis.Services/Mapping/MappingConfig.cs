using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Services.Database.Entities;
using Mapster;

namespace AutoServis.Services.Mapping;

public class MappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<Service, ServiceResponse>()
            .Map(dest => dest.CategoryName, src => src.Category.Name)
            .Map(dest => dest.RequiredParts, src => src.ServiceParts)
            .IgnoreNullValues(true);

        config.NewConfig<ServicePart, ServicePartResponse>()
            .Map(dest => dest.PartName, src => src.Part.Name)
            .Map(dest => dest.UnitPrice, src => src.Part.UnitPrice);

        config.NewConfig<VehicleUpsertRequest, Vehicle>()
            .Ignore(
                dest => dest.Id,
                dest => dest.UserId,
                dest => dest.User,
                dest => dest.Brand,
                dest => dest.IsDeleted,
                dest => dest.CreatedAt);
    }
}
