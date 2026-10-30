using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;

namespace AutoServis.Services.Vehicles;
public interface IVehicleService
    : IBaseCRUDService<VehicleResponse, VehicleSearchObject, VehicleUpsertRequest, VehicleUpsertRequest>
{
}