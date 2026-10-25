using AutoServis.Model.Responses;
using AutoServis.Services.Database.Entities;
using Mapster;

namespace AutoServis.Services.Mapping;

// Mapster mappings that cannot be inferred from matching property names. Picked up by TypeAdapterConfig.GlobalSettings.Scan in AddServiceLayer.
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
    }
}
